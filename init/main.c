void main()
{
    char *video_memory = (char*) 0xb8140;
    *video_memory = 'X';
}
