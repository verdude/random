use std::env;
use std::net::{TcpListener, TcpStream};
use std::io::Write;

fn handle_client(str: &str, stream: &mut TcpStream) {
    let resp = format!("HTTP/1.1 200\nContent-Length: {}\n\n{}", str.len(), str);
    match stream.write(&resp.to_string().into_bytes()) {
        Ok(bytes) => if bytes != resp.len() {
            println!("Possible error.");
        },
        Err(e) => println!("{}", e)
    }
}

fn main() {
    let mut args = env::args();
    let mut limit = 1;
    let mut paste: Option<String> = None;

    // parse args
    loop {
        let arg_opt = args.next();
        let arg: String;
        if arg_opt.is_none() {
            break;
        }
        else {
            // ... :c
            arg = arg_opt.unwrap();
        }

        if arg == "-l" {
            limit = args.next().unwrap_or("1".to_string()).parse::<u32>().unwrap_or(1);
        }
        else if paste.is_none() {
            paste = args.next();
        }
        else {
            println!("extra argument provided: {}", arg);
        }
    }

    let string: String = match paste {
        Some(s) => s.clone(),
        None => {
            println!("No string provided.");
            return;
        }
    };

    let port = "2222";
    let listener = TcpListener::bind(format!("0.0.0.0:{}", port).as_str())
        .expect(format!("Could not bind to port: {}", port).as_str());

    println!("Serving: {} {}-time[s]", string, limit);

    // limit  is consumed twice as fast using a browser because
    // it makes more requests specifically for favicons
    for stream in listener.incoming() {
        if limit == 0 {
            println!("Reached limit.");
            return;
        }
        match stream {
            Ok(mut stream) => {
                handle_client(&string.as_str(), &mut stream);
                limit -= 1;
                println!("{}", limit);
            },
            Err(e) => println!("error getting client stream: {}", e)
        }
    }
}
