import functools
import os
import hashlib
import json

import base64
import struct


class RSAParser():
    # pylint: disable=too-few-public-methodsRyan Rossiter, 1 year ago: • SSH extension (#1363)
    RSAAlgorithm = 'ssh-rsa'

    def __init__(self):
        self.algorithm = ''
        self.modulus = ''
        self.exponent = ''
        self._key_length_big_endian = True

    def parse(self, public_key_text):
        text_parts = public_key_text.split(' ')

        if len(text_parts) < 2:
            error_str = ("Incorrectly formatted public key. "
                         "Key must be format '<algorithm> <base64_key>'")
            raise ValueError(error_str)

        algorithm = text_parts[0]
        if algorithm != RSAParser.RSAAlgorithm:
            raise ValueError(f"Public key is not ssh-rsa algorithm ({algorithm})")

        b64_string = text_parts[1]
        key_bytes = base64.b64decode(b64_string)
        fields = list(self._get_fields(key_bytes))

        if len(fields) < 3:
            error_str = ("Incorrectly encoded public key. "
                         "Encoded key must be base64 encoded <algorithm><exponent><modulus>")
            raise ValueError(error_str)

        encoded_algorithm = fields[0].decode("ascii")
        if encoded_algorithm != RSAParser.RSAAlgorithm:
            raise ValueError(f"Encoded public key is not ssh-rsa algorithm ({encoded_algorithm})")

        self.algorithm = encoded_algorithm
        self.exponent = base64.urlsafe_b64encode(fields[1]).decode("ascii")
        self.modulus = base64.urlsafe_b64encode(fields[2]).decode("ascii")

    def _get_fields(self, key_bytes):
        read = 0
        while read < len(key_bytes):
            length = struct.unpack(self._get_struct_format(), key_bytes[read:read + 4])[0]
            read = read + 4
            data = key_bytes[read:read + length]
            read = read + length
            yield data

    def _get_struct_format(self):
        format_start = ">" if self._key_length_big_endian else "<"
        return format_start + "L"


def _prepare_jwk_data(public_key_file):
    modulus, exponent = _get_modulus_exponent(public_key_file)
    key_hash = hashlib.sha256()
    key_hash.update(modulus.encode('utf-8'))
    key_hash.update(exponent.encode('utf-8'))
    key_id = key_hash.hexdigest()
    jwk = {
        "kty": "RSA",
        "n": modulus,
        "e": exponent,
        "kid": key_id
    }
    json_jwk = json.dumps(jwk)
    data = {
        "token_type": "ssh-cert",
        "req_cnf": json_jwk,
        "key_id": key_id
    }
    return data

def _get_modulus_exponent(public_key_file):


    with open(public_key_file, 'r') as f:
        public_key_text = f.read()

    parser = RSAParser()
    try:
        parser.parse(public_key_text)
    except Exception as e:
        pass
    modulus = parser.modulus
    exponent = parser.exponent

    return modulus, exponent

print(_prepare_jwk_data("C:\\Users\\yunwang\\source\\repos\\azure-powershell\\az_ssh_config\\wyunchi-wyunchi-vm\\id_rsa.pub"))