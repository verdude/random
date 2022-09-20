use argparse::{ArgumentParser, Store};
use scraper::{Html, Selector};
use std::fs;
use std::io;

fn read_file(filename: &str) -> String {
    return fs::read_to_string(filename)
        .expect(&format!("Failed to read file {}", filename));
}

fn read_stdin() -> String {
    let lines = io::stdin().lines();
    let mut content = String::new();
    for line in lines {
        let line = line.unwrap();
        if line != "" {
            content.push_str(&line);
            content.push('\n');
        }
    }
    return content;
}

fn get_text(contents: String) -> Vec<&str> {
    let doc = Html::parse_document(&contents);
    let selector = Selector::parse("*").unwrap();
    let body = doc.select(&selector).next().unwrap();
    body.text().collect::<Vec<_>>()
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

    let contents = if file == "-" { read_stdin() } else { read_file(&file) };
    let text: Vec<String> = get_text(contents);
    let lines = text.iter().map(|s|s.replace("\n", ""));
    let mut vec = Vec::new();
    for line in lines {
        if line != "" {
            vec.push(line);
        }
    }
    println!("{}", vec.join("\n"));
}
