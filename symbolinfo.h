#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H
#include <bits/stdc++.h>
using namespace std;
class symbolInfo
{
public:
    char name[40];
    char type[40];
    char vtype[40];
    int intvalue;
    char charvalue;
    float floatvalue;
    int size;
    string code;
    string arrIndexHolder;
    symbolInfo(){code="";arrIndexHolder="";}
    symbolInfo(char *n,char *t){
	strcpy(name,n);
	strcpy(type,t);
	code="";
	arrIndexHolder="";
    }
    class symbolInfo *next;
    class symbolInfo **aray;
};

#endif
