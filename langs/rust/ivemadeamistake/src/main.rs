extern crate ctrlc;
use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::{thread, time};
use std::path::Path;

fn get_string(f: &mut File) -> String {
    let mut string = String::new();
    let _ = f.read_to_string(&mut string);
    string.trim().to_string()
}

fn sleep(n: u64) {
    let duration = time::Duration::from_secs(n);
    thread::sleep(duration);
}

fn print_time(time: u64) {
    let sixty: f64 = 60.0;
    println!("\nIn Seconds: {}", time);
    println!("In Hours: {}", time as f64 / sixty / sixty);
}

fn get_fname() -> Result<String, String> {
    let res = env::args().skip(1).next();
    if res.is_none() {
        Err("Bad bad bad gimme string plis".to_string())
    }
    else {
        Ok(res.unwrap().clone())
    }
}

fn main() {
    let home = env::var("HOME").unwrap() + "/.mistakes/";
    let homeclone = home.clone();
    let fname: String = home + &get_fname().expect("No Filename");
    let fclone = fname.clone();
    let time = match File::open(fname) {
        Ok(mut r) => get_string(&mut r).parse::<u64>().unwrap(),
        Err(_) => {
            println!("{} not found, but that's ok bro, we'll just start from 0, ok?", fclone);
            0
        }
    };

    print_time(time);
    let now = time::Instant::now();

    ctrlc::set_handler(move || {
        let n = time + now.elapsed().as_secs();
        print_time(n);
        if ! Path::new(&homeclone).exists() {
            match std::fs::create_dir_all(&homeclone) {
                Err(e) => println!("{}", e),
                _ => println!("created mistakes dir")
            }
        }
        std::process::exit(match std::fs::write(fclone.as_str(), n.to_string()) {
            Ok(_) => 0,
            Err(_) => {
                println!("failure to write to file: {}", fclone);
                1
            }
        });
    }).expect("Error setting Ctrl-C handler");

    loop {
        sleep(u64::max_value());
    }
}
