/* DXF2SCR.C

Program that crunches a DXF file with circles, arcs and lines into an
Eagle script file, useful for translating board outlines.

Hank Wallace 20-Mar-03
Revision 20-Mar-03

There are two licensing options for this program:

1. If you are a fan of the GNU license, and you think you
understand it, and you think it is reasonable, and you believe
that 'free to download' means 'high quality' or 'low maintenance
cost', and you are a computer geek who cannot get a date who
measures the value of his/her existence by the number of
marginally useful command line options you can stuff into one
program on a lonely Friday night, and you write C source code in
such a manner that there are more #define'd constants and
conditional compilation directives than there are actual C
source statements, and you attempt to make your programs so
'portable' that they runs on no machine whatsoever without
modification, then you have no license to use this software. Get
a life.

2. If you one of the other 6 billion people on planet Earth,
this program source code and executable is free for your use
without restriction, but NO WARRANTY OR SUPPORT IS GIVEN.


This program compiles under Microsoft's command line compiler,
version 12.00.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//#define M_PI 3.141592654

/* ========================================================= */

int main(int argument_count, char *argument[], char *environment[])
{
  char s[100],p;
  int
    i,
    state,
    lines,
    arcs,
    circles,
    linewidth=1;
  float x,y,x1,y1,x2,y2,x3,y3,r,theta1,theta3,xorg,yorg;
  FILE *ifile,*ofile;

  const char* dufus=
    "Program that crunches a DXF file with circles, arcs and lines\n"
    "into an Eagle script file. Items are put on the dimension layer.\n"
    "Usage:\n\n"
		"  A> DXF2SCR FILE.DXF FILE.SCR Xorg Yorg\n\n"
		"Where FILE.DXF is the name of the DXF file, and FILE.SCR is the\n"
		"      output file. (Xorg,Yorg) is the origin of the output file.\n"
		"      Xorg and Yorg are in decimal inches.\n";

  if (argument_count != 5)
    {
      printf(dufus);
      exit(1);
    }

  if ((ifile=fopen(argument[1],"ra")) == NULL)
    {
      printf(dufus);
      exit(1);
    }

  if ((ofile=fopen(argument[2],"wa")) == NULL)
    {
      printf(dufus);
      exit(1);
    }

  xorg=atof(argument[3])*1000;
  yorg=atof(argument[4])*1000;

  fprintf(ofile,"# DXF2SCR generated script file.\n");
  fprintf(ofile,"Grid mil 1 off;\n");
  fprintf(ofile,"Set Wire_Bend 2;\n");
  fprintf(ofile,"Layer Dimension;\n");
  fprintf(ofile,"Change Font Vector;\n");

  state=0;
  lines=arcs=circles=0;
  while (!feof(ifile))
    {
      *s=0;
      if (fgets(s,sizeof(s)-1,ifile) == NULL)
        break;

      switch (state)
        {
          case 0: // scanning for SECTION
            if (strncmp(s,"SECTION",7) == 0)
              state=1;
            break;
          case 1: // scanning for ENTITIES
            if (strncmp(s,"ENDSEC",6) == 0)
              state=0;
            if (strncmp(s,"ENTITIES",8) == 0)
              state=2;
            break;
          case 2: // scanning for LINE, ARC or CIRCLE
            if (strncmp(s,"ENDSEC",6) == 0)
              state=0;
            if (strncmp(s,"LINE",4) == 0)
              {
                state=3;
                lines++;
              }
            if (strncmp(s,"ARC",3) == 0)
              {
                state=4;
                arcs++;
              }
            if (strncmp(s,"CIRCLE",6) == 0)
              {
                state=5;
                circles++;
              }
            break;
          case 3: // absorbing LINE
            // LINE 10, 20, 30 (start point), 11, 21, 31 (end point).
            if (strncmp(s," 10",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                x=1000*atof(s);
              }
            if (strncmp(s," 20",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                y=1000*atof(s);
              }
            if (strncmp(s," 11",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                x1=1000*atof(s);
              }
            if (strncmp(s," 21",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                y1=1000*atof(s);
                fprintf(ofile,"Wire %d (%0.0f %0.0f) (%0.0f %0.0f);\n",
                  linewidth,x+xorg,y+yorg,x1+xorg,y1+yorg);
                state=2;
              }
            break;
          case 4: // absorbing ARC
            // ARC 10, 20, 30 (center), 40 (radius), 50 (start angle), 51 (end
            if (strncmp(s," 10",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                x=1000*atof(s);
              }
            if (strncmp(s," 20",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                y=1000*atof(s);
              }
            if (strncmp(s," 40",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                r=1000*atof(s);
              }
            if (strncmp(s," 50",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                theta1=atof(s);
                theta1*=(M_PI/180);
              }
            if (strncmp(s," 51",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                theta3=atof(s);
                theta3*=(M_PI/180);

                // compute Eagle arc parameters from DXF arc params
                x1=r*cos(theta1)+x;
                y1=r*sin(theta1)+y;
                x2=x1-2*r*cos(theta1);
                y2=y1-2*r*sin(theta1);
                x3=r*cos(theta3)+x;
                y3=r*sin(theta3)+y;

                fprintf(ofile,"Arc CCW %d (%0.0f %0.0f) (%0.0f %0.0f) (%0.0f %0.0f);\n",
                  linewidth,x1+xorg,y1+yorg,x2+xorg,y2+yorg,x3+xorg,y3+yorg);
                state=2;
              }
            break;
          case 5: // absorbing CIRCLE
            // CIRCLE 10, 20, 30 (center), 40 (radius).
            if (strncmp(s," 10",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                x=1000*atof(s);
              }
            if (strncmp(s," 20",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                y=1000*atof(s);
              }
            if (strncmp(s," 40",3) == 0)
              {
                fgets(s,sizeof(s)-1,ifile);
                y1=1000*atof(s);
                fprintf(ofile,"Circle %d (%0.0f %0.0f) (%0.0f %0.0f);\n",
                  linewidth,x+xorg,y+yorg,x+xorg,y+y1+yorg);
                state=2;
              }
            break;
        }
    }

  fprintf(ofile,"Window Fit;\n");
  fprintf(ofile,"# lines=%d, arcs=%d, circles=%d\n",lines,arcs,circles);
  fclose(ifile);
  fclose(ofile);
  exit(0);
  
  return 0;
}

