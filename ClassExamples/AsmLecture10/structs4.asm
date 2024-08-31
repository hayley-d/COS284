struct example{
  char *p;  //8 bytes
  char c;   //1 byte
  //padds 3 bytes ebtween so that int x can start on a multiple of 4
  int x;    //4 bytes
}
//since the size of the struct adds up to 13 bytes with padding it should be 16 bytes

struct example2{
  char c // 1 byte
  //padds 7 bytes here
  char* p // 8 bytes
}
//the size of this struct is 16 bytes

struct example3{
  int e // 4 bytes
  char c  //1 byte
  //padd by 3 so that if we have another example3 struc after it is correct
}
//size is 8 bytes

struct example4{
  long e    //8 bytes
  char c    //1 bytes
  //padd by 7 bytes to get to 16 bytes total
}
//16 bytes total
