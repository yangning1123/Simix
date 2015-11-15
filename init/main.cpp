#include "drivers/Screen.h"

namespace Kernel
{
    void test()
    {
	char *video_memory = (char*) 0xb8000;
	*video_memory = 'X';
    }
}

void main()
{
    Kernel::test();
    IO::Screen screen(0, 0);
    screen.clear_screen();
}

