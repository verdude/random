use std::env;
use std::collections::HashMap;

use hyper::body;
use hyper::{Method, Response, Request, Body, Client};
use hyper_tls::{HttpsConnector};

#[derive(Debug)]
struct Sextets {
    first: usize,
    second: usize,
    third: usize,
    fourth: usize,
}

fn get_first(byte: u8) -> usize {
    ((byte & 0b1111_1100) >> 2) as usize
}

fn get_second(left: u8, right: u8) -> usize {
    let second_1 = (0b0000_0011 & left) << 4;
    let second_2 = (0b1111_0000 & right) >> 4;

    (second_1 | second_2) as usize
}

fn get_third(left: u8, right: u8) -> usize {
    let third_1 = (0b0000_1111 & left) << 2;
    let third_2 = (0b1100_0000 & right) >> 6;

    (third_1 | third_2) as usize
}

fn get_fourth(byte: u8) -> usize {
    (byte & 0b0011_1111) as usize
}

fn get_sextets(bytes: &[u8]) -> Sextets {
    return Sextets {
        first: get_first(bytes[0]),
        second: get_second(bytes[0], bytes[1]),
        third: get_third(bytes[1], bytes[2]),
        fourth: get_fourth(bytes[2]),
    };
}

fn get_rest_of_bits(bytes: &[u8], table: &Vec<u8>) -> String {
    let mut retval = String::new();
    let first = get_first(bytes[0]);
    retval.push(table[first] as char);

    if bytes.len() == 2 {
        let second = get_second(bytes[0], bytes[1]);
        let third = get_third(bytes[1], 0);
        retval.push(table[second] as char);
        retval.push(table[third] as char);
        retval.push('=');
    }
    else if bytes.len() == 3 {
        let second = get_second(bytes[0], bytes[1]);
        let third = get_third(bytes[1], bytes[2]);
        let fourth = get_fourth(bytes[2]);
        retval.push(table[second] as char);
        retval.push(table[third] as char);
        retval.push(table[fourth] as char);
    }
    else {
        // len 1
        let second = get_second(bytes[0], 0);
        retval.push(table[second] as char);
        retval.push('=');
        retval.push('=');
    }
    retval
}

fn base64_encode(s: String, dst: &mut String) {
    let uppercase: Vec<u8> = (65..=90).collect();
    let lowercase: Vec<u8> = (97..=122).collect();
    let digits: Vec<u8> = (48..=57).collect();
    let mut table: Vec<u8> = Vec::new();
    table.extend(uppercase);
    table.extend(lowercase);
    table.extend(digits);
    table.push(42);
    table.push(47);

    assert_eq!(table.len(), 64);

    for bytes in s.into_bytes().chunks(3) {
        if bytes.len() == 3 {
            let the_boys = get_sextets(bytes);
            dst.push(table[the_boys.first] as char);
            dst.push(table[the_boys.second] as char);
            dst.push(table[the_boys.third] as char);
            dst.push(table[the_boys.fourth] as char);
        }
        else {
            dst.push_str(get_rest_of_bits(bytes, &table).as_str());
        }
    }
}

fn percent_encode(s: &str, dst: &mut String) {
    let chars_: [char;19] = ['!', '#',  '$',  '%',  '&',  '\'', '(', ')', '*', '+', ',', '/', ':', ';', '=', '?', '@', '[', ']'];
    let encodings_: [&str;19] = ["%21", "%23", "%24", "%25", "%26", "%27", "%28", "%29", "%2A", "%2B", "%2C", "%2F", "%3A", "%3B",
    "%3D", "%3F", "%40", "%5B", "%5D"];
    // Why is this so weird????
    let reserved: HashMap<&char, &&str> = chars_.iter().zip(encodings_.iter()).collect();

    for c in s.chars() {
        if reserved.contains_key(&c) {
            dst.push_str(reserved[&c]);
        }
        else {
            dst.push(c);
        }
    }
}

async fn print_body(res: Response<Body>) {
    match body::to_bytes(res.into_body()).await {
        Ok(b) => println!("{}", String::from_utf8(b.to_vec()).expect("response was not valid utf8")),
        Err(e) => println!("{}", e)
    }
}

// WHAT IS THIS????? :c
#[tokio::main]
async fn main() {
    let key_var = "TWILIO_ACCOUNT_SID";
    let token_var = "TWILIO_AUTH_TOKEN";
    let from_var = "TWILIO_FROM_NUMBER";
    let to_var = "MY_PHONE";

    let msg = env::args().skip(1).collect::<Vec<String>>().join(" ");
    if msg == "" {
        println!("NO MESSAGE SPECIFIED!!!");
        return;
    }

    let e_msg = |x: &str| format!("{} not found", x);

    let key = match env::var(key_var) {
        Ok(val) => val,
        Err(_) => panic!(e_msg(key_var))
    };
    let token = match env::var(token_var) {
        Ok(val) => val,
        Err(_) => panic!(e_msg(token_var))
    };
    let from = match env::var(from_var) {
        Ok(val) => val,
        Err(_) => panic!(e_msg(from_var))
    };
    let to = match env::var(to_var) {
        Ok(val) => val,
        Err(_) => panic!(e_msg(to_var))
    };

    let mut auth_enc: String = String::new();

    base64_encode(format!("{}:{}", key, token), &mut auth_enc);

    let mut req_body = String::new();
    let mut from_enc = String::new();
    let mut to_enc = String::new();
    let mut body_enc = String::new();

    percent_encode(from.as_str(), &mut from_enc);
    percent_encode(to.as_str(), &mut to_enc);
    percent_encode(msg.as_str(), &mut body_enc);

    req_body.push_str(format!("From={}&To={}&Body={}", from_enc, to_enc, body_enc).as_str());


    let uri = format!("https://api.twilio.com/2010-04-01/Accounts/{}/Messages.json", key);
    let https = HttpsConnector::new();
    let client = Client::builder().build::<_, Body>(https);
    let builder = Request::builder()
        .method(Method::POST)
        .uri(uri)
        .header("content-type", "application/x-www-form-urlencoded")
        .header("authorization", format!("Basic {}", auth_enc))
        .body(Body::from(req_body));

    let req = match builder {
        Ok(r) => r,
        _ => panic!("failed to build request")
    };

    match client.request(req).await {
        Ok(res) => {
            if ! res.status().is_success() {
                println!("Got Response Code: {}", res.status());
                print_body(res).await;
            }
        },
        Err(e) => println!("{}", e)
    };
}

