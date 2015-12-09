/*
 * 系统初始化时一系列函数，如打印内存信息等
 *
 */

#include "drivers/Screen.h"
#include "misc.h"

void Misc::disp_meminfo()
{
    using namespace IO;
    Screen screen(25, 2);
    //screen.scroll_line();
    screen.print_string("Hello, OS kernel!", COLOR_GREEN, COLOR_BLACK);
}
