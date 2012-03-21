#include <cstdio>
#include <cstring>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <Foundation/Foundation.h>

void error_out(const char * s)
{
	NSLog(@"%s: %s",s,strerror(errno));
	exit(-1);
}

const char * fifo = NULL;
int fd = -1;
void cleanup(int sig)
{
	if (fifo)
		unlink(fifo);
	if (fd>0)
		close(fd);	
	if (sig != SIGHUP)
		NSLog(@"Daemon stopped");
	exit(sig);
}

void open_fd()
{
	NSLog(@"Waiting for MultiCleaner...");	
	
	do {
		fd = open(fifo,O_RDONLY);
	} while ((fd == -1) && (errno == EINTR));
	if (fd == -1)
		error_out("Can't open() fifo");
		
	NSLog(@"MultiCleaner arrived");
}

void parse_buffer(const char * b, size_t sz);

bool correctiOSVersion()
{
	NSDictionary * sysVersionDict = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	NSString * version = [sysVersionDict objectForKey:@"ProductVersion"];
	if (!version)
		return true;
		
	int majorVersion = 0;
	sscanf([version UTF8String],"%d",&majorVersion);
	[sysVersionDict release];
	
	return majorVersion>=5;
}

int main(int argc, char **argv, char **envp) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if (!correctiOSVersion())
		return 0;
	
	fifo = (argc>=2)?argv[1]:"/tmp/mckill";
	
	NSLog(@"Using %s",fifo);
	
	umask(0);
	if ((mkfifo(fifo,0666) == -1) && (errno!=EEXIST))
		error_out("Can't create fifo");
		
	if (signal (SIGINT, cleanup) == SIG_IGN)
		signal (SIGINT, SIG_IGN);
	if (signal (SIGHUP, cleanup) == SIG_IGN)
		signal (SIGHUP, SIG_IGN);
	if (signal (SIGTERM, cleanup) == SIG_IGN)
		signal (SIGTERM, SIG_IGN);
		
	open_fd();
	[pool drain];
		
	#define MAX_BUFFER 256
	char b[MAX_BUFFER];
	while(1)
	{
		int r = read(fd, b, MAX_BUFFER);
		int e = errno;
		if (r==-1 && (e == EAGAIN || e == EINTR)) continue;
		if (r==0)
		{
			pool = [[NSAutoreleasePool alloc] init];
			NSLog(@"MultiCleaner left");
			close(fd);
			fd = -1;
			open_fd();
			[pool drain];
			continue;
		}
		if (r<0) break;
		
		parse_buffer(b,r);
	}
	
	cleanup(0);
	return 0;
}

int pid = 0;
void parse_buffer(const char * b, size_t sz)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	for (size_t i=0; i<sz; i++)
	{
		char c = b[i];
		if (c>='0' && c<='9')
			pid = pid * 10 + (c-'0');
		if (c=='\n')
		{
			if (pid>0)
			{
				if (kill(pid,SIGTERM)==-1)
					NSLog(@"Couldn't kill PID %d: %s",pid,strerror(errno));
				else
					NSLog(@"Sent SIGTERM to PID %d\n",pid);
			}
			pid = 0;
		}
	}
	[pool drain];
}
