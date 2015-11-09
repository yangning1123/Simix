namespace kernel {
    void test()
    {
	char *video_memory = (char*) 0xb8140;
	*video_memory = 'X';
    }
}

void main()
{
    kernel::test();
}
