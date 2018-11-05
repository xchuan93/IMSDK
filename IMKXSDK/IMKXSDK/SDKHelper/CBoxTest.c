//
//  CBoxTest.c
//  WebSocketDemo
//
//  Created by Apple on 2018/6/30.
//  Copyright © 2018年 newbike. All rights reserved.
//

#include "CBoxTest.h"
#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void initCBox(char * alice_dir1,char * bob_dir1){
    char alice_tmp[] = "/tmp/cbox_test_aliceXXXXXX";
    char * alice_dir = mkdtemp(alice_tmp);
    assert(alice_dir != NULL);
    
    char bob_tmp[] = "/tmp/cbox_test_bobXXXXXX";
    char * bob_dir = mkdtemp(bob_tmp);
    assert(bob_dir != NULL);
    
    printf("alice=\"%s\", bob=\"%s\"\n", alice_tmp, bob_tmp);
    
    alice_dir1  = alice_dir;
    bob_dir1 = bob_dir;
    
//    CBoxResult rc = CBOX_SUCCESS;
//
//    CBox * alice_box = NULL;
//    rc = cbox_file_open(alice_dir, &alice_box);
//    assert(rc == CBOX_SUCCESS);
//    assert(alice_box != NULL);
//
//    CBox * bob_box = NULL;
//    rc = cbox_file_open(bob_dir, &bob_box);
//    assert(rc == CBOX_SUCCESS);
//    assert(bob_box != NULL);
//
//    // Run test cases
//    test_basics(alice_box, bob_box);
//
//    // Cleanup
//    cbox_close(alice_box);
//    cbox_close(bob_box);
}
