//
//  SecureKey.c
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 1/3/18.
//  Copyright © 2018 Agile Infoways. All rights reserved.
//

#include "SecureKey.h"
#include <stdio.h>
#include <math.h>

char *encodePassword(const char *key)
{
    char *word;
    char i;
    word = malloc(strlen(key)); /* make space for the new string (should check the return value ...) */
    strcpy(word, key); /* copy key into the new var */
    
    for(i = 0; key[i]; i++) {
        int num = (int)key[i];
        double change = floor(cos(num) * 100);
        change = change < 0 ? change * -1 : change;
        change = change <= 32 ? change + i + 32 : change + i;
        char c = change;
        word[i] = c;
    }
    
    return word;
}

//char *decodePassword(const char *pass)
//{
//    char *word;
//    char i;
//    word = malloc(strlen(pass)); /* make space for the new string (should check the return value ...) */
//    strcpy(word, pass); /* copy key into the new var */
//
//    for(i = 0; pass[i]; i++) {
//        int num = (int)pass[i];
//                printf("%d\n",num);
//        num = num >= 32 ? num + i - 32 : num + i;
//        num = num > 0 ? num * -1 : num;
//        double change
////        double change = floor(cos(num) * 100);
////        change = change < 0 ? change * -1 : change;
////        change = change <= 32 ? change + i + 32 : change + i;
//        char c = change;
//                printf("%c",c);
//        word[i] = c;
//    }
//
//
//    return word;
//}

