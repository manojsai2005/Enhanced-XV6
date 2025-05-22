
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NFORK 10
#define IO 5

int main()
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  int n, pid;
  int wtime, rtime;
  int twtime = 0, trtime = 0;
  for (n = 0; n < NFORK; n++)
  12:	4481                	li	s1,0
  14:	4929                	li	s2,10
  {
    pid = fork();
  16:	00000097          	auipc	ra,0x0
  1a:	39e080e7          	jalr	926(ra) # 3b4 <fork>
    if (pid < 0)
  1e:	00054d63          	bltz	a0,38 <main+0x38>
      break;
    if (pid == 0)
  22:	cd31                	beqz	a0,7e <main+0x7e>
  for (n = 0; n < NFORK; n++)
  24:	2485                	addiw	s1,s1,1
  26:	ff2498e3          	bne	s1,s2,16 <main+0x16>
  2a:	4901                	li	s2,0
  2c:	4981                	li	s3,0
      exit(0);
    }
  }
  for (; n > 0; n--)
  {
    if (waitx(0, &wtime, &rtime) >= 0)
  2e:	fb840a93          	addi	s5,s0,-72
  32:	fbc40a13          	addi	s4,s0,-68
  36:	a065                	j	de <main+0xde>
  for (; n > 0; n--)
  38:	fe9049e3          	bgtz	s1,2a <main+0x2a>
  3c:	4901                	li	s2,0
  3e:	4981                	li	s3,0
    {
      trtime += rtime;
      twtime += wtime;
    }
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  40:	666665b7          	lui	a1,0x66666
  44:	66758593          	addi	a1,a1,1639 # 66666667 <base+0x66665657>
  48:	02b98633          	mul	a2,s3,a1
  4c:	9609                	srai	a2,a2,0x22
  4e:	41f9d99b          	sraiw	s3,s3,0x1f
  52:	02b905b3          	mul	a1,s2,a1
  56:	9589                	srai	a1,a1,0x22
  58:	41f9591b          	sraiw	s2,s2,0x1f
  5c:	4136063b          	subw	a2,a2,s3
  60:	412585bb          	subw	a1,a1,s2
  64:	00001517          	auipc	a0,0x1
  68:	8a450513          	addi	a0,a0,-1884 # 908 <malloc+0x112>
  6c:	00000097          	auipc	ra,0x0
  70:	6ce080e7          	jalr	1742(ra) # 73a <printf>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	346080e7          	jalr	838(ra) # 3bc <exit>
      if (n < IO)
  7e:	4791                	li	a5,4
  80:	0497d663          	bge	a5,s1,cc <main+0xcc>
        for (volatile int i = 0; i < 1000000000; i++)
  84:	fa042a23          	sw	zero,-76(s0)
  88:	fb442703          	lw	a4,-76(s0)
  8c:	2701                	sext.w	a4,a4
  8e:	3b9ad7b7          	lui	a5,0x3b9ad
  92:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  96:	00e7cd63          	blt	a5,a4,b0 <main+0xb0>
  9a:	873e                	mv	a4,a5
  9c:	fb442783          	lw	a5,-76(s0)
  a0:	2785                	addiw	a5,a5,1
  a2:	faf42a23          	sw	a5,-76(s0)
  a6:	fb442783          	lw	a5,-76(s0)
  aa:	2781                	sext.w	a5,a5
  ac:	fef758e3          	bge	a4,a5,9c <main+0x9c>
      printf("Process %d finished\n", n);
  b0:	85a6                	mv	a1,s1
  b2:	00001517          	auipc	a0,0x1
  b6:	83e50513          	addi	a0,a0,-1986 # 8f0 <malloc+0xfa>
  ba:	00000097          	auipc	ra,0x0
  be:	680080e7          	jalr	1664(ra) # 73a <printf>
      exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	2f8080e7          	jalr	760(ra) # 3bc <exit>
        sleep(200); // IO bound processes
  cc:	0c800513          	li	a0,200
  d0:	00000097          	auipc	ra,0x0
  d4:	37c080e7          	jalr	892(ra) # 44c <sleep>
  d8:	bfe1                	j	b0 <main+0xb0>
  for (; n > 0; n--)
  da:	34fd                	addiw	s1,s1,-1
  dc:	d0b5                	beqz	s1,40 <main+0x40>
    if (waitx(0, &wtime, &rtime) >= 0)
  de:	8656                	mv	a2,s5
  e0:	85d2                	mv	a1,s4
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	378080e7          	jalr	888(ra) # 45c <waitx>
  ec:	fe0547e3          	bltz	a0,da <main+0xda>
      trtime += rtime;
  f0:	fb842783          	lw	a5,-72(s0)
  f4:	0127893b          	addw	s2,a5,s2
      twtime += wtime;
  f8:	fbc42783          	lw	a5,-68(s0)
  fc:	013789bb          	addw	s3,a5,s3
 100:	bfe9                	j	da <main+0xda>

0000000000000102 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  extern int main();
  main();
 10a:	00000097          	auipc	ra,0x0
 10e:	ef6080e7          	jalr	-266(ra) # 0 <main>
  exit(0);
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	2a8080e7          	jalr	680(ra) # 3bc <exit>

000000000000011c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 124:	87aa                	mv	a5,a0
 126:	0585                	addi	a1,a1,1
 128:	0785                	addi	a5,a5,1
 12a:	fff5c703          	lbu	a4,-1(a1)
 12e:	fee78fa3          	sb	a4,-1(a5)
 132:	fb75                	bnez	a4,126 <strcpy+0xa>
    ;
  return os;
}
 134:	60a2                	ld	ra,8(sp)
 136:	6402                	ld	s0,0(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 144:	00054783          	lbu	a5,0(a0)
 148:	cb91                	beqz	a5,15c <strcmp+0x20>
 14a:	0005c703          	lbu	a4,0(a1)
 14e:	00f71763          	bne	a4,a5,15c <strcmp+0x20>
    p++, q++;
 152:	0505                	addi	a0,a0,1
 154:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 156:	00054783          	lbu	a5,0(a0)
 15a:	fbe5                	bnez	a5,14a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 15c:	0005c503          	lbu	a0,0(a1)
}
 160:	40a7853b          	subw	a0,a5,a0
 164:	60a2                	ld	ra,8(sp)
 166:	6402                	ld	s0,0(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strlen>:

uint
strlen(const char *s)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e406                	sd	ra,8(sp)
 170:	e022                	sd	s0,0(sp)
 172:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf99                	beqz	a5,196 <strlen+0x2a>
 17a:	0505                	addi	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	addi	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x12>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18e:	60a2                	ld	ra,8(sp)
 190:	6402                	ld	s0,0(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret
  for(n = 0; s[n]; n++)
 196:	4501                	li	a0,0
 198:	bfdd                	j	18e <strlen+0x22>

000000000000019a <memset>:

void*
memset(void *dst, int c, uint n)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a2:	ca19                	beqz	a2,1b8 <memset+0x1e>
 1a4:	87aa                	mv	a5,a0
 1a6:	1602                	slli	a2,a2,0x20
 1a8:	9201                	srli	a2,a2,0x20
 1aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b2:	0785                	addi	a5,a5,1
 1b4:	fee79de3          	bne	a5,a4,1ae <memset+0x14>
  }
  return dst;
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strchr>:

char*
strchr(const char *s, char c)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e406                	sd	ra,8(sp)
 1c4:	e022                	sd	s0,0(sp)
 1c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cf81                	beqz	a5,1e4 <strchr+0x24>
    if(*s == c)
 1ce:	00f58763          	beq	a1,a5,1dc <strchr+0x1c>
  for(; *s; s++)
 1d2:	0505                	addi	a0,a0,1
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	fbfd                	bnez	a5,1ce <strchr+0xe>
      return (char*)s;
  return 0;
 1da:	4501                	li	a0,0
}
 1dc:	60a2                	ld	ra,8(sp)
 1de:	6402                	ld	s0,0(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  return 0;
 1e4:	4501                	li	a0,0
 1e6:	bfdd                	j	1dc <strchr+0x1c>

00000000000001e8 <gets>:

char*
gets(char *buf, int max)
{
 1e8:	7159                	addi	sp,sp,-112
 1ea:	f486                	sd	ra,104(sp)
 1ec:	f0a2                	sd	s0,96(sp)
 1ee:	eca6                	sd	s1,88(sp)
 1f0:	e8ca                	sd	s2,80(sp)
 1f2:	e4ce                	sd	s3,72(sp)
 1f4:	e0d2                	sd	s4,64(sp)
 1f6:	fc56                	sd	s5,56(sp)
 1f8:	f85a                	sd	s6,48(sp)
 1fa:	f45e                	sd	s7,40(sp)
 1fc:	f062                	sd	s8,32(sp)
 1fe:	ec66                	sd	s9,24(sp)
 200:	e86a                	sd	s10,16(sp)
 202:	1880                	addi	s0,sp,112
 204:	8caa                	mv	s9,a0
 206:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	892a                	mv	s2,a0
 20a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 20c:	f9f40b13          	addi	s6,s0,-97
 210:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 212:	4ba9                	li	s7,10
 214:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 216:	8d26                	mv	s10,s1
 218:	0014899b          	addiw	s3,s1,1
 21c:	84ce                	mv	s1,s3
 21e:	0349d763          	bge	s3,s4,24c <gets+0x64>
    cc = read(0, &c, 1);
 222:	8656                	mv	a2,s5
 224:	85da                	mv	a1,s6
 226:	4501                	li	a0,0
 228:	00000097          	auipc	ra,0x0
 22c:	1ac080e7          	jalr	428(ra) # 3d4 <read>
    if(cc < 1)
 230:	00a05e63          	blez	a0,24c <gets+0x64>
    buf[i++] = c;
 234:	f9f44783          	lbu	a5,-97(s0)
 238:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 23c:	01778763          	beq	a5,s7,24a <gets+0x62>
 240:	0905                	addi	s2,s2,1
 242:	fd879ae3          	bne	a5,s8,216 <gets+0x2e>
    buf[i++] = c;
 246:	8d4e                	mv	s10,s3
 248:	a011                	j	24c <gets+0x64>
 24a:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 24c:	9d66                	add	s10,s10,s9
 24e:	000d0023          	sb	zero,0(s10)
  return buf;
}
 252:	8566                	mv	a0,s9
 254:	70a6                	ld	ra,104(sp)
 256:	7406                	ld	s0,96(sp)
 258:	64e6                	ld	s1,88(sp)
 25a:	6946                	ld	s2,80(sp)
 25c:	69a6                	ld	s3,72(sp)
 25e:	6a06                	ld	s4,64(sp)
 260:	7ae2                	ld	s5,56(sp)
 262:	7b42                	ld	s6,48(sp)
 264:	7ba2                	ld	s7,40(sp)
 266:	7c02                	ld	s8,32(sp)
 268:	6ce2                	ld	s9,24(sp)
 26a:	6d42                	ld	s10,16(sp)
 26c:	6165                	addi	sp,sp,112
 26e:	8082                	ret

0000000000000270 <stat>:

int
stat(const char *n, struct stat *st)
{
 270:	1101                	addi	sp,sp,-32
 272:	ec06                	sd	ra,24(sp)
 274:	e822                	sd	s0,16(sp)
 276:	e04a                	sd	s2,0(sp)
 278:	1000                	addi	s0,sp,32
 27a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27c:	4581                	li	a1,0
 27e:	00000097          	auipc	ra,0x0
 282:	17e080e7          	jalr	382(ra) # 3fc <open>
  if(fd < 0)
 286:	02054663          	bltz	a0,2b2 <stat+0x42>
 28a:	e426                	sd	s1,8(sp)
 28c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 28e:	85ca                	mv	a1,s2
 290:	00000097          	auipc	ra,0x0
 294:	184080e7          	jalr	388(ra) # 414 <fstat>
 298:	892a                	mv	s2,a0
  close(fd);
 29a:	8526                	mv	a0,s1
 29c:	00000097          	auipc	ra,0x0
 2a0:	148080e7          	jalr	328(ra) # 3e4 <close>
  return r;
 2a4:	64a2                	ld	s1,8(sp)
}
 2a6:	854a                	mv	a0,s2
 2a8:	60e2                	ld	ra,24(sp)
 2aa:	6442                	ld	s0,16(sp)
 2ac:	6902                	ld	s2,0(sp)
 2ae:	6105                	addi	sp,sp,32
 2b0:	8082                	ret
    return -1;
 2b2:	597d                	li	s2,-1
 2b4:	bfcd                	j	2a6 <stat+0x36>

00000000000002b6 <atoi>:

int
atoi(const char *s)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2be:	00054683          	lbu	a3,0(a0)
 2c2:	fd06879b          	addiw	a5,a3,-48
 2c6:	0ff7f793          	zext.b	a5,a5
 2ca:	4625                	li	a2,9
 2cc:	02f66963          	bltu	a2,a5,2fe <atoi+0x48>
 2d0:	872a                	mv	a4,a0
  n = 0;
 2d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2d4:	0705                	addi	a4,a4,1
 2d6:	0025179b          	slliw	a5,a0,0x2
 2da:	9fa9                	addw	a5,a5,a0
 2dc:	0017979b          	slliw	a5,a5,0x1
 2e0:	9fb5                	addw	a5,a5,a3
 2e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e6:	00074683          	lbu	a3,0(a4)
 2ea:	fd06879b          	addiw	a5,a3,-48
 2ee:	0ff7f793          	zext.b	a5,a5
 2f2:	fef671e3          	bgeu	a2,a5,2d4 <atoi+0x1e>
  return n;
}
 2f6:	60a2                	ld	ra,8(sp)
 2f8:	6402                	ld	s0,0(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
  n = 0;
 2fe:	4501                	li	a0,0
 300:	bfdd                	j	2f6 <atoi+0x40>

0000000000000302 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 302:	1141                	addi	sp,sp,-16
 304:	e406                	sd	ra,8(sp)
 306:	e022                	sd	s0,0(sp)
 308:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30a:	02b57563          	bgeu	a0,a1,334 <memmove+0x32>
    while(n-- > 0)
 30e:	00c05f63          	blez	a2,32c <memmove+0x2a>
 312:	1602                	slli	a2,a2,0x20
 314:	9201                	srli	a2,a2,0x20
 316:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31a:	872a                	mv	a4,a0
      *dst++ = *src++;
 31c:	0585                	addi	a1,a1,1
 31e:	0705                	addi	a4,a4,1
 320:	fff5c683          	lbu	a3,-1(a1)
 324:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 328:	fee79ae3          	bne	a5,a4,31c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32c:	60a2                	ld	ra,8(sp)
 32e:	6402                	ld	s0,0(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
    dst += n;
 334:	00c50733          	add	a4,a0,a2
    src += n;
 338:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33a:	fec059e3          	blez	a2,32c <memmove+0x2a>
 33e:	fff6079b          	addiw	a5,a2,-1
 342:	1782                	slli	a5,a5,0x20
 344:	9381                	srli	a5,a5,0x20
 346:	fff7c793          	not	a5,a5
 34a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34c:	15fd                	addi	a1,a1,-1
 34e:	177d                	addi	a4,a4,-1
 350:	0005c683          	lbu	a3,0(a1)
 354:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 358:	fef71ae3          	bne	a4,a5,34c <memmove+0x4a>
 35c:	bfc1                	j	32c <memmove+0x2a>

000000000000035e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 366:	ca0d                	beqz	a2,398 <memcmp+0x3a>
 368:	fff6069b          	addiw	a3,a2,-1
 36c:	1682                	slli	a3,a3,0x20
 36e:	9281                	srli	a3,a3,0x20
 370:	0685                	addi	a3,a3,1
 372:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 374:	00054783          	lbu	a5,0(a0)
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00e79863          	bne	a5,a4,38c <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 380:	0505                	addi	a0,a0,1
    p2++;
 382:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 384:	fed518e3          	bne	a0,a3,374 <memcmp+0x16>
  }
  return 0;
 388:	4501                	li	a0,0
 38a:	a019                	j	390 <memcmp+0x32>
      return *p1 - *p2;
 38c:	40e7853b          	subw	a0,a5,a4
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfdd                	j	390 <memcmp+0x32>

000000000000039c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f5e080e7          	jalr	-162(ra) # 302 <memmove>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b4:	4885                	li	a7,1
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3bc:	4889                	li	a7,2
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c4:	488d                	li	a7,3
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3cc:	4891                	li	a7,4
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <read>:
.global read
read:
 li a7, SYS_read
 3d4:	4895                	li	a7,5
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <write>:
.global write
write:
 li a7, SYS_write
 3dc:	48c1                	li	a7,16
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <close>:
.global close
close:
 li a7, SYS_close
 3e4:	48d5                	li	a7,21
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ec:	4899                	li	a7,6
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f4:	489d                	li	a7,7
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <open>:
.global open
open:
 li a7, SYS_open
 3fc:	48bd                	li	a7,15
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 404:	48c5                	li	a7,17
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40c:	48c9                	li	a7,18
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 414:	48a1                	li	a7,8
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <link>:
.global link
link:
 li a7, SYS_link
 41c:	48cd                	li	a7,19
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 464:	48dd                	li	a7,23
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 46c:	48e1                	li	a7,24
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 474:	48e5                	li	a7,25
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 47c:	48e9                	li	a7,26
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 484:	1101                	addi	sp,sp,-32
 486:	ec06                	sd	ra,24(sp)
 488:	e822                	sd	s0,16(sp)
 48a:	1000                	addi	s0,sp,32
 48c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 490:	4605                	li	a2,1
 492:	fef40593          	addi	a1,s0,-17
 496:	00000097          	auipc	ra,0x0
 49a:	f46080e7          	jalr	-186(ra) # 3dc <write>
}
 49e:	60e2                	ld	ra,24(sp)
 4a0:	6442                	ld	s0,16(sp)
 4a2:	6105                	addi	sp,sp,32
 4a4:	8082                	ret

