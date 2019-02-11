#!/usr/bin/env python3
from subprocess import Popen, PIPE, STDOUT
from threading import Thread
import sys, argparse, BaseHTTPServer, time, socket, shlex, cmd, os
promptText = '>> '

def main():
    global ip, port
    parser = argparse.ArgumentParser(description = 'Supple', add_help = True)
    parser.add_argument('port', action = 'store', default = 80, type = int, help = 'The port on which the supple server should run')
    parser.add_argument('-s', action = 'store', dest = 'script', help = 'A script with endpoints in the form: [endpoint] = [command], i.e. "/ = cat fileToServe"')
    values = parser.parse_args(sys.argv[1:])
    ip = getIp()
    port = values.port
    start(values.script)


def start(script = None):
    server = Server(('', port), Handler)
    thread = Thread(target = server.start)
    thread.start()
    print time.asctime() + " Supple Server started - %s:%s" % (ip, str(port))
    supple = Supple()
    if script:
        if os.path.isfile(script):
            for line in open(script).read().splitlines():
                supple.onecmd(line)
        else:
            print 'Could not find script "%s"' % script
    try:
        supple.cmdloop()
    except KeyboardInterrupt:
        pass
    server.shutdown()
    print time.asctime() + " Supple Server stopped - %s:%s" % (ip, str(port))
    thread.join()
    exit()

class Supple(cmd.Cmd):
    def __init__(self):
        self.aliases = {'l' : self.do_log, 'p' : self.do_print, 'ls' : self.do_print, 'h' : self.do_help, 'rm' : self.do_remove, 'r' : self.do_remove}
        self.log = Handler.log_message
        Handler.log_message = nothing
        cmd.Cmd.__init__(self)
        self.prompt = promptText

    def help_help(self):
        print 'Print help and usage for a command.'
        print 'usage: h|help [command]'

    def do_help(self, arg):
        print 'To add endpoints: [endpoint] = [command], i.e. "/newEndpoint = cat /home/username/fileToServe" or hit the server on any endpoint with a header of the form: "supple-script : [endpoint] = [command]"'
        if arg in self.aliases: arg = self.aliases[arg].__name__[3:]
        cmd.Cmd.do_help(self, arg)

    def help_log(self):
        print 'Toggles the server standard output logs on and off.'

    def do_log(self, line):
        if Handler.log_message == self.log:
            print 'Logging toggled off.'
            Handler.log_message = nothing
            self.prompt = promptText
        else:
            print 'Logging toggled on.'
            Handler.log_message = self.log
            self.prompt = ''

    def help_print(self):
        print 'Prints the current supplements with their commands and endpoints.'

    def do_print(self, line):
        for endpoint, supplement in Handler.supplements.iteritems(): print supplement.toString()

    def help_remove(self):
        print 'Removes the specified endpoints, i.e. remove /someEndpoint /someOtherEndpoint'

    def do_remove(self, line):
        cmd, arguments, line = self.parseline(line)
        deleted = False
        for arg in arguments.split():
            if arg in Handler.supplements.keys():
                del Handler.supplements[arg]
                deleted = True
        if deleted:
            print 'Removed "%s"' % arg
            self.do_print(line)
        else:
            print '"%s" not found' % arg
            self.do_print(line)

    def help_EOF(self):
        print 'EOF will stop supple execution.'

    def do_EOF(self, line):
        print 'Received an EOF'
        return True

    def default(self, line):
        cmd, arguments, line = self.parseline(line)
        if line in ('q', 'quit', 'exit'):
            print 'Press "Control + c" to quit'
        elif cmd in self.aliases:
            self.aliases[cmd](arguments)
        else:
            try:
                supplement = addSupplement(line, True)
                if supplement:
                    print supplement.toString()
                else:
                    raise Exception()
            except Exception as e:
                print '*** Invalid command: %s' % line
                print e

def addSupplement(line, overwrite = False):
    args = line.split(',')
    (endpoint, command) = args[0].split('=', 1)
    endpoint = endpoint.strip()
    command = command.strip()
    if endpoint in Handler.supplements.keys() and not overwrite:
        return None
    headers = {}
    for header in args[1:]:
        (key, value) = header.split(':', 1)
        headers[key.strip()] = value.strip()
    supplement = Supplement().addEndpoint(endpoint).addCommand(command).addHeaders(headers)
    Handler.supplements[endpoint] = supplement
    return supplement

class Server(BaseHTTPServer.HTTPServer):
    def start(self):
        try: self.serve_forever()
        except KeyboardInterrupt: pass
        finally: self.server_close()

class Handler(BaseHTTPServer.BaseHTTPRequestHandler):
    supplements = {}
    def do_GET(self):
        pathArgs = self.path.split('?', 1)
        path = pathArgs[0]
        args = pathArgs[1:]
        supplement = self.supplements.get(path, '')
        if supplement:
            self.send_response(200)
            for key, value in supplement.headers.iteritems():
                self.send_header(key, value)
            self.end_headers()
            self.wfile.write(supplement.execute(''), args)
        else:
            self.notFound()

    def do_PUT(self):
        try:
            pathArgs = self.path.split('?', 1)
            path = pathArgs[0]
            args = pathArgs[1:]
            supplement = addSupplement(path + " = " + self.rfile.read(int(self.headers.getheader('content-length', 0)))) if self.headers.getheader('supple-script').lower() in 'true' else None
        except Exception:
            message = 'Could not add supplement: "%s"' % suppleScript
            print
            print message
            self.send_response(500)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(message + '\n')

        if supplement:
            self.send_response(200)
            for key, value in supplement.headers.iteritems(): self.send_header(key, value)
            self.end_headers()
            self.wfile.write('Successfully created endpoint.\n')
            print
            print supplement.toString()
            sys.stdout.write(promptText)
        else:
            self.send_response(405)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write('Endpoint already exists.\n')

    def do_POST(self):
        pathArgs = self.path.split('?', 1)
        path = pathArgs[0]
        args = pathArgs[1:]
        supplement = self.supplements.get(path, '')
        if supplement:
            self.send_response(200)
            for key, value in supplement.headers.iteritems():
                self.send_header(key, value)
            self.end_headers()
            contentLength = int(self.headers.getheader('content-length', 0))
            self.wfile.write(supplement.execute(self.rfile.read(contentLength), args))
        else:
            self.notFound()

    def notFound(self):
        self.send_response(404)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write('Not Found\n')

class Supplement:
    def addHeaders(self, dictionary):
        self.headers = dictionary
        return self

    def addCommand(self, command):
        self.command = command
        return self

    def addEndpoint(self, endpoint):
        self.endpoint = endpoint
        return self

    def execute(self, input, args = None):
        fullCommand = self.command.split()
        if args:
            fullCommand = fullCommand.extend(args)
        process = Popen(fullCommand, stdout = PIPE, stdin = PIPE, stderr = STDOUT)
        return process.communicate(input = input)[0]

    def toString(self): return ip + ":" + str(port) + self.endpoint + " = " + self.command + ", Headers = " + ', '.join(' : '.join((k, v)) for k, v in self.headers.iteritems())

def getIp ():
    ips = []
    for currentIp in ["192.0.2.0", "198.51.100.0", "203.0.113.0"]:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect((currentIp, 80))
        ip = s.getsockname()[0]
        s.close()
        if ip in ips: return ip
        ips.append(ip)
    return ips[0]

def nothing(self, format, *args):
    pass

if __name__ == "__main__":
    main()
