use std::process::Command;
use std::process::Stdio;
use std::process::Child;
use std::env;

fn cleanup<T: std::fmt::Display>(baby: Result<Child, T>) {
    match baby {
        Ok(mut c) => {c.kill().expect("CRITICAL ERROR.");},
        Err(e) => {println!("ERROR MESSAGE FROM THE SYSTEM! PROCEED WITH EXTREME CAUTION: {}", e);}
    };
}

fn main() {
    let mut args = env::args().skip(1);
    let command = args.next().expect("no command specified.");
    let args = args.collect::<Vec<String>>();

    let mut redis_com = Command::new("redis-server");
    // disable persistence
    // disable output
    redis_com
        .arg("--save")
        .stdout(Stdio::null())
        .stderr(Stdio::null());
    let redis = redis_com.spawn();

    let mut proc = Command::new(command.clone());
    for arg in args.iter() {
        proc.arg(arg);
    }

    match proc.spawn() {
        Ok(child) => {
            let output = child
                .wait_with_output()
                .expect(&command);
        },
        Err(e) => {
            println!("CRITICAL FAILURE: {}", e);
        }
    }
    cleanup(redis);
}