00000000000004a6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a6:	7139                	addi	sp,sp,-64
 4a8:	fc06                	sd	ra,56(sp)
 4aa:	f822                	sd	s0,48(sp)
 4ac:	f426                	sd	s1,40(sp)
 4ae:	f04a                	sd	s2,32(sp)
 4b0:	ec4e                	sd	s3,24(sp)
 4b2:	0080                	addi	s0,sp,64
 4b4:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b6:	c299                	beqz	a3,4bc <printint+0x16>
 4b8:	0805c063          	bltz	a1,538 <printint+0x92>
  neg = 0;
 4bc:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4be:	fc040313          	addi	t1,s0,-64
  neg = 0;
 4c2:	869a                	mv	a3,t1
  i = 0;
 4c4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4c6:	00000817          	auipc	a6,0x0
 4ca:	4c280813          	addi	a6,a6,1218 # 988 <digits>
 4ce:	88be                	mv	a7,a5
 4d0:	0017851b          	addiw	a0,a5,1
 4d4:	87aa                	mv	a5,a0
 4d6:	02c5f73b          	remuw	a4,a1,a2
 4da:	1702                	slli	a4,a4,0x20
 4dc:	9301                	srli	a4,a4,0x20
 4de:	9742                	add	a4,a4,a6
 4e0:	00074703          	lbu	a4,0(a4)
 4e4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4e8:	872e                	mv	a4,a1
 4ea:	02c5d5bb          	divuw	a1,a1,a2
 4ee:	0685                	addi	a3,a3,1
 4f0:	fcc77fe3          	bgeu	a4,a2,4ce <printint+0x28>
  if(neg)
 4f4:	000e0c63          	beqz	t3,50c <printint+0x66>
    buf[i++] = '-';
 4f8:	fd050793          	addi	a5,a0,-48
 4fc:	00878533          	add	a0,a5,s0
 500:	02d00793          	li	a5,45
 504:	fef50823          	sb	a5,-16(a0)
 508:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 50c:	fff7899b          	addiw	s3,a5,-1
 510:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 514:	fff4c583          	lbu	a1,-1(s1)
 518:	854a                	mv	a0,s2
 51a:	00000097          	auipc	ra,0x0
 51e:	f6a080e7          	jalr	-150(ra) # 484 <putc>
  while(--i >= 0)
 522:	39fd                	addiw	s3,s3,-1
 524:	14fd                	addi	s1,s1,-1
 526:	fe09d7e3          	bgez	s3,514 <printint+0x6e>
}
 52a:	70e2                	ld	ra,56(sp)
 52c:	7442                	ld	s0,48(sp)
 52e:	74a2                	ld	s1,40(sp)
 530:	7902                	ld	s2,32(sp)
 532:	69e2                	ld	s3,24(sp)
 534:	6121                	addi	sp,sp,64
 536:	8082                	ret
    x = -xx;
 538:	40b005bb          	negw	a1,a1
    neg = 1;
 53c:	4e05                	li	t3,1
    x = -xx;
 53e:	b741                	j	4be <printint+0x18>

