import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionData{
    encryptAES(String txt){

        final key = encrypt.Key.fromBase64('99118822773366445511002299338844');
        final iv = encrypt.IV.fromLength(16);
        print('Key ==; ${key.base64}');
        print('iv ==; ${iv.base16}');

        final encrypter = encrypt.Encrypter(encrypt.AES(key));

        final encrypted = encrypter.encrypt(txt, iv: iv);
        final decrypted = encrypter.decrypt(encrypted, iv: iv);

        print("Encrypted ::: $encrypted"); // Lorem ipsum dolor sit amet, consectetur adipiscing elit

        print("decrypted ::: $decrypted"); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
        print(encrypted.base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
        print(encrypted.base16); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
        print(encrypted.bytes); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==

    }

}