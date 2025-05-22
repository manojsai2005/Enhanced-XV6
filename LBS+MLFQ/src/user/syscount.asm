
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <get_syscall_index>:




int get_syscall_index(int mask)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int index = 0;
    while (mask > 1)
   8:	4705                	li	a4,1
   a:	00a75d63          	bge	a4,a0,24 <get_syscall_index+0x24>
   e:	87aa                	mv	a5,a0
    int index = 0;
  10:	4501                	li	a0,0
    {
        mask >>= 1; // Shift the mask right to check the next bit
  12:	4017d79b          	sraiw	a5,a5,0x1
        index++;
  16:	2505                	addiw	a0,a0,1
    while (mask > 1)
  18:	fef74de3          	blt	a4,a5,12 <get_syscall_index+0x12>
    }
    return index;
}
  1c:	60a2                	ld	ra,8(sp)
  1e:	6402                	ld	s0,0(sp)
  20:	0141                	addi	sp,sp,16
  22:	8082                	ret
    int index = 0;
  24:	4501                	li	a0,0
  26:	bfdd                	j	1c <get_syscall_index+0x1c>

0000000000000028 <main>:

int main(int argc, char *argv[])
{
  28:	7139                	addi	sp,sp,-64
  2a:	fc06                	sd	ra,56(sp)
  2c:	f822                	sd	s0,48(sp)
  2e:	0080                	addi	s0,sp,64
    if (argc < 3)
  30:	4789                	li	a5,2
  32:	02a7c263          	blt	a5,a0,56 <main+0x2e>
  36:	f426                	sd	s1,40(sp)
  38:	f04a                	sd	s2,32(sp)
  3a:	ec4e                	sd	s3,24(sp)
    {
        printf("Usage: syscount <mask> <command> [args]\n");
  3c:	00001517          	auipc	a0,0x1
  40:	8f450513          	addi	a0,a0,-1804 # 930 <malloc+0xfc>
  44:	00000097          	auipc	ra,0x0
  48:	734080e7          	jalr	1844(ra) # 778 <printf>
        exit(1);
  4c:	4505                	li	a0,1
  4e:	00000097          	auipc	ra,0x0
  52:	3ac080e7          	jalr	940(ra) # 3fa <exit>
  56:	f426                	sd	s1,40(sp)
  58:	f04a                	sd	s2,32(sp)
  5a:	84ae                	mv	s1,a1
    }

    // Convert the mask from the user input
    int mask = atoi(argv[1]);
  5c:	6588                	ld	a0,8(a1)
  5e:	00000097          	auipc	ra,0x0
  62:	296080e7          	jalr	662(ra) # 2f4 <atoi>
  66:	892a                	mv	s2,a0
    if (mask <= 0 || (mask & (mask - 1)) != 0)
  68:	00a05763          	blez	a0,76 <main+0x4e>
  6c:	fff5079b          	addiw	a5,a0,-1
  70:	8fe9                	and	a5,a5,a0
  72:	2781                	sext.w	a5,a5
  74:	cf99                	beqz	a5,92 <main+0x6a>
  76:	ec4e                	sd	s3,24(sp)
    { // Ensure mask is a power of 2
        printf("Error: Invalid mask (must be a power of 2)\n");
  78:	00001517          	auipc	a0,0x1
  7c:	8e850513          	addi	a0,a0,-1816 # 960 <malloc+0x12c>
  80:	00000097          	auipc	ra,0x0
  84:	6f8080e7          	jalr	1784(ra) # 778 <printf>
        exit(1);
  88:	4505                	li	a0,1
  8a:	00000097          	auipc	ra,0x0
  8e:	370080e7          	jalr	880(ra) # 3fa <exit>
  92:	ec4e                	sd	s3,24(sp)


    // Get the syscall index from the mask
    int syscall_index = get_syscall_index(mask);

    int pid = fork();
  94:	00000097          	auipc	ra,0x0
  98:	35e080e7          	jalr	862(ra) # 3f2 <fork>
  9c:	89aa                	mv	s3,a0
    if (pid < 0)
  9e:	02054763          	bltz	a0,cc <main+0xa4>
    {
        printf("Error: fork failed\n");
        exit(1);
    }

    if (pid == 0)
  a2:	e131                	bnez	a0,e6 <main+0xbe>
    {
        // In child process, run the command
        exec(argv[2], &argv[2]); // Exec the command with its arguments
  a4:	01048593          	addi	a1,s1,16
  a8:	6888                	ld	a0,16(s1)
  aa:	00000097          	auipc	ra,0x0
  ae:	388080e7          	jalr	904(ra) # 432 <exec>
        printf("Error: exec failed\n");
  b2:	00001517          	auipc	a0,0x1
  b6:	8f650513          	addi	a0,a0,-1802 # 9a8 <malloc+0x174>
  ba:	00000097          	auipc	ra,0x0
  be:	6be080e7          	jalr	1726(ra) # 778 <printf>
        exit(1);
  c2:	4505                	li	a0,1
  c4:	00000097          	auipc	ra,0x0
  c8:	336080e7          	jalr	822(ra) # 3fa <exit>
        printf("Error: fork failed\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	8c450513          	addi	a0,a0,-1852 # 990 <malloc+0x15c>
  d4:	00000097          	auipc	ra,0x0
  d8:	6a4080e7          	jalr	1700(ra) # 778 <printf>
        exit(1);
  dc:	4505                	li	a0,1
  de:	00000097          	auipc	ra,0x0
  e2:	31c080e7          	jalr	796(ra) # 3fa <exit>
    int syscall_index = get_syscall_index(mask);
  e6:	854a                	mv	a0,s2
  e8:	00000097          	auipc	ra,0x0
  ec:	f18080e7          	jalr	-232(ra) # 0 <get_syscall_index>
  f0:	84aa                	mv	s1,a0
    }
    else
    {
        // In parent process, wait for the child to exit
        int status;
        wait(&status);
  f2:	fcc40513          	addi	a0,s0,-52
  f6:	00000097          	auipc	ra,0x0
  fa:	30c080e7          	jalr	780(ra) # 402 <wait>

        // After the command has run, get the system call count based on the mask
        int count = getSysCount(pid, syscall_index);
  fe:	85a6                	mv	a1,s1
 100:	854e                	mv	a0,s3
 102:	00000097          	auipc	ra,0x0
 106:	3a0080e7          	jalr	928(ra) # 4a2 <getSysCount>
 10a:	86aa                	mv	a3,a0
        if (count >= 0)
 10c:	02054163          	bltz	a0,12e <main+0x106>
        {
            printf("PID %d called syscall %d (%d times)\n", pid, syscall_index, count);
 110:	8626                	mv	a2,s1
 112:	85ce                	mv	a1,s3
 114:	00001517          	auipc	a0,0x1
 118:	8ac50513          	addi	a0,a0,-1876 # 9c0 <malloc+0x18c>
 11c:	00000097          	auipc	ra,0x0
 120:	65c080e7          	jalr	1628(ra) # 778 <printf>
        {
            printf("Error getting syscall count\n");
        }
    }

    exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	2d4080e7          	jalr	724(ra) # 3fa <exit>
            printf("Error getting syscall count\n");
 12e:	00001517          	auipc	a0,0x1
 132:	8ba50513          	addi	a0,a0,-1862 # 9e8 <malloc+0x1b4>
 136:	00000097          	auipc	ra,0x0
 13a:	642080e7          	jalr	1602(ra) # 778 <printf>
 13e:	b7dd                	j	124 <main+0xfc>

0000000000000140 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 140:	1141                	addi	sp,sp,-16
 142:	e406                	sd	ra,8(sp)
 144:	e022                	sd	s0,0(sp)
 146:	0800                	addi	s0,sp,16
  extern int main();
  main();
 148:	00000097          	auipc	ra,0x0
 14c:	ee0080e7          	jalr	-288(ra) # 28 <main>
  exit(0);
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	2a8080e7          	jalr	680(ra) # 3fa <exit>

000000000000015a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 162:	87aa                	mv	a5,a0
 164:	0585                	addi	a1,a1,1
 166:	0785                	addi	a5,a5,1
 168:	fff5c703          	lbu	a4,-1(a1)
 16c:	fee78fa3          	sb	a4,-1(a5)
 170:	fb75                	bnez	a4,164 <strcpy+0xa>
    ;
  return os;
}
 172:	60a2                	ld	ra,8(sp)
 174:	6402                	ld	s0,0(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret

000000000000017a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e406                	sd	ra,8(sp)
 17e:	e022                	sd	s0,0(sp)
 180:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb91                	beqz	a5,19a <strcmp+0x20>
 188:	0005c703          	lbu	a4,0(a1)
 18c:	00f71763          	bne	a4,a5,19a <strcmp+0x20>
    p++, q++;
 190:	0505                	addi	a0,a0,1
 192:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	fbe5                	bnez	a5,188 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 19a:	0005c503          	lbu	a0,0(a1)
}
 19e:	40a7853b          	subw	a0,a5,a0
 1a2:	60a2                	ld	ra,8(sp)
 1a4:	6402                	ld	s0,0(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strlen>:

uint
strlen(const char *s)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cf99                	beqz	a5,1d4 <strlen+0x2a>
 1b8:	0505                	addi	a0,a0,1
 1ba:	87aa                	mv	a5,a0
 1bc:	86be                	mv	a3,a5
 1be:	0785                	addi	a5,a5,1
 1c0:	fff7c703          	lbu	a4,-1(a5)
 1c4:	ff65                	bnez	a4,1bc <strlen+0x12>
 1c6:	40a6853b          	subw	a0,a3,a0
 1ca:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1cc:	60a2                	ld	ra,8(sp)
 1ce:	6402                	ld	s0,0(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret
  for(n = 0; s[n]; n++)
 1d4:	4501                	li	a0,0
 1d6:	bfdd                	j	1cc <strlen+0x22>

00000000000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e406                	sd	ra,8(sp)
 1dc:	e022                	sd	s0,0(sp)
 1de:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e0:	ca19                	beqz	a2,1f6 <memset+0x1e>
 1e2:	87aa                	mv	a5,a0
 1e4:	1602                	slli	a2,a2,0x20
 1e6:	9201                	srli	a2,a2,0x20
 1e8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ec:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f0:	0785                	addi	a5,a5,1
 1f2:	fee79de3          	bne	a5,a4,1ec <memset+0x14>
  }
  return dst;
}
 1f6:	60a2                	ld	ra,8(sp)
 1f8:	6402                	ld	s0,0(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret

00000000000001fe <strchr>:

char*
strchr(const char *s, char c)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e406                	sd	ra,8(sp)
 202:	e022                	sd	s0,0(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cf81                	beqz	a5,222 <strchr+0x24>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1c>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xe>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	60a2                	ld	ra,8(sp)
 21c:	6402                	ld	s0,0(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret
  return 0;
 222:	4501                	li	a0,0
 224:	bfdd                	j	21a <strchr+0x1c>

0000000000000226 <gets>:

char*
gets(char *buf, int max)
{
 226:	7159                	addi	sp,sp,-112
 228:	f486                	sd	ra,104(sp)
 22a:	f0a2                	sd	s0,96(sp)
 22c:	eca6                	sd	s1,88(sp)
 22e:	e8ca                	sd	s2,80(sp)
 230:	e4ce                	sd	s3,72(sp)
 232:	e0d2                	sd	s4,64(sp)
 234:	fc56                	sd	s5,56(sp)
 236:	f85a                	sd	s6,48(sp)
 238:	f45e                	sd	s7,40(sp)
 23a:	f062                	sd	s8,32(sp)
 23c:	ec66                	sd	s9,24(sp)
 23e:	e86a                	sd	s10,16(sp)
 240:	1880                	addi	s0,sp,112
 242:	8caa                	mv	s9,a0
 244:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 246:	892a                	mv	s2,a0
 248:	4481                	li	s1,0
    cc = read(0, &c, 1);
 24a:	f9f40b13          	addi	s6,s0,-97
 24e:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 250:	4ba9                	li	s7,10
 252:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 254:	8d26                	mv	s10,s1
 256:	0014899b          	addiw	s3,s1,1
 25a:	84ce                	mv	s1,s3
 25c:	0349d763          	bge	s3,s4,28a <gets+0x64>
    cc = read(0, &c, 1);
 260:	8656                	mv	a2,s5
 262:	85da                	mv	a1,s6
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	1ac080e7          	jalr	428(ra) # 412 <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x64>
    buf[i++] = c;
 272:	f9f44783          	lbu	a5,-97(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01778763          	beq	a5,s7,288 <gets+0x62>
 27e:	0905                	addi	s2,s2,1
 280:	fd879ae3          	bne	a5,s8,254 <gets+0x2e>
    buf[i++] = c;
 284:	8d4e                	mv	s10,s3
 286:	a011                	j	28a <gets+0x64>
 288:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 28a:	9d66                	add	s10,s10,s9
 28c:	000d0023          	sb	zero,0(s10)
  return buf;
}
 290:	8566                	mv	a0,s9
 292:	70a6                	ld	ra,104(sp)
 294:	7406                	ld	s0,96(sp)
 296:	64e6                	ld	s1,88(sp)
 298:	6946                	ld	s2,80(sp)
 29a:	69a6                	ld	s3,72(sp)
 29c:	6a06                	ld	s4,64(sp)
 29e:	7ae2                	ld	s5,56(sp)
 2a0:	7b42                	ld	s6,48(sp)
 2a2:	7ba2                	ld	s7,40(sp)
 2a4:	7c02                	ld	s8,32(sp)
 2a6:	6ce2                	ld	s9,24(sp)
 2a8:	6d42                	ld	s10,16(sp)
 2aa:	6165                	addi	sp,sp,112
 2ac:	8082                	ret

00000000000002ae <stat>:

int
stat(const char *n, struct stat *st)
{
 2ae:	1101                	addi	sp,sp,-32
 2b0:	ec06                	sd	ra,24(sp)
 2b2:	e822                	sd	s0,16(sp)
 2b4:	e04a                	sd	s2,0(sp)
 2b6:	1000                	addi	s0,sp,32
 2b8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ba:	4581                	li	a1,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	17e080e7          	jalr	382(ra) # 43a <open>
  if(fd < 0)
 2c4:	02054663          	bltz	a0,2f0 <stat+0x42>
 2c8:	e426                	sd	s1,8(sp)
 2ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2cc:	85ca                	mv	a1,s2
 2ce:	00000097          	auipc	ra,0x0
 2d2:	184080e7          	jalr	388(ra) # 452 <fstat>
 2d6:	892a                	mv	s2,a0
  close(fd);
 2d8:	8526                	mv	a0,s1
 2da:	00000097          	auipc	ra,0x0
 2de:	148080e7          	jalr	328(ra) # 422 <close>
  return r;
 2e2:	64a2                	ld	s1,8(sp)
}
 2e4:	854a                	mv	a0,s2
 2e6:	60e2                	ld	ra,24(sp)
 2e8:	6442                	ld	s0,16(sp)
 2ea:	6902                	ld	s2,0(sp)
 2ec:	6105                	addi	sp,sp,32
 2ee:	8082                	ret
    return -1;
 2f0:	597d                	li	s2,-1
 2f2:	bfcd                	j	2e4 <stat+0x36>

00000000000002f4 <atoi>:

int
atoi(const char *s)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fc:	00054683          	lbu	a3,0(a0)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	4625                	li	a2,9
 30a:	02f66963          	bltu	a2,a5,33c <atoi+0x48>
 30e:	872a                	mv	a4,a0
  n = 0;
 310:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 312:	0705                	addi	a4,a4,1
 314:	0025179b          	slliw	a5,a0,0x2
 318:	9fa9                	addw	a5,a5,a0
 31a:	0017979b          	slliw	a5,a5,0x1
 31e:	9fb5                	addw	a5,a5,a3
 320:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 324:	00074683          	lbu	a3,0(a4)
 328:	fd06879b          	addiw	a5,a3,-48
 32c:	0ff7f793          	zext.b	a5,a5
 330:	fef671e3          	bgeu	a2,a5,312 <atoi+0x1e>
  return n;
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  n = 0;
 33c:	4501                	li	a0,0
 33e:	bfdd                	j	334 <atoi+0x40>

0000000000000340 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e406                	sd	ra,8(sp)
 344:	e022                	sd	s0,0(sp)
 346:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 348:	02b57563          	bgeu	a0,a1,372 <memmove+0x32>
    while(n-- > 0)
 34c:	00c05f63          	blez	a2,36a <memmove+0x2a>
 350:	1602                	slli	a2,a2,0x20
 352:	9201                	srli	a2,a2,0x20
 354:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 358:	872a                	mv	a4,a0
      *dst++ = *src++;
 35a:	0585                	addi	a1,a1,1
 35c:	0705                	addi	a4,a4,1
 35e:	fff5c683          	lbu	a3,-1(a1)
 362:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
    dst += n;
 372:	00c50733          	add	a4,a0,a2
    src += n;
 376:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 378:	fec059e3          	blez	a2,36a <memmove+0x2a>
 37c:	fff6079b          	addiw	a5,a2,-1
 380:	1782                	slli	a5,a5,0x20
 382:	9381                	srli	a5,a5,0x20
 384:	fff7c793          	not	a5,a5
 388:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38a:	15fd                	addi	a1,a1,-1
 38c:	177d                	addi	a4,a4,-1
 38e:	0005c683          	lbu	a3,0(a1)
 392:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 396:	fef71ae3          	bne	a4,a5,38a <memmove+0x4a>
 39a:	bfc1                	j	36a <memmove+0x2a>

000000000000039c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a4:	ca0d                	beqz	a2,3d6 <memcmp+0x3a>
 3a6:	fff6069b          	addiw	a3,a2,-1
 3aa:	1682                	slli	a3,a3,0x20
 3ac:	9281                	srli	a3,a3,0x20
 3ae:	0685                	addi	a3,a3,1
 3b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b2:	00054783          	lbu	a5,0(a0)
 3b6:	0005c703          	lbu	a4,0(a1)
 3ba:	00e79863          	bne	a5,a4,3ca <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 3be:	0505                	addi	a0,a0,1
    p2++;
 3c0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c2:	fed518e3          	bne	a0,a3,3b2 <memcmp+0x16>
  }
  return 0;
 3c6:	4501                	li	a0,0
 3c8:	a019                	j	3ce <memcmp+0x32>
      return *p1 - *p2;
 3ca:	40e7853b          	subw	a0,a5,a4
}
 3ce:	60a2                	ld	ra,8(sp)
 3d0:	6402                	ld	s0,0(sp)
 3d2:	0141                	addi	sp,sp,16
 3d4:	8082                	ret
  return 0;
 3d6:	4501                	li	a0,0
 3d8:	bfdd                	j	3ce <memcmp+0x32>

00000000000003da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e2:	00000097          	auipc	ra,0x0
 3e6:	f5e080e7          	jalr	-162(ra) # 340 <memmove>
}
 3ea:	60a2                	ld	ra,8(sp)
 3ec:	6402                	ld	s0,0(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret

00000000000003f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f2:	4885                	li	a7,1
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fa:	4889                	li	a7,2
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <wait>:
.global wait
wait:
 li a7, SYS_wait
 402:	488d                	li	a7,3
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40a:	4891                	li	a7,4
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <read>:
.global read
read:
 li a7, SYS_read
 412:	4895                	li	a7,5
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <write>:
.global write
write:
 li a7, SYS_write
 41a:	48c1                	li	a7,16
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <close>:
.global close
close:
 li a7, SYS_close
 422:	48d5                	li	a7,21
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <kill>:
.global kill
kill:
 li a7, SYS_kill
 42a:	4899                	li	a7,6
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <exec>:
.global exec
exec:
 li a7, SYS_exec
 432:	489d                	li	a7,7
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <open>:
.global open
open:
 li a7, SYS_open
 43a:	48bd                	li	a7,15
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 442:	48c5                	li	a7,17
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44a:	48c9                	li	a7,18
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 452:	48a1                	li	a7,8
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <link>:
.global link
link:
 li a7, SYS_link
 45a:	48cd                	li	a7,19
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 462:	48d1                	li	a7,20
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46a:	48a5                	li	a7,9
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <dup>:
.global dup
dup:
 li a7, SYS_dup
 472:	48a9                	li	a7,10
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47a:	48ad                	li	a7,11
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 482:	48b1                	li	a7,12
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48a:	48b5                	li	a7,13
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 492:	48b9                	li	a7,14
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 49a:	48d9                	li	a7,22
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 4a2:	48dd                	li	a7,23
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4aa:	48e1                	li	a7,24
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4b2:	48e5                	li	a7,25
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 4ba:	48e9                	li	a7,26
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c2:	1101                	addi	sp,sp,-32
 4c4:	ec06                	sd	ra,24(sp)
 4c6:	e822                	sd	s0,16(sp)
 4c8:	1000                	addi	s0,sp,32
 4ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ce:	4605                	li	a2,1
 4d0:	fef40593          	addi	a1,s0,-17
 4d4:	00000097          	auipc	ra,0x0
 4d8:	f46080e7          	jalr	-186(ra) # 41a <write>
}
 4dc:	60e2                	ld	ra,24(sp)
 4de:	6442                	ld	s0,16(sp)
 4e0:	6105                	addi	sp,sp,32
 4e2:	8082                	ret

00000000000004e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e4:	7139                	addi	sp,sp,-64
 4e6:	fc06                	sd	ra,56(sp)
 4e8:	f822                	sd	s0,48(sp)
 4ea:	f426                	sd	s1,40(sp)
 4ec:	f04a                	sd	s2,32(sp)
 4ee:	ec4e                	sd	s3,24(sp)
 4f0:	0080                	addi	s0,sp,64
 4f2:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f4:	c299                	beqz	a3,4fa <printint+0x16>
 4f6:	0805c063          	bltz	a1,576 <printint+0x92>
  neg = 0;
 4fa:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4fc:	fc040313          	addi	t1,s0,-64
  neg = 0;
 500:	869a                	mv	a3,t1
  i = 0;
 502:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 504:	00000817          	auipc	a6,0x0
 508:	56480813          	addi	a6,a6,1380 # a68 <digits>
 50c:	88be                	mv	a7,a5
 50e:	0017851b          	addiw	a0,a5,1
 512:	87aa                	mv	a5,a0
 514:	02c5f73b          	remuw	a4,a1,a2
 518:	1702                	slli	a4,a4,0x20
 51a:	9301                	srli	a4,a4,0x20
 51c:	9742                	add	a4,a4,a6
 51e:	00074703          	lbu	a4,0(a4)
 522:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 526:	872e                	mv	a4,a1
 528:	02c5d5bb          	divuw	a1,a1,a2
 52c:	0685                	addi	a3,a3,1
 52e:	fcc77fe3          	bgeu	a4,a2,50c <printint+0x28>
  if(neg)
 532:	000e0c63          	beqz	t3,54a <printint+0x66>
    buf[i++] = '-';
 536:	fd050793          	addi	a5,a0,-48
 53a:	00878533          	add	a0,a5,s0
 53e:	02d00793          	li	a5,45
 542:	fef50823          	sb	a5,-16(a0)
 546:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 54a:	fff7899b          	addiw	s3,a5,-1
 54e:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 552:	fff4c583          	lbu	a1,-1(s1)
 556:	854a                	mv	a0,s2
 558:	00000097          	auipc	ra,0x0
 55c:	f6a080e7          	jalr	-150(ra) # 4c2 <putc>
  while(--i >= 0)
 560:	39fd                	addiw	s3,s3,-1
 562:	14fd                	addi	s1,s1,-1
 564:	fe09d7e3          	bgez	s3,552 <printint+0x6e>
}
 568:	70e2                	ld	ra,56(sp)
 56a:	7442                	ld	s0,48(sp)
 56c:	74a2                	ld	s1,40(sp)
 56e:	7902                	ld	s2,32(sp)
 570:	69e2                	ld	s3,24(sp)
 572:	6121                	addi	sp,sp,64
 574:	8082                	ret
    x = -xx;
 576:	40b005bb          	negw	a1,a1
    neg = 1;
 57a:	4e05                	li	t3,1
    x = -xx;
 57c:	b741                	j	4fc <printint+0x18>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	715d                	addi	sp,sp,-80
 580:	e486                	sd	ra,72(sp)
 582:	e0a2                	sd	s0,64(sp)
 584:	f84a                	sd	s2,48(sp)
 586:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c903          	lbu	s2,0(a1)
 58c:	1a090a63          	beqz	s2,740 <vprintf+0x1c2>
 590:	fc26                	sd	s1,56(sp)
 592:	f44e                	sd	s3,40(sp)
 594:	f052                	sd	s4,32(sp)
 596:	ec56                	sd	s5,24(sp)
 598:	e85a                	sd	s6,16(sp)
 59a:	e45e                	sd	s7,8(sp)
 59c:	8aaa                	mv	s5,a0
 59e:	8bb2                	mv	s7,a2
 5a0:	00158493          	addi	s1,a1,1
  state = 0;
 5a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a6:	02500a13          	li	s4,37
 5aa:	4b55                	li	s6,21
 5ac:	a839                	j	5ca <vprintf+0x4c>
        putc(fd, c);
 5ae:	85ca                	mv	a1,s2
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	f10080e7          	jalr	-240(ra) # 4c2 <putc>
 5ba:	a019                	j	5c0 <vprintf+0x42>
    } else if(state == '%'){
 5bc:	01498d63          	beq	s3,s4,5d6 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5c0:	0485                	addi	s1,s1,1
 5c2:	fff4c903          	lbu	s2,-1(s1)
 5c6:	16090763          	beqz	s2,734 <vprintf+0x1b6>
    if(state == 0){
 5ca:	fe0999e3          	bnez	s3,5bc <vprintf+0x3e>
      if(c == '%'){
 5ce:	ff4910e3          	bne	s2,s4,5ae <vprintf+0x30>
        state = '%';
 5d2:	89d2                	mv	s3,s4
 5d4:	b7f5                	j	5c0 <vprintf+0x42>
      if(c == 'd'){
 5d6:	13490463          	beq	s2,s4,6fe <vprintf+0x180>
 5da:	f9d9079b          	addiw	a5,s2,-99
 5de:	0ff7f793          	zext.b	a5,a5
 5e2:	12fb6763          	bltu	s6,a5,710 <vprintf+0x192>
 5e6:	f9d9079b          	addiw	a5,s2,-99
 5ea:	0ff7f713          	zext.b	a4,a5
 5ee:	12eb6163          	bltu	s6,a4,710 <vprintf+0x192>
 5f2:	00271793          	slli	a5,a4,0x2
 5f6:	00000717          	auipc	a4,0x0
 5fa:	41a70713          	addi	a4,a4,1050 # a10 <malloc+0x1dc>
 5fe:	97ba                	add	a5,a5,a4
 600:	439c                	lw	a5,0(a5)
 602:	97ba                	add	a5,a5,a4
 604:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	ed0080e7          	jalr	-304(ra) # 4e4 <printint>
 61c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 61e:	4981                	li	s3,0
 620:	b745                	j	5c0 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000ba583          	lw	a1,0(s7)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	eb4080e7          	jalr	-332(ra) # 4e4 <printint>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b751                	j	5c0 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 63e:	008b8913          	addi	s2,s7,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000ba583          	lw	a1,0(s7)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e98080e7          	jalr	-360(ra) # 4e4 <printint>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	b7a5                	j	5c0 <vprintf+0x42>
 65a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 65c:	008b8c13          	addi	s8,s7,8
 660:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 664:	03000593          	li	a1,48
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e58080e7          	jalr	-424(ra) # 4c2 <putc>
  putc(fd, 'x');
 672:	07800593          	li	a1,120
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e4a080e7          	jalr	-438(ra) # 4c2 <putc>
 680:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 682:	00000b97          	auipc	s7,0x0
 686:	3e6b8b93          	addi	s7,s7,998 # a68 <digits>
 68a:	03c9d793          	srli	a5,s3,0x3c
 68e:	97de                	add	a5,a5,s7
 690:	0007c583          	lbu	a1,0(a5)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e2c080e7          	jalr	-468(ra) # 4c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69e:	0992                	slli	s3,s3,0x4
 6a0:	397d                	addiw	s2,s2,-1
 6a2:	fe0914e3          	bnez	s2,68a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6a6:	8be2                	mv	s7,s8
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	6c02                	ld	s8,0(sp)
 6ac:	bf11                	j	5c0 <vprintf+0x42>
        s = va_arg(ap, char*);
 6ae:	008b8993          	addi	s3,s7,8
 6b2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6b6:	02090163          	beqz	s2,6d8 <vprintf+0x15a>
        while(*s != 0){
 6ba:	00094583          	lbu	a1,0(s2)
 6be:	c9a5                	beqz	a1,72e <vprintf+0x1b0>
          putc(fd, *s);
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e00080e7          	jalr	-512(ra) # 4c2 <putc>
          s++;
 6ca:	0905                	addi	s2,s2,1
        while(*s != 0){
 6cc:	00094583          	lbu	a1,0(s2)
 6d0:	f9e5                	bnez	a1,6c0 <vprintf+0x142>
        s = va_arg(ap, char*);
 6d2:	8bce                	mv	s7,s3
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b5ed                	j	5c0 <vprintf+0x42>
          s = "(null)";
 6d8:	00000917          	auipc	s2,0x0
 6dc:	33090913          	addi	s2,s2,816 # a08 <malloc+0x1d4>
        while(*s != 0){
 6e0:	02800593          	li	a1,40
 6e4:	bff1                	j	6c0 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	000bc583          	lbu	a1,0(s7)
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	dd2080e7          	jalr	-558(ra) # 4c2 <putc>
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b5d1                	j	5c0 <vprintf+0x42>
        putc(fd, c);
 6fe:	02500593          	li	a1,37
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	dbe080e7          	jalr	-578(ra) # 4c2 <putc>
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd4d                	j	5c0 <vprintf+0x42>
        putc(fd, '%');
 710:	02500593          	li	a1,37
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	dac080e7          	jalr	-596(ra) # 4c2 <putc>
        putc(fd, c);
 71e:	85ca                	mv	a1,s2
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	da0080e7          	jalr	-608(ra) # 4c2 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bd51                	j	5c0 <vprintf+0x42>
        s = va_arg(ap, char*);
 72e:	8bce                	mv	s7,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	b579                	j	5c0 <vprintf+0x42>
 734:	74e2                	ld	s1,56(sp)
 736:	79a2                	ld	s3,40(sp)
 738:	7a02                	ld	s4,32(sp)
 73a:	6ae2                	ld	s5,24(sp)
 73c:	6b42                	ld	s6,16(sp)
 73e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 740:	60a6                	ld	ra,72(sp)
 742:	6406                	ld	s0,64(sp)
 744:	7942                	ld	s2,48(sp)
 746:	6161                	addi	sp,sp,80
 748:	8082                	ret

000000000000074a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74a:	715d                	addi	sp,sp,-80
 74c:	ec06                	sd	ra,24(sp)
 74e:	e822                	sd	s0,16(sp)
 750:	1000                	addi	s0,sp,32
 752:	e010                	sd	a2,0(s0)
 754:	e414                	sd	a3,8(s0)
 756:	e818                	sd	a4,16(s0)
 758:	ec1c                	sd	a5,24(s0)
 75a:	03043023          	sd	a6,32(s0)
 75e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	8622                	mv	a2,s0
 764:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 768:	00000097          	auipc	ra,0x0
 76c:	e16080e7          	jalr	-490(ra) # 57e <vprintf>
}
 770:	60e2                	ld	ra,24(sp)
 772:	6442                	ld	s0,16(sp)
 774:	6161                	addi	sp,sp,80
 776:	8082                	ret

0000000000000778 <printf>:

void
printf(const char *fmt, ...)
{
 778:	711d                	addi	sp,sp,-96
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e40c                	sd	a1,8(s0)
 782:	e810                	sd	a2,16(s0)
 784:	ec14                	sd	a3,24(s0)
 786:	f018                	sd	a4,32(s0)
 788:	f41c                	sd	a5,40(s0)
 78a:	03043823          	sd	a6,48(s0)
 78e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 792:	00840613          	addi	a2,s0,8
 796:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79a:	85aa                	mv	a1,a0
 79c:	4505                	li	a0,1
 79e:	00000097          	auipc	ra,0x0
 7a2:	de0080e7          	jalr	-544(ra) # 57e <vprintf>
}
 7a6:	60e2                	ld	ra,24(sp)
 7a8:	6442                	ld	s0,16(sp)
 7aa:	6125                	addi	sp,sp,96
 7ac:	8082                	ret

00000000000007ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ae:	1141                	addi	sp,sp,-16
 7b0:	e406                	sd	ra,8(sp)
 7b2:	e022                	sd	s0,0(sp)
 7b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	00001797          	auipc	a5,0x1
 7be:	8467b783          	ld	a5,-1978(a5) # 1000 <freep>
 7c2:	a02d                	j	7ec <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c4:	4618                	lw	a4,8(a2)
 7c6:	9f2d                	addw	a4,a4,a1
 7c8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7cc:	6398                	ld	a4,0(a5)
 7ce:	6310                	ld	a2,0(a4)
 7d0:	a83d                	j	80e <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d2:	ff852703          	lw	a4,-8(a0)
 7d6:	9f31                	addw	a4,a4,a2
 7d8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7da:	ff053683          	ld	a3,-16(a0)
 7de:	a091                	j	822 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x3c>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x4c>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bgeu	a5,a3,7e0 <free+0x32>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059813          	slli	a6,a1,0x20
 804:	01c85713          	srli	a4,a6,0x1c
 808:	9736                	add	a4,a4,a3
 80a:	fae60de3          	beq	a2,a4,7c4 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061593          	slli	a1,a2,0x20
 818:	01c5d713          	srli	a4,a1,0x1c
 81c:	973e                	add	a4,a4,a5
 81e:	fae68ae3          	beq	a3,a4,7d2 <free+0x24>
    p->s.ptr = bp->s.ptr;
 822:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	7cf73e23          	sd	a5,2012(a4) # 1000 <freep>
}
 82c:	60a2                	ld	ra,8(sp)
 82e:	6402                	ld	s0,0(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret

0000000000000834 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 834:	7139                	addi	sp,sp,-64
 836:	fc06                	sd	ra,56(sp)
 838:	f822                	sd	s0,48(sp)
 83a:	f04a                	sd	s2,32(sp)
 83c:	ec4e                	sd	s3,24(sp)
 83e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051993          	slli	s3,a0,0x20
 844:	0209d993          	srli	s3,s3,0x20
 848:	09bd                	addi	s3,s3,15
 84a:	0049d993          	srli	s3,s3,0x4
 84e:	2985                	addiw	s3,s3,1
 850:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 852:	00000517          	auipc	a0,0x0
 856:	7ae53503          	ld	a0,1966(a0) # 1000 <freep>
 85a:	c905                	beqz	a0,88a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	09377a63          	bgeu	a4,s3,8f4 <malloc+0xc0>
 864:	f426                	sd	s1,40(sp)
 866:	e852                	sd	s4,16(sp)
 868:	e456                	sd	s5,8(sp)
 86a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 86c:	8a4e                	mv	s4,s3
 86e:	6705                	lui	a4,0x1
 870:	00e9f363          	bgeu	s3,a4,876 <malloc+0x42>
 874:	6a05                	lui	s4,0x1
 876:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87e:	00000497          	auipc	s1,0x0
 882:	78248493          	addi	s1,s1,1922 # 1000 <freep>
  if(p == (char*)-1)
 886:	5afd                	li	s5,-1
 888:	a089                	j	8ca <malloc+0x96>
 88a:	f426                	sd	s1,40(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 892:	00000797          	auipc	a5,0x0
 896:	77e78793          	addi	a5,a5,1918 # 1010 <base>
 89a:	00000717          	auipc	a4,0x0
 89e:	76f73323          	sd	a5,1894(a4) # 1000 <freep>
 8a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a8:	b7d1                	j	86c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	e118                	sd	a4,0(a0)
 8ae:	a8b9                	j	90c <malloc+0xd8>
  hp->s.size = nu;
 8b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b4:	0541                	addi	a0,a0,16
 8b6:	00000097          	auipc	ra,0x0
 8ba:	ef8080e7          	jalr	-264(ra) # 7ae <free>
  return freep;
 8be:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8c0:	c135                	beqz	a0,924 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	03277363          	bgeu	a4,s2,8ec <malloc+0xb8>
    if(p == freep)
 8ca:	6098                	ld	a4,0(s1)
 8cc:	853e                	mv	a0,a5
 8ce:	fef71ae3          	bne	a4,a5,8c2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8d2:	8552                	mv	a0,s4
 8d4:	00000097          	auipc	ra,0x0
 8d8:	bae080e7          	jalr	-1106(ra) # 482 <sbrk>
  if(p == (char*)-1)
 8dc:	fd551ae3          	bne	a0,s5,8b0 <malloc+0x7c>
        return 0;
 8e0:	4501                	li	a0,0
 8e2:	74a2                	ld	s1,40(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
 8ea:	a03d                	j	918 <malloc+0xe4>
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8f4:	fae90be3          	beq	s2,a4,8aa <malloc+0x76>
        p->s.size -= nunits;
 8f8:	4137073b          	subw	a4,a4,s3
 8fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fe:	02071693          	slli	a3,a4,0x20
 902:	01c6d713          	srli	a4,a3,0x1c
 906:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 908:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90c:	00000717          	auipc	a4,0x0
 910:	6ea73a23          	sd	a0,1780(a4) # 1000 <freep>
      return (void*)(p + 1);
 914:	01078513          	addi	a0,a5,16
  }
}
 918:	70e2                	ld	ra,56(sp)
 91a:	7442                	ld	s0,48(sp)
 91c:	7902                	ld	s2,32(sp)
 91e:	69e2                	ld	s3,24(sp)
 920:	6121                	addi	sp,sp,64
 922:	8082                	ret
 924:	74a2                	ld	s1,40(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
 92c:	b7f5                	j	918 <malloc+0xe4>