0000000000000540 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 540:	715d                	addi	sp,sp,-80
 542:	e486                	sd	ra,72(sp)
 544:	e0a2                	sd	s0,64(sp)
 546:	f84a                	sd	s2,48(sp)
 548:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54a:	0005c903          	lbu	s2,0(a1)
 54e:	1a090a63          	beqz	s2,702 <vprintf+0x1c2>
 552:	fc26                	sd	s1,56(sp)
 554:	f44e                	sd	s3,40(sp)
 556:	f052                	sd	s4,32(sp)
 558:	ec56                	sd	s5,24(sp)
 55a:	e85a                	sd	s6,16(sp)
 55c:	e45e                	sd	s7,8(sp)
 55e:	8aaa                	mv	s5,a0
 560:	8bb2                	mv	s7,a2
 562:	00158493          	addi	s1,a1,1
  state = 0;
 566:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 568:	02500a13          	li	s4,37
 56c:	4b55                	li	s6,21
 56e:	a839                	j	58c <vprintf+0x4c>
        putc(fd, c);
 570:	85ca                	mv	a1,s2
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	f10080e7          	jalr	-240(ra) # 484 <putc>
 57c:	a019                	j	582 <vprintf+0x42>
    } else if(state == '%'){
 57e:	01498d63          	beq	s3,s4,598 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 582:	0485                	addi	s1,s1,1
 584:	fff4c903          	lbu	s2,-1(s1)
 588:	16090763          	beqz	s2,6f6 <vprintf+0x1b6>
    if(state == 0){
 58c:	fe0999e3          	bnez	s3,57e <vprintf+0x3e>
      if(c == '%'){
 590:	ff4910e3          	bne	s2,s4,570 <vprintf+0x30>
        state = '%';
 594:	89d2                	mv	s3,s4
 596:	b7f5                	j	582 <vprintf+0x42>
      if(c == 'd'){
 598:	13490463          	beq	s2,s4,6c0 <vprintf+0x180>
 59c:	f9d9079b          	addiw	a5,s2,-99
 5a0:	0ff7f793          	zext.b	a5,a5
 5a4:	12fb6763          	bltu	s6,a5,6d2 <vprintf+0x192>
 5a8:	f9d9079b          	addiw	a5,s2,-99
 5ac:	0ff7f713          	zext.b	a4,a5
 5b0:	12eb6163          	bltu	s6,a4,6d2 <vprintf+0x192>
 5b4:	00271793          	slli	a5,a4,0x2
 5b8:	00000717          	auipc	a4,0x0
 5bc:	37870713          	addi	a4,a4,888 # 930 <malloc+0x13a>
 5c0:	97ba                	add	a5,a5,a4
 5c2:	439c                	lw	a5,0(a5)
 5c4:	97ba                	add	a5,a5,a4
 5c6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4685                	li	a3,1
 5ce:	4629                	li	a2,10
 5d0:	000ba583          	lw	a1,0(s7)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	ed0080e7          	jalr	-304(ra) # 4a6 <printint>
 5de:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b745                	j	582 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e4:	008b8913          	addi	s2,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4629                	li	a2,10
 5ec:	000ba583          	lw	a1,0(s7)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	eb4080e7          	jalr	-332(ra) # 4a6 <printint>
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b751                	j	582 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 600:	008b8913          	addi	s2,s7,8
 604:	4681                	li	a3,0
 606:	4641                	li	a2,16
 608:	000ba583          	lw	a1,0(s7)
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e98080e7          	jalr	-360(ra) # 4a6 <printint>
 616:	8bca                	mv	s7,s2
      state = 0;
 618:	4981                	li	s3,0
 61a:	b7a5                	j	582 <vprintf+0x42>
 61c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 61e:	008b8c13          	addi	s8,s7,8
 622:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 626:	03000593          	li	a1,48
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e58080e7          	jalr	-424(ra) # 484 <putc>
  putc(fd, 'x');
 634:	07800593          	li	a1,120
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e4a080e7          	jalr	-438(ra) # 484 <putc>
 642:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 644:	00000b97          	auipc	s7,0x0
 648:	344b8b93          	addi	s7,s7,836 # 988 <digits>
 64c:	03c9d793          	srli	a5,s3,0x3c
 650:	97de                	add	a5,a5,s7
 652:	0007c583          	lbu	a1,0(a5)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e2c080e7          	jalr	-468(ra) # 484 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 660:	0992                	slli	s3,s3,0x4
 662:	397d                	addiw	s2,s2,-1
 664:	fe0914e3          	bnez	s2,64c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 668:	8be2                	mv	s7,s8
      state = 0;
 66a:	4981                	li	s3,0
 66c:	6c02                	ld	s8,0(sp)
 66e:	bf11                	j	582 <vprintf+0x42>
        s = va_arg(ap, char*);
 670:	008b8993          	addi	s3,s7,8
 674:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 678:	02090163          	beqz	s2,69a <vprintf+0x15a>
        while(*s != 0){
 67c:	00094583          	lbu	a1,0(s2)
 680:	c9a5                	beqz	a1,6f0 <vprintf+0x1b0>
          putc(fd, *s);
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	e00080e7          	jalr	-512(ra) # 484 <putc>
          s++;
 68c:	0905                	addi	s2,s2,1
        while(*s != 0){
 68e:	00094583          	lbu	a1,0(s2)
 692:	f9e5                	bnez	a1,682 <vprintf+0x142>
        s = va_arg(ap, char*);
 694:	8bce                	mv	s7,s3
      state = 0;
 696:	4981                	li	s3,0
 698:	b5ed                	j	582 <vprintf+0x42>
          s = "(null)";
 69a:	00000917          	auipc	s2,0x0
 69e:	28e90913          	addi	s2,s2,654 # 928 <malloc+0x132>
        while(*s != 0){
 6a2:	02800593          	li	a1,40
 6a6:	bff1                	j	682 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	000bc583          	lbu	a1,0(s7)
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	dd2080e7          	jalr	-558(ra) # 484 <putc>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b5d1                	j	582 <vprintf+0x42>
        putc(fd, c);
 6c0:	02500593          	li	a1,37
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	dbe080e7          	jalr	-578(ra) # 484 <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd4d                	j	582 <vprintf+0x42>
        putc(fd, '%');
 6d2:	02500593          	li	a1,37
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	dac080e7          	jalr	-596(ra) # 484 <putc>
        putc(fd, c);
 6e0:	85ca                	mv	a1,s2
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	da0080e7          	jalr	-608(ra) # 484 <putc>
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bd51                	j	582 <vprintf+0x42>
        s = va_arg(ap, char*);
 6f0:	8bce                	mv	s7,s3
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b579                	j	582 <vprintf+0x42>
 6f6:	74e2                	ld	s1,56(sp)
 6f8:	79a2                	ld	s3,40(sp)
 6fa:	7a02                	ld	s4,32(sp)
 6fc:	6ae2                	ld	s5,24(sp)
 6fe:	6b42                	ld	s6,16(sp)
 700:	6ba2                	ld	s7,8(sp)
    }
  }
}
 702:	60a6                	ld	ra,72(sp)
 704:	6406                	ld	s0,64(sp)
 706:	7942                	ld	s2,48(sp)
 708:	6161                	addi	sp,sp,80
 70a:	8082                	ret

000000000000070c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70c:	715d                	addi	sp,sp,-80
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e010                	sd	a2,0(s0)
 716:	e414                	sd	a3,8(s0)
 718:	e818                	sd	a4,16(s0)
 71a:	ec1c                	sd	a5,24(s0)
 71c:	03043023          	sd	a6,32(s0)
 720:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	8622                	mv	a2,s0
 726:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72a:	00000097          	auipc	ra,0x0
 72e:	e16080e7          	jalr	-490(ra) # 540 <vprintf>
}
 732:	60e2                	ld	ra,24(sp)
 734:	6442                	ld	s0,16(sp)
 736:	6161                	addi	sp,sp,80
 738:	8082                	ret

000000000000073a <printf>:

void
printf(const char *fmt, ...)
{
 73a:	711d                	addi	sp,sp,-96
 73c:	ec06                	sd	ra,24(sp)
 73e:	e822                	sd	s0,16(sp)
 740:	1000                	addi	s0,sp,32
 742:	e40c                	sd	a1,8(s0)
 744:	e810                	sd	a2,16(s0)
 746:	ec14                	sd	a3,24(s0)
 748:	f018                	sd	a4,32(s0)
 74a:	f41c                	sd	a5,40(s0)
 74c:	03043823          	sd	a6,48(s0)
 750:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	00840613          	addi	a2,s0,8
 758:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75c:	85aa                	mv	a1,a0
 75e:	4505                	li	a0,1
 760:	00000097          	auipc	ra,0x0
 764:	de0080e7          	jalr	-544(ra) # 540 <vprintf>
}
 768:	60e2                	ld	ra,24(sp)
 76a:	6442                	ld	s0,16(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 770:	1141                	addi	sp,sp,-16
 772:	e406                	sd	ra,8(sp)
 774:	e022                	sd	s0,0(sp)
 776:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	00001797          	auipc	a5,0x1
 780:	8847b783          	ld	a5,-1916(a5) # 1000 <freep>
 784:	a02d                	j	7ae <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 786:	4618                	lw	a4,8(a2)
 788:	9f2d                	addw	a4,a4,a1
 78a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	6398                	ld	a4,0(a5)
 790:	6310                	ld	a2,0(a4)
 792:	a83d                	j	7d0 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 794:	ff852703          	lw	a4,-8(a0)
 798:	9f31                	addw	a4,a4,a2
 79a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79c:	ff053683          	ld	a3,-16(a0)
 7a0:	a091                	j	7e4 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e7e463          	bltu	a5,a4,7ac <free+0x3c>
 7a8:	00e6ea63          	bltu	a3,a4,7bc <free+0x4c>
{
 7ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	fed7fae3          	bgeu	a5,a3,7a2 <free+0x32>
 7b2:	6398                	ld	a4,0(a5)
 7b4:	00e6e463          	bltu	a3,a4,7bc <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b8:	fee7eae3          	bltu	a5,a4,7ac <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7bc:	ff852583          	lw	a1,-8(a0)
 7c0:	6390                	ld	a2,0(a5)
 7c2:	02059813          	slli	a6,a1,0x20
 7c6:	01c85713          	srli	a4,a6,0x1c
 7ca:	9736                	add	a4,a4,a3
 7cc:	fae60de3          	beq	a2,a4,786 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d4:	4790                	lw	a2,8(a5)
 7d6:	02061593          	slli	a1,a2,0x20
 7da:	01c5d713          	srli	a4,a1,0x1c
 7de:	973e                	add	a4,a4,a5
 7e0:	fae68ae3          	beq	a3,a4,794 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
}
 7ee:	60a2                	ld	ra,8(sp)
 7f0:	6402                	ld	s0,0(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret

00000000000007f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f6:	7139                	addi	sp,sp,-64
 7f8:	fc06                	sd	ra,56(sp)
 7fa:	f822                	sd	s0,48(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 802:	02051993          	slli	s3,a0,0x20
 806:	0209d993          	srli	s3,s3,0x20
 80a:	09bd                	addi	s3,s3,15
 80c:	0049d993          	srli	s3,s3,0x4
 810:	2985                	addiw	s3,s3,1
 812:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 814:	00000517          	auipc	a0,0x0
 818:	7ec53503          	ld	a0,2028(a0) # 1000 <freep>
 81c:	c905                	beqz	a0,84c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	09377a63          	bgeu	a4,s3,8b6 <malloc+0xc0>
 826:	f426                	sd	s1,40(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 82e:	8a4e                	mv	s4,s3
 830:	6705                	lui	a4,0x1
 832:	00e9f363          	bgeu	s3,a4,838 <malloc+0x42>
 836:	6a05                	lui	s4,0x1
 838:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 840:	00000497          	auipc	s1,0x0
 844:	7c048493          	addi	s1,s1,1984 # 1000 <freep>
  if(p == (char*)-1)
 848:	5afd                	li	s5,-1
 84a:	a089                	j	88c <malloc+0x96>
 84c:	f426                	sd	s1,40(sp)
 84e:	e852                	sd	s4,16(sp)
 850:	e456                	sd	s5,8(sp)
 852:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 854:	00000797          	auipc	a5,0x0
 858:	7bc78793          	addi	a5,a5,1980 # 1010 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	7af73223          	sd	a5,1956(a4) # 1000 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86a:	b7d1                	j	82e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	e118                	sd	a4,0(a0)
 870:	a8b9                	j	8ce <malloc+0xd8>
  hp->s.size = nu;
 872:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 876:	0541                	addi	a0,a0,16
 878:	00000097          	auipc	ra,0x0
 87c:	ef8080e7          	jalr	-264(ra) # 770 <free>
  return freep;
 880:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 882:	c135                	beqz	a0,8e6 <malloc+0xf0>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	03277363          	bgeu	a4,s2,8ae <malloc+0xb8>
    if(p == freep)
 88c:	6098                	ld	a4,0(s1)
 88e:	853e                	mv	a0,a5
 890:	fef71ae3          	bne	a4,a5,884 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 894:	8552                	mv	a0,s4
 896:	00000097          	auipc	ra,0x0
 89a:	bae080e7          	jalr	-1106(ra) # 444 <sbrk>
  if(p == (char*)-1)
 89e:	fd551ae3          	bne	a0,s5,872 <malloc+0x7c>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	74a2                	ld	s1,40(sp)
 8a6:	6a42                	ld	s4,16(sp)
 8a8:	6aa2                	ld	s5,8(sp)
 8aa:	6b02                	ld	s6,0(sp)
 8ac:	a03d                	j	8da <malloc+0xe4>
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	6a42                	ld	s4,16(sp)
 8b2:	6aa2                	ld	s5,8(sp)
 8b4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b6:	fae90be3          	beq	s2,a4,86c <malloc+0x76>
        p->s.size -= nunits;
 8ba:	4137073b          	subw	a4,a4,s3
 8be:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c0:	02071693          	slli	a3,a4,0x20
 8c4:	01c6d713          	srli	a4,a3,0x1c
 8c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72a73923          	sd	a0,1842(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d6:	01078513          	addi	a0,a5,16
  }
}
 8da:	70e2                	ld	ra,56(sp)
 8dc:	7442                	ld	s0,48(sp)
 8de:	7902                	ld	s2,32(sp)
 8e0:	69e2                	ld	s3,24(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret
 8e6:	74a2                	ld	s1,40(sp)
 8e8:	6a42                	ld	s4,16(sp)
 8ea:	6aa2                	ld	s5,8(sp)
 8ec:	6b02                	ld	s6,0(sp)
 8ee:	b7f5                	j	8da <malloc+0xe4>
