#!/usr/bin/env python3

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from platform import system
import subprocess
import smtplib

import argparse
import logging

logging.basicConfig(level=logging.INFO, handlers=[logging.StreamHandler()])
for handler in logging.getLogger().handlers:
    handler.setLevel(logging.INFO)
    handler.flush = lambda: None


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-y",
        "--youjian",
        type=str,
        required=True,
        help="郵件地址",
    )
    parser.add_argument(
        "-s",
        "--shoujianren",
        type=str,
        required=True,
        help="收件人郵件地址",
    )
    parser.add_argument(
        "-z",
        "--zhuti",
        type=str,
        required=True,
        help="郵件主題",
    )
    parser.add_argument(
        "-b",
        "--shenti",
        type=str,
        required=True,
        help="郵件正文",
    )
    return parser.parse_args()


def get_credentials(fuwu):
    if system() == "Linux":
        cmd = [
            "secret-tool", "lookup",
            "fuwu", "jiyoujian",
            "leixing", "yingyongmima",
            "zhanghu", fuwu
        ]
    else:
        cmd = [
            "security", "find-generic-password",
            "-a", fuwu,
            "-s", "local",
            "-w",
            "mima",
        ]

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


args = parse_args()
mima = get_credentials(args.youjian)

if (
    not mima
    or not args.youjian
    or not args.shoujianren
    or not args.zhuti
    or not args.shenti
):
    raise ValueError("你錯了")

message = MIMEMultipart()
message["From"] = args.youjian
message["To"] = args.shoujianren
message["Subject"] = args.zhuti

message.attach(MIMEText(args.shenti, "plain"))

try:
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(args.youjian, mima)
    server.sendmail(args.youjian, args.shoujianren, message.as_string())
    server.quit()
except Exception as e:
    print(f"Error sending email: {e}")
