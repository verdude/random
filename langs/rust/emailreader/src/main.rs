use argparse::{ArgumentParser, Store};
use std::fs;
use std::io;

fn read_file(filename: &str) -> String {
    println!("filename {}", filename);
    let contents: String = fs::read_to_string(filename)
        .expect(&format!("Failed to read file {}", filename));
    return contents;
}

fn read_stdin() -> String {
    let lines = io::stdin().lines();
    let mut content = String::new();
    for line in lines {
        let line: String = line.unwrap();
        if line != "" {
            content.push_str(&line);
            content.push('\n');
        }
    }
    return content;
}

fn get_text() -> String {
}

fn main() {
    let mut file = String::new();

    {
        let mut ap = ArgumentParser::new();
        ap.set_description("Parse Html Emails");
        ap.refer(&mut file)
            .add_argument("file", Store, "File to read or - for stdin.");
        ap.parse_args_or_exit();
    }

    let contents: String;
    if file == "-" {
        contents = read_stdin();
    } else {
        contents = read_file(&file);
    }
}
