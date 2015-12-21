/*
 * 系统初始化时一系列函数，如打印内存信息等
 *
 */

#include "drivers/Screen.h"
#include "Misc.h"

void Misc::disp_meminfo()
{
    using namespace IO;
    Screen screen(0, 0);    
    screen.print_string((char*)"Hello, OS kernel!", vga_color::COLOR_GREEN, vga_color::COLOR_BLACK);
}










