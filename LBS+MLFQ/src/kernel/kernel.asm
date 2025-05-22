
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a4010113          	addi	sp,sp,-1472 # 80008a40 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	00009797          	auipc	a5,0x9
    80000054:	8b078793          	addi	a5,a5,-1872 # 80008900 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	4ae78793          	addi	a5,a5,1198 # 80006510 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd968f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e4278793          	addi	a5,a5,-446 # 80000ef0 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05c63          	blez	a2,80000164 <consolewrite+0x62>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	7d4080e7          	jalr	2004(ra) # 80002908 <either_copyin>
    8000013c:	03550663          	beq	a0,s5,80000168 <consolewrite+0x66>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7da080e7          	jalr	2010(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	894e                	mv	s2,s3
    80000156:	64a6                	ld	s1,72(sp)
    80000158:	79e2                	ld	s3,56(sp)
    8000015a:	7a42                	ld	s4,48(sp)
    8000015c:	7aa2                	ld	s5,40(sp)
    8000015e:	7b02                	ld	s6,32(sp)
    80000160:	6be2                	ld	s7,24(sp)
    80000162:	a809                	j	80000174 <consolewrite+0x72>
    80000164:	4901                	li	s2,0
    80000166:	a039                	j	80000174 <consolewrite+0x72>
    80000168:	64a6                	ld	s1,72(sp)
    8000016a:	79e2                	ld	s3,56(sp)
    8000016c:	7a42                	ld	s4,48(sp)
    8000016e:	7aa2                	ld	s5,40(sp)
    80000170:	7b02                	ld	s6,32(sp)
    80000172:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000174:	854a                	mv	a0,s2
    80000176:	60e6                	ld	ra,88(sp)
    80000178:	6446                	ld	s0,80(sp)
    8000017a:	6906                	ld	s2,64(sp)
    8000017c:	6125                	addi	sp,sp,96
    8000017e:	8082                	ret

0000000080000180 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000180:	711d                	addi	sp,sp,-96
    80000182:	ec86                	sd	ra,88(sp)
    80000184:	e8a2                	sd	s0,80(sp)
    80000186:	e4a6                	sd	s1,72(sp)
    80000188:	e0ca                	sd	s2,64(sp)
    8000018a:	fc4e                	sd	s3,56(sp)
    8000018c:	f852                	sd	s4,48(sp)
    8000018e:	f456                	sd	s5,40(sp)
    80000190:	f05a                	sd	s6,32(sp)
    80000192:	1080                	addi	s0,sp,96
    80000194:	8aaa                	mv	s5,a0
    80000196:	8a2e                	mv	s4,a1
    80000198:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019a:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	8a450513          	addi	a0,a0,-1884 # 80010a40 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	a9a080e7          	jalr	-1382(ra) # 80000c3e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	89448493          	addi	s1,s1,-1900 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00011917          	auipc	s2,0x11
    800001b8:	92490913          	addi	s2,s2,-1756 # 80010ad8 <cons+0x98>
  while(n > 0){
    800001bc:	0d305563          	blez	s3,80000286 <consoleread+0x106>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	0af71a63          	bne	a4,a5,8000027c <consoleread+0xfc>
      if(killed(myproc())){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	89c080e7          	jalr	-1892(ra) # 80001a68 <myproc>
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	568080e7          	jalr	1384(ra) # 8000273c <killed>
    800001dc:	e52d                	bnez	a0,80000246 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001de:	85a6                	mv	a1,s1
    800001e0:	854a                	mv	a0,s2
    800001e2:	00002097          	auipc	ra,0x2
    800001e6:	2a6080e7          	jalr	678(ra) # 80002488 <sleep>
    while(cons.r == cons.w){
    800001ea:	0984a783          	lw	a5,152(s1)
    800001ee:	09c4a703          	lw	a4,156(s1)
    800001f2:	fcf70de3          	beq	a4,a5,800001cc <consoleread+0x4c>
    800001f6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f8:	00011717          	auipc	a4,0x11
    800001fc:	84870713          	addi	a4,a4,-1976 # 80010a40 <cons>
    80000200:	0017869b          	addiw	a3,a5,1
    80000204:	08d72c23          	sw	a3,152(a4)
    80000208:	07f7f693          	andi	a3,a5,127
    8000020c:	9736                	add	a4,a4,a3
    8000020e:	01874703          	lbu	a4,24(a4)
    80000212:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000216:	4691                	li	a3,4
    80000218:	04db8a63          	beq	s7,a3,8000026c <consoleread+0xec>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000021c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000220:	4685                	li	a3,1
    80000222:	faf40613          	addi	a2,s0,-81
    80000226:	85d2                	mv	a1,s4
    80000228:	8556                	mv	a0,s5
    8000022a:	00002097          	auipc	ra,0x2
    8000022e:	688080e7          	jalr	1672(ra) # 800028b2 <either_copyout>
    80000232:	57fd                	li	a5,-1
    80000234:	04f50863          	beq	a0,a5,80000284 <consoleread+0x104>
      break;

    dst++;
    80000238:	0a05                	addi	s4,s4,1
    --n;
    8000023a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000023c:	47a9                	li	a5,10
    8000023e:	04fb8f63          	beq	s7,a5,8000029c <consoleread+0x11c>
    80000242:	6be2                	ld	s7,24(sp)
    80000244:	bfa5                	j	800001bc <consoleread+0x3c>
        release(&cons.lock);
    80000246:	00010517          	auipc	a0,0x10
    8000024a:	7fa50513          	addi	a0,a0,2042 # 80010a40 <cons>
    8000024e:	00001097          	auipc	ra,0x1
    80000252:	aa0080e7          	jalr	-1376(ra) # 80000cee <release>
        return -1;
    80000256:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000258:	60e6                	ld	ra,88(sp)
    8000025a:	6446                	ld	s0,80(sp)
    8000025c:	64a6                	ld	s1,72(sp)
    8000025e:	6906                	ld	s2,64(sp)
    80000260:	79e2                	ld	s3,56(sp)
    80000262:	7a42                	ld	s4,48(sp)
    80000264:	7aa2                	ld	s5,40(sp)
    80000266:	7b02                	ld	s6,32(sp)
    80000268:	6125                	addi	sp,sp,96
    8000026a:	8082                	ret
      if(n < target){
    8000026c:	0169fa63          	bgeu	s3,s6,80000280 <consoleread+0x100>
        cons.r--;
    80000270:	00011717          	auipc	a4,0x11
    80000274:	86f72423          	sw	a5,-1944(a4) # 80010ad8 <cons+0x98>
    80000278:	6be2                	ld	s7,24(sp)
    8000027a:	a031                	j	80000286 <consoleread+0x106>
    8000027c:	ec5e                	sd	s7,24(sp)
    8000027e:	bfad                	j	800001f8 <consoleread+0x78>
    80000280:	6be2                	ld	s7,24(sp)
    80000282:	a011                	j	80000286 <consoleread+0x106>
    80000284:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000286:	00010517          	auipc	a0,0x10
    8000028a:	7ba50513          	addi	a0,a0,1978 # 80010a40 <cons>
    8000028e:	00001097          	auipc	ra,0x1
    80000292:	a60080e7          	jalr	-1440(ra) # 80000cee <release>
  return target - n;
    80000296:	413b053b          	subw	a0,s6,s3
    8000029a:	bf7d                	j	80000258 <consoleread+0xd8>
    8000029c:	6be2                	ld	s7,24(sp)
    8000029e:	b7e5                	j	80000286 <consoleread+0x106>

00000000800002a0 <consputc>:
{
    800002a0:	1141                	addi	sp,sp,-16
    800002a2:	e406                	sd	ra,8(sp)
    800002a4:	e022                	sd	s0,0(sp)
    800002a6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a8:	10000793          	li	a5,256
    800002ac:	00f50a63          	beq	a0,a5,800002c0 <consputc+0x20>
    uartputc_sync(c);
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	590080e7          	jalr	1424(ra) # 80000840 <uartputc_sync>
}
    800002b8:	60a2                	ld	ra,8(sp)
    800002ba:	6402                	ld	s0,0(sp)
    800002bc:	0141                	addi	sp,sp,16
    800002be:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002c0:	4521                	li	a0,8
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	02000513          	li	a0,32
    800002ce:	00000097          	auipc	ra,0x0
    800002d2:	572080e7          	jalr	1394(ra) # 80000840 <uartputc_sync>
    800002d6:	4521                	li	a0,8
    800002d8:	00000097          	auipc	ra,0x0
    800002dc:	568080e7          	jalr	1384(ra) # 80000840 <uartputc_sync>
    800002e0:	bfe1                	j	800002b8 <consputc+0x18>

00000000800002e2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e2:	7179                	addi	sp,sp,-48
    800002e4:	f406                	sd	ra,40(sp)
    800002e6:	f022                	sd	s0,32(sp)
    800002e8:	ec26                	sd	s1,24(sp)
    800002ea:	1800                	addi	s0,sp,48
    800002ec:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ee:	00010517          	auipc	a0,0x10
    800002f2:	75250513          	addi	a0,a0,1874 # 80010a40 <cons>
    800002f6:	00001097          	auipc	ra,0x1
    800002fa:	948080e7          	jalr	-1720(ra) # 80000c3e <acquire>

  switch(c){
    800002fe:	47d5                	li	a5,21
    80000300:	0af48463          	beq	s1,a5,800003a8 <consoleintr+0xc6>
    80000304:	0297c963          	blt	a5,s1,80000336 <consoleintr+0x54>
    80000308:	47a1                	li	a5,8
    8000030a:	10f48063          	beq	s1,a5,8000040a <consoleintr+0x128>
    8000030e:	47c1                	li	a5,16
    80000310:	12f49363          	bne	s1,a5,80000436 <consoleintr+0x154>
  case C('P'):  // Print process list.
    procdump();
    80000314:	00002097          	auipc	ra,0x2
    80000318:	64a080e7          	jalr	1610(ra) # 8000295e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031c:	00010517          	auipc	a0,0x10
    80000320:	72450513          	addi	a0,a0,1828 # 80010a40 <cons>
    80000324:	00001097          	auipc	ra,0x1
    80000328:	9ca080e7          	jalr	-1590(ra) # 80000cee <release>
}
    8000032c:	70a2                	ld	ra,40(sp)
    8000032e:	7402                	ld	s0,32(sp)
    80000330:	64e2                	ld	s1,24(sp)
    80000332:	6145                	addi	sp,sp,48
    80000334:	8082                	ret
  switch(c){
    80000336:	07f00793          	li	a5,127
    8000033a:	0cf48863          	beq	s1,a5,8000040a <consoleintr+0x128>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000033e:	00010717          	auipc	a4,0x10
    80000342:	70270713          	addi	a4,a4,1794 # 80010a40 <cons>
    80000346:	0a072783          	lw	a5,160(a4)
    8000034a:	09872703          	lw	a4,152(a4)
    8000034e:	9f99                	subw	a5,a5,a4
    80000350:	07f00713          	li	a4,127
    80000354:	fcf764e3          	bltu	a4,a5,8000031c <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000358:	47b5                	li	a5,13
    8000035a:	0ef48163          	beq	s1,a5,8000043c <consoleintr+0x15a>
      consputc(c);
    8000035e:	8526                	mv	a0,s1
    80000360:	00000097          	auipc	ra,0x0
    80000364:	f40080e7          	jalr	-192(ra) # 800002a0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000368:	00010797          	auipc	a5,0x10
    8000036c:	6d878793          	addi	a5,a5,1752 # 80010a40 <cons>
    80000370:	0a07a683          	lw	a3,160(a5)
    80000374:	0016871b          	addiw	a4,a3,1
    80000378:	863a                	mv	a2,a4
    8000037a:	0ae7a023          	sw	a4,160(a5)
    8000037e:	07f6f693          	andi	a3,a3,127
    80000382:	97b6                	add	a5,a5,a3
    80000384:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000388:	47a9                	li	a5,10
    8000038a:	0cf48f63          	beq	s1,a5,80000468 <consoleintr+0x186>
    8000038e:	4791                	li	a5,4
    80000390:	0cf48c63          	beq	s1,a5,80000468 <consoleintr+0x186>
    80000394:	00010797          	auipc	a5,0x10
    80000398:	7447a783          	lw	a5,1860(a5) # 80010ad8 <cons+0x98>
    8000039c:	9f1d                	subw	a4,a4,a5
    8000039e:	08000793          	li	a5,128
    800003a2:	f6f71de3          	bne	a4,a5,8000031c <consoleintr+0x3a>
    800003a6:	a0c9                	j	80000468 <consoleintr+0x186>
    800003a8:	e84a                	sd	s2,16(sp)
    800003aa:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    800003ac:	00010717          	auipc	a4,0x10
    800003b0:	69470713          	addi	a4,a4,1684 # 80010a40 <cons>
    800003b4:	0a072783          	lw	a5,160(a4)
    800003b8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003bc:	00010497          	auipc	s1,0x10
    800003c0:	68448493          	addi	s1,s1,1668 # 80010a40 <cons>
    while(cons.e != cons.w &&
    800003c4:	4929                	li	s2,10
      consputc(BACKSPACE);
    800003c6:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    800003ca:	02f70a63          	beq	a4,a5,800003fe <consoleintr+0x11c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ce:	37fd                	addiw	a5,a5,-1
    800003d0:	07f7f713          	andi	a4,a5,127
    800003d4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003d6:	01874703          	lbu	a4,24(a4)
    800003da:	03270563          	beq	a4,s2,80000404 <consoleintr+0x122>
      cons.e--;
    800003de:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003e2:	854e                	mv	a0,s3
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	ebc080e7          	jalr	-324(ra) # 800002a0 <consputc>
    while(cons.e != cons.w &&
    800003ec:	0a04a783          	lw	a5,160(s1)
    800003f0:	09c4a703          	lw	a4,156(s1)
    800003f4:	fcf71de3          	bne	a4,a5,800003ce <consoleintr+0xec>
    800003f8:	6942                	ld	s2,16(sp)
    800003fa:	69a2                	ld	s3,8(sp)
    800003fc:	b705                	j	8000031c <consoleintr+0x3a>
    800003fe:	6942                	ld	s2,16(sp)
    80000400:	69a2                	ld	s3,8(sp)
    80000402:	bf29                	j	8000031c <consoleintr+0x3a>
    80000404:	6942                	ld	s2,16(sp)
    80000406:	69a2                	ld	s3,8(sp)
    80000408:	bf11                	j	8000031c <consoleintr+0x3a>
    if(cons.e != cons.w){
    8000040a:	00010717          	auipc	a4,0x10
    8000040e:	63670713          	addi	a4,a4,1590 # 80010a40 <cons>
    80000412:	0a072783          	lw	a5,160(a4)
    80000416:	09c72703          	lw	a4,156(a4)
    8000041a:	f0f701e3          	beq	a4,a5,8000031c <consoleintr+0x3a>
      cons.e--;
    8000041e:	37fd                	addiw	a5,a5,-1
    80000420:	00010717          	auipc	a4,0x10
    80000424:	6cf72023          	sw	a5,1728(a4) # 80010ae0 <cons+0xa0>
      consputc(BACKSPACE);
    80000428:	10000513          	li	a0,256
    8000042c:	00000097          	auipc	ra,0x0
    80000430:	e74080e7          	jalr	-396(ra) # 800002a0 <consputc>
    80000434:	b5e5                	j	8000031c <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000436:	ee0483e3          	beqz	s1,8000031c <consoleintr+0x3a>
    8000043a:	b711                	j	8000033e <consoleintr+0x5c>
      consputc(c);
    8000043c:	4529                	li	a0,10
    8000043e:	00000097          	auipc	ra,0x0
    80000442:	e62080e7          	jalr	-414(ra) # 800002a0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000446:	00010797          	auipc	a5,0x10
    8000044a:	5fa78793          	addi	a5,a5,1530 # 80010a40 <cons>
    8000044e:	0a07a703          	lw	a4,160(a5)
    80000452:	0017069b          	addiw	a3,a4,1
    80000456:	8636                	mv	a2,a3
    80000458:	0ad7a023          	sw	a3,160(a5)
    8000045c:	07f77713          	andi	a4,a4,127
    80000460:	97ba                	add	a5,a5,a4
    80000462:	4729                	li	a4,10
    80000464:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000468:	00010797          	auipc	a5,0x10
    8000046c:	66c7aa23          	sw	a2,1652(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00010517          	auipc	a0,0x10
    80000474:	66850513          	addi	a0,a0,1640 # 80010ad8 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	074080e7          	jalr	116(ra) # 800024ec <wakeup>
    80000480:	bd71                	j	8000031c <consoleintr+0x3a>

0000000080000482 <consoleinit>:

void
consoleinit(void)
{
    80000482:	1141                	addi	sp,sp,-16
    80000484:	e406                	sd	ra,8(sp)
    80000486:	e022                	sd	s0,0(sp)
    80000488:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000048a:	00008597          	auipc	a1,0x8
    8000048e:	b7658593          	addi	a1,a1,-1162 # 80008000 <etext>
    80000492:	00010517          	auipc	a0,0x10
    80000496:	5ae50513          	addi	a0,a0,1454 # 80010a40 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	710080e7          	jalr	1808(ra) # 80000baa <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	344080e7          	jalr	836(ra) # 800007e6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00024797          	auipc	a5,0x24
    800004ae:	b2e78793          	addi	a5,a5,-1234 # 80023fd8 <devsw>
    800004b2:	00000717          	auipc	a4,0x0
    800004b6:	cce70713          	addi	a4,a4,-818 # 80000180 <consoleread>
    800004ba:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004bc:	00000717          	auipc	a4,0x0
    800004c0:	c4670713          	addi	a4,a4,-954 # 80000102 <consolewrite>
    800004c4:	ef98                	sd	a4,24(a5)
}
    800004c6:	60a2                	ld	ra,8(sp)
    800004c8:	6402                	ld	s0,0(sp)
    800004ca:	0141                	addi	sp,sp,16
    800004cc:	8082                	ret

00000000800004ce <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ce:	7179                	addi	sp,sp,-48
    800004d0:	f406                	sd	ra,40(sp)
    800004d2:	f022                	sd	s0,32(sp)
    800004d4:	ec26                	sd	s1,24(sp)
    800004d6:	e84a                	sd	s2,16(sp)
    800004d8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004da:	c219                	beqz	a2,800004e0 <printint+0x12>
    800004dc:	06054e63          	bltz	a0,80000558 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800004e0:	4e01                	li	t3,0

  i = 0;
    800004e2:	fd040313          	addi	t1,s0,-48
    x = xx;
    800004e6:	869a                	mv	a3,t1
  i = 0;
    800004e8:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800004ea:	00008817          	auipc	a6,0x8
    800004ee:	23e80813          	addi	a6,a6,574 # 80008728 <digits>
    800004f2:	88be                	mv	a7,a5
    800004f4:	0017861b          	addiw	a2,a5,1
    800004f8:	87b2                	mv	a5,a2
    800004fa:	02b5773b          	remuw	a4,a0,a1
    800004fe:	1702                	slli	a4,a4,0x20
    80000500:	9301                	srli	a4,a4,0x20
    80000502:	9742                	add	a4,a4,a6
    80000504:	00074703          	lbu	a4,0(a4)
    80000508:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000050c:	872a                	mv	a4,a0
    8000050e:	02b5553b          	divuw	a0,a0,a1
    80000512:	0685                	addi	a3,a3,1
    80000514:	fcb77fe3          	bgeu	a4,a1,800004f2 <printint+0x24>

  if(sign)
    80000518:	000e0c63          	beqz	t3,80000530 <printint+0x62>
    buf[i++] = '-';
    8000051c:	fe060793          	addi	a5,a2,-32
    80000520:	00878633          	add	a2,a5,s0
    80000524:	02d00793          	li	a5,45
    80000528:	fef60823          	sb	a5,-16(a2)
    8000052c:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    80000530:	fff7891b          	addiw	s2,a5,-1
    80000534:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    80000538:	fff4c503          	lbu	a0,-1(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d64080e7          	jalr	-668(ra) # 800002a0 <consputc>
  while(--i >= 0)
    80000544:	397d                	addiw	s2,s2,-1
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	fe0958e3          	bgez	s2,80000538 <printint+0x6a>
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	64e2                	ld	s1,24(sp)
    80000552:	6942                	ld	s2,16(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4e05                	li	t3,1
    x = -xx;
    8000055e:	b751                	j	800004e2 <printint+0x14>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	5807aa23          	sw	zero,1428(a5) # 80010b00 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	32f72023          	sw	a5,800(a4) # 800088c0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	ec6e                	sd	s11,24(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00010d97          	auipc	s11,0x10
    800005ce:	536dad83          	lw	s11,1334(s11) # 80010b00 <pr+0x18>
  if(locking)
    800005d2:	040d9463          	bnez	s11,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050c63          	beqz	a0,8000077e <printf+0x1d4>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	f06a                	sd	s10,32(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	07800c93          	li	s9,120
    8000060a:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060c:	00008a97          	auipc	s5,0x8
    80000610:	11ca8a93          	addi	s5,s5,284 # 80008728 <digits>
    switch(c){
    80000614:	07300c13          	li	s8,115
    80000618:	a0b9                	j	80000666 <printf+0xbc>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	4ce50513          	addi	a0,a0,1230 # 80010ae8 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	61c080e7          	jalr	1564(ra) # 80000c3e <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c52080e7          	jalr	-942(ra) # 800002a0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	0019879b          	addiw	a5,s3,1
    8000065a:	89be                	mv	s3,a5
    8000065c:	97d2                	add	a5,a5,s4
    8000065e:	0007c503          	lbu	a0,0(a5)
    80000662:	10050563          	beqz	a0,8000076c <printf+0x1c2>
    if(c != '%'){
    80000666:	ff6514e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    8000066a:	0019879b          	addiw	a5,s3,1
    8000066e:	89be                	mv	s3,a5
    80000670:	97d2                	add	a5,a5,s4
    80000672:	0007c783          	lbu	a5,0(a5)
    80000676:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000067a:	10078a63          	beqz	a5,8000078e <printf+0x1e4>
    switch(c){
    8000067e:	05778a63          	beq	a5,s7,800006d2 <printf+0x128>
    80000682:	02fbf463          	bgeu	s7,a5,800006aa <printf+0x100>
    80000686:	09878763          	beq	a5,s8,80000714 <printf+0x16a>
    8000068a:	0d979663          	bne	a5,s9,80000756 <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85ea                	mv	a1,s10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e2e080e7          	jalr	-466(ra) # 800004ce <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	0b678063          	beq	a5,s6,8000074a <printf+0x1a0>
    800006ae:	06400713          	li	a4,100
    800006b2:	0ae79263          	bne	a5,a4,80000756 <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006b6:	f8843783          	ld	a5,-120(s0)
    800006ba:	00878713          	addi	a4,a5,8
    800006be:	f8e43423          	sd	a4,-120(s0)
    800006c2:	4605                	li	a2,1
    800006c4:	45a9                	li	a1,10
    800006c6:	4388                	lw	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	e06080e7          	jalr	-506(ra) # 800004ce <printint>
      break;
    800006d0:	b759                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006d2:	f8843783          	ld	a5,-120(s0)
    800006d6:	00878713          	addi	a4,a5,8
    800006da:	f8e43423          	sd	a4,-120(s0)
    800006de:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006e2:	03000513          	li	a0,48
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	bba080e7          	jalr	-1094(ra) # 800002a0 <consputc>
  consputc('x');
    800006ee:	8566                	mv	a0,s9
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	bb0080e7          	jalr	-1104(ra) # 800002a0 <consputc>
    800006f8:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006fa:	03c95793          	srli	a5,s2,0x3c
    800006fe:	97d6                	add	a5,a5,s5
    80000700:	0007c503          	lbu	a0,0(a5)
    80000704:	00000097          	auipc	ra,0x0
    80000708:	b9c080e7          	jalr	-1124(ra) # 800002a0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0912                	slli	s2,s2,0x4
    8000070e:	34fd                	addiw	s1,s1,-1
    80000710:	f4ed                	bnez	s1,800006fa <printf+0x150>
    80000712:	b791                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000714:	f8843783          	ld	a5,-120(s0)
    80000718:	00878713          	addi	a4,a5,8
    8000071c:	f8e43423          	sd	a4,-120(s0)
    80000720:	6384                	ld	s1,0(a5)
    80000722:	cc89                	beqz	s1,8000073c <printf+0x192>
      for(; *s; s++)
    80000724:	0004c503          	lbu	a0,0(s1)
    80000728:	d51d                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b76080e7          	jalr	-1162(ra) # 800002a0 <consputc>
      for(; *s; s++)
    80000732:	0485                	addi	s1,s1,1
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	f96d                	bnez	a0,8000072a <printf+0x180>
    8000073a:	bf31                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073c:	00008497          	auipc	s1,0x8
    80000740:	8dc48493          	addi	s1,s1,-1828 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000744:	02800513          	li	a0,40
    80000748:	b7cd                	j	8000072a <printf+0x180>
      consputc('%');
    8000074a:	855a                	mv	a0,s6
    8000074c:	00000097          	auipc	ra,0x0
    80000750:	b54080e7          	jalr	-1196(ra) # 800002a0 <consputc>
      break;
    80000754:	b709                	j	80000656 <printf+0xac>
      consputc('%');
    80000756:	855a                	mv	a0,s6
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	b48080e7          	jalr	-1208(ra) # 800002a0 <consputc>
      consputc(c);
    80000760:	8526                	mv	a0,s1
    80000762:	00000097          	auipc	ra,0x0
    80000766:	b3e080e7          	jalr	-1218(ra) # 800002a0 <consputc>
      break;
    8000076a:	b5f5                	j	80000656 <printf+0xac>
    8000076c:	74a6                	ld	s1,104(sp)
    8000076e:	7906                	ld	s2,96(sp)
    80000770:	69e6                	ld	s3,88(sp)
    80000772:	6aa6                	ld	s5,72(sp)
    80000774:	6b06                	ld	s6,64(sp)
    80000776:	7be2                	ld	s7,56(sp)
    80000778:	7c42                	ld	s8,48(sp)
    8000077a:	7ca2                	ld	s9,40(sp)
    8000077c:	7d02                	ld	s10,32(sp)
  if(locking)
    8000077e:	020d9263          	bnez	s11,800007a2 <printf+0x1f8>
}
    80000782:	70e6                	ld	ra,120(sp)
    80000784:	7446                	ld	s0,112(sp)
    80000786:	6a46                	ld	s4,80(sp)
    80000788:	6de2                	ld	s11,24(sp)
    8000078a:	6129                	addi	sp,sp,192
    8000078c:	8082                	ret
    8000078e:	74a6                	ld	s1,104(sp)
    80000790:	7906                	ld	s2,96(sp)
    80000792:	69e6                	ld	s3,88(sp)
    80000794:	6aa6                	ld	s5,72(sp)
    80000796:	6b06                	ld	s6,64(sp)
    80000798:	7be2                	ld	s7,56(sp)
    8000079a:	7c42                	ld	s8,48(sp)
    8000079c:	7ca2                	ld	s9,40(sp)
    8000079e:	7d02                	ld	s10,32(sp)
    800007a0:	bff9                	j	8000077e <printf+0x1d4>
    release(&pr.lock);
    800007a2:	00010517          	auipc	a0,0x10
    800007a6:	34650513          	addi	a0,a0,838 # 80010ae8 <pr>
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	544080e7          	jalr	1348(ra) # 80000cee <release>
}
    800007b2:	bfc1                	j	80000782 <printf+0x1d8>

00000000800007b4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b4:	1101                	addi	sp,sp,-32
    800007b6:	ec06                	sd	ra,24(sp)
    800007b8:	e822                	sd	s0,16(sp)
    800007ba:	e426                	sd	s1,8(sp)
    800007bc:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007be:	00010497          	auipc	s1,0x10
    800007c2:	32a48493          	addi	s1,s1,810 # 80010ae8 <pr>
    800007c6:	00008597          	auipc	a1,0x8
    800007ca:	86a58593          	addi	a1,a1,-1942 # 80008030 <etext+0x30>
    800007ce:	8526                	mv	a0,s1
    800007d0:	00000097          	auipc	ra,0x0
    800007d4:	3da080e7          	jalr	986(ra) # 80000baa <initlock>
  pr.locking = 1;
    800007d8:	4785                	li	a5,1
    800007da:	cc9c                	sw	a5,24(s1)
}
    800007dc:	60e2                	ld	ra,24(sp)
    800007de:	6442                	ld	s0,16(sp)
    800007e0:	64a2                	ld	s1,8(sp)
    800007e2:	6105                	addi	sp,sp,32
    800007e4:	8082                	ret

00000000800007e6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e6:	1141                	addi	sp,sp,-16
    800007e8:	e406                	sd	ra,8(sp)
    800007ea:	e022                	sd	s0,0(sp)
    800007ec:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ee:	100007b7          	lui	a5,0x10000
    800007f2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f6:	10000737          	lui	a4,0x10000
    800007fa:	f8000693          	li	a3,-128
    800007fe:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000802:	468d                	li	a3,3
    80000804:	10000637          	lui	a2,0x10000
    80000808:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000810:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000814:	8732                	mv	a4,a2
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	2e050513          	addi	a0,a0,736 # 80010b08 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	37a080e7          	jalr	890(ra) # 80000baa <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a6080e7          	jalr	934(ra) # 80000bf2 <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	06c7a783          	lw	a5,108(a5) # 800088c0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	418080e7          	jalr	1048(ra) # 80000c92 <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	03a7b783          	ld	a5,58(a5) # 800088c8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	03a73703          	ld	a4,58(a4) # 800088d0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	24ca8a93          	addi	s5,s5,588 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	00448493          	addi	s1,s1,4 # 800088c8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	00098993          	mv	s3,s3
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	bfa080e7          	jalr	-1030(ra) # 800024ec <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3) # 800088d0 <uart_tx_w>
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00010517          	auipc	a0,0x10
    80000934:	1d850513          	addi	a0,a0,472 # 80010b08 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	306080e7          	jalr	774(ra) # 80000c3e <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	f807a783          	lw	a5,-128(a5) # 800088c0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	f8673703          	ld	a4,-122(a4) # 800088d0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	f767b783          	ld	a5,-138(a5) # 800088c8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	1aa98993          	addi	s3,s3,426 # 80010b08 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	f6248493          	addi	s1,s1,-158 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	f6290913          	addi	s2,s2,-158 # 800088d0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	b0a080e7          	jalr	-1270(ra) # 80002488 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	17448493          	addi	s1,s1,372 # 80010b08 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f2e7b423          	sd	a4,-216(a5) # 800088d0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	334080e7          	jalr	820(ra) # 80000cee <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e406                	sd	ra,8(sp)
    800009d8:	e022                	sd	s0,0(sp)
    800009da:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009dc:	100007b7          	lui	a5,0x10000
    800009e0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb89                	beqz	a5,800009f8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	60a2                	ld	ra,8(sp)
    800009f2:	6402                	ld	s0,0(sp)
    800009f4:	0141                	addi	sp,sp,16
    800009f6:	8082                	ret
    return -1;
    800009f8:	557d                	li	a0,-1
    800009fa:	bfdd                	j	800009f0 <uartgetc+0x1c>

00000000800009fc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fc:	1101                	addi	sp,sp,-32
    800009fe:	ec06                	sd	ra,24(sp)
    80000a00:	e822                	sd	s0,16(sp)
    80000a02:	e426                	sd	s1,8(sp)
    80000a04:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a06:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	fcc080e7          	jalr	-52(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a10:	00950763          	beq	a0,s1,80000a1e <uartintr+0x22>
      break;
    consoleintr(c);
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	8ce080e7          	jalr	-1842(ra) # 800002e2 <consoleintr>
  while(1){
    80000a1c:	b7f5                	j	80000a08 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1e:	00010497          	auipc	s1,0x10
    80000a22:	0ea48493          	addi	s1,s1,234 # 80010b08 <uart_tx_lock>
    80000a26:	8526                	mv	a0,s1
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	216080e7          	jalr	534(ra) # 80000c3e <acquire>
  uartstart();
    80000a30:	00000097          	auipc	ra,0x0
    80000a34:	e5e080e7          	jalr	-418(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	2b4080e7          	jalr	692(ra) # 80000cee <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret

0000000080000a4c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	e04a                	sd	s2,0(sp)
    80000a56:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a58:	03451793          	slli	a5,a0,0x34
    80000a5c:	ebb9                	bnez	a5,80000ab2 <kfree+0x66>
    80000a5e:	84aa                	mv	s1,a0
    80000a60:	00024797          	auipc	a5,0x24
    80000a64:	71078793          	addi	a5,a5,1808 # 80025170 <end>
    80000a68:	04f56563          	bltu	a0,a5,80000ab2 <kfree+0x66>
    80000a6c:	47c5                	li	a5,17
    80000a6e:	07ee                	slli	a5,a5,0x1b
    80000a70:	04f57163          	bgeu	a0,a5,80000ab2 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a74:	6605                	lui	a2,0x1
    80000a76:	4585                	li	a1,1
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	2be080e7          	jalr	702(ra) # 80000d36 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a80:	00010917          	auipc	s2,0x10
    80000a84:	0c090913          	addi	s2,s2,192 # 80010b40 <kmem>
    80000a88:	854a                	mv	a0,s2
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	1b4080e7          	jalr	436(ra) # 80000c3e <acquire>
  r->next = kmem.freelist;
    80000a92:	01893783          	ld	a5,24(s2)
    80000a96:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a98:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9c:	854a                	mv	a0,s2
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	250080e7          	jalr	592(ra) # 80000cee <release>
}
    80000aa6:	60e2                	ld	ra,24(sp)
    80000aa8:	6442                	ld	s0,16(sp)
    80000aaa:	64a2                	ld	s1,8(sp)
    80000aac:	6902                	ld	s2,0(sp)
    80000aae:	6105                	addi	sp,sp,32
    80000ab0:	8082                	ret
    panic("kfree");
    80000ab2:	00007517          	auipc	a0,0x7
    80000ab6:	58e50513          	addi	a0,a0,1422 # 80008040 <etext+0x40>
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	aa6080e7          	jalr	-1370(ra) # 80000560 <panic>

0000000080000ac2 <freerange>:
{
    80000ac2:	7179                	addi	sp,sp,-48
    80000ac4:	f406                	sd	ra,40(sp)
    80000ac6:	f022                	sd	s0,32(sp)
    80000ac8:	ec26                	sd	s1,24(sp)
    80000aca:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000acc:	6785                	lui	a5,0x1
    80000ace:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad2:	00e504b3          	add	s1,a0,a4
    80000ad6:	777d                	lui	a4,0xfffff
    80000ad8:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94be                	add	s1,s1,a5
    80000adc:	0295e463          	bltu	a1,s1,80000b04 <freerange+0x42>
    80000ae0:	e84a                	sd	s2,16(sp)
    80000ae2:	e44e                	sd	s3,8(sp)
    80000ae4:	e052                	sd	s4,0(sp)
    80000ae6:	892e                	mv	s2,a1
    kfree(p);
    80000ae8:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aea:	89be                	mv	s3,a5
    kfree(p);
    80000aec:	01448533          	add	a0,s1,s4
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	f5c080e7          	jalr	-164(ra) # 80000a4c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	94ce                	add	s1,s1,s3
    80000afa:	fe9979e3          	bgeu	s2,s1,80000aec <freerange+0x2a>
    80000afe:	6942                	ld	s2,16(sp)
    80000b00:	69a2                	ld	s3,8(sp)
    80000b02:	6a02                	ld	s4,0(sp)
}
    80000b04:	70a2                	ld	ra,40(sp)
    80000b06:	7402                	ld	s0,32(sp)
    80000b08:	64e2                	ld	s1,24(sp)
    80000b0a:	6145                	addi	sp,sp,48
    80000b0c:	8082                	ret

0000000080000b0e <kinit>:
{
    80000b0e:	1141                	addi	sp,sp,-16
    80000b10:	e406                	sd	ra,8(sp)
    80000b12:	e022                	sd	s0,0(sp)
    80000b14:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b16:	00007597          	auipc	a1,0x7
    80000b1a:	53258593          	addi	a1,a1,1330 # 80008048 <etext+0x48>
    80000b1e:	00010517          	auipc	a0,0x10
    80000b22:	02250513          	addi	a0,a0,34 # 80010b40 <kmem>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	084080e7          	jalr	132(ra) # 80000baa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2e:	45c5                	li	a1,17
    80000b30:	05ee                	slli	a1,a1,0x1b
    80000b32:	00024517          	auipc	a0,0x24
    80000b36:	63e50513          	addi	a0,a0,1598 # 80025170 <end>
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	f88080e7          	jalr	-120(ra) # 80000ac2 <freerange>
}
    80000b42:	60a2                	ld	ra,8(sp)
    80000b44:	6402                	ld	s0,0(sp)
    80000b46:	0141                	addi	sp,sp,16
    80000b48:	8082                	ret

0000000080000b4a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b4a:	1101                	addi	sp,sp,-32
    80000b4c:	ec06                	sd	ra,24(sp)
    80000b4e:	e822                	sd	s0,16(sp)
    80000b50:	e426                	sd	s1,8(sp)
    80000b52:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b54:	00010497          	auipc	s1,0x10
    80000b58:	fec48493          	addi	s1,s1,-20 # 80010b40 <kmem>
    80000b5c:	8526                	mv	a0,s1
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	0e0080e7          	jalr	224(ra) # 80000c3e <acquire>
  r = kmem.freelist;
    80000b66:	6c84                	ld	s1,24(s1)
  if(r)
    80000b68:	c885                	beqz	s1,80000b98 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b6a:	609c                	ld	a5,0(s1)
    80000b6c:	00010517          	auipc	a0,0x10
    80000b70:	fd450513          	addi	a0,a0,-44 # 80010b40 <kmem>
    80000b74:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	178080e7          	jalr	376(ra) # 80000cee <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7e:	6605                	lui	a2,0x1
    80000b80:	4595                	li	a1,5
    80000b82:	8526                	mv	a0,s1
    80000b84:	00000097          	auipc	ra,0x0
    80000b88:	1b2080e7          	jalr	434(ra) # 80000d36 <memset>
  return (void*)r;
}
    80000b8c:	8526                	mv	a0,s1
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret
  release(&kmem.lock);
    80000b98:	00010517          	auipc	a0,0x10
    80000b9c:	fa850513          	addi	a0,a0,-88 # 80010b40 <kmem>
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	14e080e7          	jalr	334(ra) # 80000cee <release>
  if(r)
    80000ba8:	b7d5                	j	80000b8c <kalloc+0x42>

0000000080000baa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000baa:	1141                	addi	sp,sp,-16
    80000bac:	e406                	sd	ra,8(sp)
    80000bae:	e022                	sd	s0,0(sp)
    80000bb0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bb2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb8:	00053823          	sd	zero,16(a0)
}
    80000bbc:	60a2                	ld	ra,8(sp)
    80000bbe:	6402                	ld	s0,0(sp)
    80000bc0:	0141                	addi	sp,sp,16
    80000bc2:	8082                	ret

0000000080000bc4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bc4:	411c                	lw	a5,0(a0)
    80000bc6:	e399                	bnez	a5,80000bcc <holding+0x8>
    80000bc8:	4501                	li	a0,0
  return r;
}
    80000bca:	8082                	ret
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd6:	6904                	ld	s1,16(a0)
    80000bd8:	00001097          	auipc	ra,0x1
    80000bdc:	e70080e7          	jalr	-400(ra) # 80001a48 <mycpu>
    80000be0:	40a48533          	sub	a0,s1,a0
    80000be4:	00153513          	seqz	a0,a0
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret

0000000080000bf2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bf2:	1101                	addi	sp,sp,-32
    80000bf4:	ec06                	sd	ra,24(sp)
    80000bf6:	e822                	sd	s0,16(sp)
    80000bf8:	e426                	sd	s1,8(sp)
    80000bfa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bfc:	100024f3          	csrr	s1,sstatus
    80000c00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c06:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	e3e080e7          	jalr	-450(ra) # 80001a48 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	cf89                	beqz	a5,80000c2e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c16:	00001097          	auipc	ra,0x1
    80000c1a:	e32080e7          	jalr	-462(ra) # 80001a48 <mycpu>
    80000c1e:	5d3c                	lw	a5,120(a0)
    80000c20:	2785                	addiw	a5,a5,1
    80000c22:	dd3c                	sw	a5,120(a0)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    mycpu()->intena = old;
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	e1a080e7          	jalr	-486(ra) # 80001a48 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c36:	8085                	srli	s1,s1,0x1
    80000c38:	8885                	andi	s1,s1,1
    80000c3a:	dd64                	sw	s1,124(a0)
    80000c3c:	bfe9                	j	80000c16 <push_off+0x24>

0000000080000c3e <acquire>:
{
    80000c3e:	1101                	addi	sp,sp,-32
    80000c40:	ec06                	sd	ra,24(sp)
    80000c42:	e822                	sd	s0,16(sp)
    80000c44:	e426                	sd	s1,8(sp)
    80000c46:	1000                	addi	s0,sp,32
    80000c48:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	fa8080e7          	jalr	-88(ra) # 80000bf2 <push_off>
  if(holding(lk))
    80000c52:	8526                	mv	a0,s1
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	f70080e7          	jalr	-144(ra) # 80000bc4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5c:	4705                	li	a4,1
  if(holding(lk))
    80000c5e:	e115                	bnez	a0,80000c82 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c60:	87ba                	mv	a5,a4
    80000c62:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c66:	2781                	sext.w	a5,a5
    80000c68:	ffe5                	bnez	a5,80000c60 <acquire+0x22>
  __sync_synchronize();
    80000c6a:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c6e:	00001097          	auipc	ra,0x1
    80000c72:	dda080e7          	jalr	-550(ra) # 80001a48 <mycpu>
    80000c76:	e888                	sd	a0,16(s1)
}
    80000c78:	60e2                	ld	ra,24(sp)
    80000c7a:	6442                	ld	s0,16(sp)
    80000c7c:	64a2                	ld	s1,8(sp)
    80000c7e:	6105                	addi	sp,sp,32
    80000c80:	8082                	ret
    panic("acquire");
    80000c82:	00007517          	auipc	a0,0x7
    80000c86:	3ce50513          	addi	a0,a0,974 # 80008050 <etext+0x50>
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	8d6080e7          	jalr	-1834(ra) # 80000560 <panic>

0000000080000c92 <pop_off>:

void
pop_off(void)
{
    80000c92:	1141                	addi	sp,sp,-16
    80000c94:	e406                	sd	ra,8(sp)
    80000c96:	e022                	sd	s0,0(sp)
    80000c98:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c9a:	00001097          	auipc	ra,0x1
    80000c9e:	dae080e7          	jalr	-594(ra) # 80001a48 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ca2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca6:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca8:	e39d                	bnez	a5,80000cce <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000caa:	5d3c                	lw	a5,120(a0)
    80000cac:	02f05963          	blez	a5,80000cde <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cb0:	37fd                	addiw	a5,a5,-1
    80000cb2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb4:	eb89                	bnez	a5,80000cc6 <pop_off+0x34>
    80000cb6:	5d7c                	lw	a5,124(a0)
    80000cb8:	c799                	beqz	a5,80000cc6 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc6:	60a2                	ld	ra,8(sp)
    80000cc8:	6402                	ld	s0,0(sp)
    80000cca:	0141                	addi	sp,sp,16
    80000ccc:	8082                	ret
    panic("pop_off - interruptible");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	38a50513          	addi	a0,a0,906 # 80008058 <etext+0x58>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	88a080e7          	jalr	-1910(ra) # 80000560 <panic>
    panic("pop_off");
    80000cde:	00007517          	auipc	a0,0x7
    80000ce2:	39250513          	addi	a0,a0,914 # 80008070 <etext+0x70>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	87a080e7          	jalr	-1926(ra) # 80000560 <panic>

0000000080000cee <release>:
{
    80000cee:	1101                	addi	sp,sp,-32
    80000cf0:	ec06                	sd	ra,24(sp)
    80000cf2:	e822                	sd	s0,16(sp)
    80000cf4:	e426                	sd	s1,8(sp)
    80000cf6:	1000                	addi	s0,sp,32
    80000cf8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	eca080e7          	jalr	-310(ra) # 80000bc4 <holding>
    80000d02:	c115                	beqz	a0,80000d26 <release+0x38>
  lk->cpu = 0;
    80000d04:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d08:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d0c:	0310000f          	fence	rw,w
    80000d10:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d14:	00000097          	auipc	ra,0x0
    80000d18:	f7e080e7          	jalr	-130(ra) # 80000c92 <pop_off>
}
    80000d1c:	60e2                	ld	ra,24(sp)
    80000d1e:	6442                	ld	s0,16(sp)
    80000d20:	64a2                	ld	s1,8(sp)
    80000d22:	6105                	addi	sp,sp,32
    80000d24:	8082                	ret
    panic("release");
    80000d26:	00007517          	auipc	a0,0x7
    80000d2a:	35250513          	addi	a0,a0,850 # 80008078 <etext+0x78>
    80000d2e:	00000097          	auipc	ra,0x0
    80000d32:	832080e7          	jalr	-1998(ra) # 80000560 <panic>

0000000080000d36 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d36:	1141                	addi	sp,sp,-16
    80000d38:	e406                	sd	ra,8(sp)
    80000d3a:	e022                	sd	s0,0(sp)
    80000d3c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3e:	ca19                	beqz	a2,80000d54 <memset+0x1e>
    80000d40:	87aa                	mv	a5,a0
    80000d42:	1602                	slli	a2,a2,0x20
    80000d44:	9201                	srli	a2,a2,0x20
    80000d46:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d4a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4e:	0785                	addi	a5,a5,1
    80000d50:	fee79de3          	bne	a5,a4,80000d4a <memset+0x14>
  }
  return dst;
}
    80000d54:	60a2                	ld	ra,8(sp)
    80000d56:	6402                	ld	s0,0(sp)
    80000d58:	0141                	addi	sp,sp,16
    80000d5a:	8082                	ret

0000000080000d5c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d5c:	1141                	addi	sp,sp,-16
    80000d5e:	e406                	sd	ra,8(sp)
    80000d60:	e022                	sd	s0,0(sp)
    80000d62:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d64:	ca0d                	beqz	a2,80000d96 <memcmp+0x3a>
    80000d66:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d6a:	1682                	slli	a3,a3,0x20
    80000d6c:	9281                	srli	a3,a3,0x20
    80000d6e:	0685                	addi	a3,a3,1
    80000d70:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d72:	00054783          	lbu	a5,0(a0)
    80000d76:	0005c703          	lbu	a4,0(a1)
    80000d7a:	00e79863          	bne	a5,a4,80000d8a <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d7e:	0505                	addi	a0,a0,1
    80000d80:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d82:	fed518e3          	bne	a0,a3,80000d72 <memcmp+0x16>
  }

  return 0;
    80000d86:	4501                	li	a0,0
    80000d88:	a019                	j	80000d8e <memcmp+0x32>
      return *s1 - *s2;
    80000d8a:	40e7853b          	subw	a0,a5,a4
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret
  return 0;
    80000d96:	4501                	li	a0,0
    80000d98:	bfdd                	j	80000d8e <memcmp+0x32>

0000000080000d9a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e406                	sd	ra,8(sp)
    80000d9e:	e022                	sd	s0,0(sp)
    80000da0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000da2:	c205                	beqz	a2,80000dc2 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da4:	02a5e363          	bltu	a1,a0,80000dca <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000da8:	1602                	slli	a2,a2,0x20
    80000daa:	9201                	srli	a2,a2,0x20
    80000dac:	00c587b3          	add	a5,a1,a2
{
    80000db0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000db2:	0585                	addi	a1,a1,1
    80000db4:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9e91>
    80000db6:	fff5c683          	lbu	a3,-1(a1)
    80000dba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dbe:	feb79ae3          	bne	a5,a1,80000db2 <memmove+0x18>

  return dst;
}
    80000dc2:	60a2                	ld	ra,8(sp)
    80000dc4:	6402                	ld	s0,0(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret
  if(s < d && s + n > d){
    80000dca:	02061693          	slli	a3,a2,0x20
    80000dce:	9281                	srli	a3,a3,0x20
    80000dd0:	00d58733          	add	a4,a1,a3
    80000dd4:	fce57ae3          	bgeu	a0,a4,80000da8 <memmove+0xe>
    d += n;
    80000dd8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dda:	fff6079b          	addiw	a5,a2,-1
    80000dde:	1782                	slli	a5,a5,0x20
    80000de0:	9381                	srli	a5,a5,0x20
    80000de2:	fff7c793          	not	a5,a5
    80000de6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000de8:	177d                	addi	a4,a4,-1
    80000dea:	16fd                	addi	a3,a3,-1
    80000dec:	00074603          	lbu	a2,0(a4)
    80000df0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000df4:	fee79ae3          	bne	a5,a4,80000de8 <memmove+0x4e>
    80000df8:	b7e9                	j	80000dc2 <memmove+0x28>

0000000080000dfa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e406                	sd	ra,8(sp)
    80000dfe:	e022                	sd	s0,0(sp)
    80000e00:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e02:	00000097          	auipc	ra,0x0
    80000e06:	f98080e7          	jalr	-104(ra) # 80000d9a <memmove>
}
    80000e0a:	60a2                	ld	ra,8(sp)
    80000e0c:	6402                	ld	s0,0(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e406                	sd	ra,8(sp)
    80000e16:	e022                	sd	s0,0(sp)
    80000e18:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e1a:	ce11                	beqz	a2,80000e36 <strncmp+0x24>
    80000e1c:	00054783          	lbu	a5,0(a0)
    80000e20:	cf89                	beqz	a5,80000e3a <strncmp+0x28>
    80000e22:	0005c703          	lbu	a4,0(a1)
    80000e26:	00f71a63          	bne	a4,a5,80000e3a <strncmp+0x28>
    n--, p++, q++;
    80000e2a:	367d                	addiw	a2,a2,-1
    80000e2c:	0505                	addi	a0,a0,1
    80000e2e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e30:	f675                	bnez	a2,80000e1c <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e32:	4501                	li	a0,0
    80000e34:	a801                	j	80000e44 <strncmp+0x32>
    80000e36:	4501                	li	a0,0
    80000e38:	a031                	j	80000e44 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e3a:	00054503          	lbu	a0,0(a0)
    80000e3e:	0005c783          	lbu	a5,0(a1)
    80000e42:	9d1d                	subw	a0,a0,a5
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e54:	87aa                	mv	a5,a0
    80000e56:	86b2                	mv	a3,a2
    80000e58:	367d                	addiw	a2,a2,-1
    80000e5a:	02d05563          	blez	a3,80000e84 <strncpy+0x38>
    80000e5e:	0785                	addi	a5,a5,1
    80000e60:	0005c703          	lbu	a4,0(a1)
    80000e64:	fee78fa3          	sb	a4,-1(a5)
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	f775                	bnez	a4,80000e56 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e6c:	873e                	mv	a4,a5
    80000e6e:	00c05b63          	blez	a2,80000e84 <strncpy+0x38>
    80000e72:	9fb5                	addw	a5,a5,a3
    80000e74:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e76:	0705                	addi	a4,a4,1
    80000e78:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e7c:	40e786bb          	subw	a3,a5,a4
    80000e80:	fed04be3          	bgtz	a3,80000e76 <strncpy+0x2a>
  return os;
}
    80000e84:	60a2                	ld	ra,8(sp)
    80000e86:	6402                	ld	s0,0(sp)
    80000e88:	0141                	addi	sp,sp,16
    80000e8a:	8082                	ret

0000000080000e8c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e406                	sd	ra,8(sp)
    80000e90:	e022                	sd	s0,0(sp)
    80000e92:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e94:	02c05363          	blez	a2,80000eba <safestrcpy+0x2e>
    80000e98:	fff6069b          	addiw	a3,a2,-1
    80000e9c:	1682                	slli	a3,a3,0x20
    80000e9e:	9281                	srli	a3,a3,0x20
    80000ea0:	96ae                	add	a3,a3,a1
    80000ea2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ea4:	00d58963          	beq	a1,a3,80000eb6 <safestrcpy+0x2a>
    80000ea8:	0585                	addi	a1,a1,1
    80000eaa:	0785                	addi	a5,a5,1
    80000eac:	fff5c703          	lbu	a4,-1(a1)
    80000eb0:	fee78fa3          	sb	a4,-1(a5)
    80000eb4:	fb65                	bnez	a4,80000ea4 <safestrcpy+0x18>
    ;
  *s = 0;
    80000eb6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eba:	60a2                	ld	ra,8(sp)
    80000ebc:	6402                	ld	s0,0(sp)
    80000ebe:	0141                	addi	sp,sp,16
    80000ec0:	8082                	ret

0000000080000ec2 <strlen>:

int
strlen(const char *s)
{
    80000ec2:	1141                	addi	sp,sp,-16
    80000ec4:	e406                	sd	ra,8(sp)
    80000ec6:	e022                	sd	s0,0(sp)
    80000ec8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eca:	00054783          	lbu	a5,0(a0)
    80000ece:	cf99                	beqz	a5,80000eec <strlen+0x2a>
    80000ed0:	0505                	addi	a0,a0,1
    80000ed2:	87aa                	mv	a5,a0
    80000ed4:	86be                	mv	a3,a5
    80000ed6:	0785                	addi	a5,a5,1
    80000ed8:	fff7c703          	lbu	a4,-1(a5)
    80000edc:	ff65                	bnez	a4,80000ed4 <strlen+0x12>
    80000ede:	40a6853b          	subw	a0,a3,a0
    80000ee2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ee4:	60a2                	ld	ra,8(sp)
    80000ee6:	6402                	ld	s0,0(sp)
    80000ee8:	0141                	addi	sp,sp,16
    80000eea:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eec:	4501                	li	a0,0
    80000eee:	bfdd                	j	80000ee4 <strlen+0x22>

0000000080000ef0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef0:	1141                	addi	sp,sp,-16
    80000ef2:	e406                	sd	ra,8(sp)
    80000ef4:	e022                	sd	s0,0(sp)
    80000ef6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ef8:	00001097          	auipc	ra,0x1
    80000efc:	b3c080e7          	jalr	-1220(ra) # 80001a34 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f00:	00008717          	auipc	a4,0x8
    80000f04:	9d870713          	addi	a4,a4,-1576 # 800088d8 <started>
  if(cpuid() == 0){
    80000f08:	c139                	beqz	a0,80000f4e <main+0x5e>
    while(started == 0)
    80000f0a:	431c                	lw	a5,0(a4)
    80000f0c:	2781                	sext.w	a5,a5
    80000f0e:	dff5                	beqz	a5,80000f0a <main+0x1a>
      ;
    __sync_synchronize();
    80000f10:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	b20080e7          	jalr	-1248(ra) # 80001a34 <cpuid>
    80000f1c:	85aa                	mv	a1,a0
    80000f1e:	00007517          	auipc	a0,0x7
    80000f22:	17a50513          	addi	a0,a0,378 # 80008098 <etext+0x98>
    80000f26:	fffff097          	auipc	ra,0xfffff
    80000f2a:	684080e7          	jalr	1668(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	0d8080e7          	jalr	216(ra) # 80001006 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	d0e080e7          	jalr	-754(ra) # 80002c44 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	616080e7          	jalr	1558(ra) # 80006554 <plicinithart>
  }

  scheduler();        
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	414080e7          	jalr	1044(ra) # 8000235a <scheduler>
    consoleinit();
    80000f4e:	fffff097          	auipc	ra,0xfffff
    80000f52:	534080e7          	jalr	1332(ra) # 80000482 <consoleinit>
    printfinit();
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	85e080e7          	jalr	-1954(ra) # 800007b4 <printfinit>
    printf("\n");
    80000f5e:	00007517          	auipc	a0,0x7
    80000f62:	0b250513          	addi	a0,a0,178 # 80008010 <etext+0x10>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	644080e7          	jalr	1604(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	11250513          	addi	a0,a0,274 # 80008080 <etext+0x80>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	634080e7          	jalr	1588(ra) # 800005aa <printf>
    printf("\n");
    80000f7e:	00007517          	auipc	a0,0x7
    80000f82:	09250513          	addi	a0,a0,146 # 80008010 <etext+0x10>
    80000f86:	fffff097          	auipc	ra,0xfffff
    80000f8a:	624080e7          	jalr	1572(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f8e:	00000097          	auipc	ra,0x0
    80000f92:	b80080e7          	jalr	-1152(ra) # 80000b0e <kinit>
    kvminit();       // create kernel page table
    80000f96:	00000097          	auipc	ra,0x0
    80000f9a:	32a080e7          	jalr	810(ra) # 800012c0 <kvminit>
    kvminithart();   // turn on paging
    80000f9e:	00000097          	auipc	ra,0x0
    80000fa2:	068080e7          	jalr	104(ra) # 80001006 <kvminithart>
    procinit();      // process table
    80000fa6:	00001097          	auipc	ra,0x1
    80000faa:	9d2080e7          	jalr	-1582(ra) # 80001978 <procinit>
    trapinit();      // trap vectors
    80000fae:	00002097          	auipc	ra,0x2
    80000fb2:	c6e080e7          	jalr	-914(ra) # 80002c1c <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb6:	00002097          	auipc	ra,0x2
    80000fba:	c8e080e7          	jalr	-882(ra) # 80002c44 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fbe:	00005097          	auipc	ra,0x5
    80000fc2:	57c080e7          	jalr	1404(ra) # 8000653a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fc6:	00005097          	auipc	ra,0x5
    80000fca:	58e080e7          	jalr	1422(ra) # 80006554 <plicinithart>
    binit();         // buffer cache
    80000fce:	00002097          	auipc	ra,0x2
    80000fd2:	610080e7          	jalr	1552(ra) # 800035de <binit>
    iinit();         // inode table
    80000fd6:	00003097          	auipc	ra,0x3
    80000fda:	ca0080e7          	jalr	-864(ra) # 80003c76 <iinit>
    fileinit();      // file table
    80000fde:	00004097          	auipc	ra,0x4
    80000fe2:	c72080e7          	jalr	-910(ra) # 80004c50 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe6:	00005097          	auipc	ra,0x5
    80000fea:	676080e7          	jalr	1654(ra) # 8000665c <virtio_disk_init>
    userinit();      // first user process
    80000fee:	00001097          	auipc	ra,0x1
    80000ff2:	d8e080e7          	jalr	-626(ra) # 80001d7c <userinit>
    __sync_synchronize();
    80000ff6:	0330000f          	fence	rw,rw
    started = 1;
    80000ffa:	4785                	li	a5,1
    80000ffc:	00008717          	auipc	a4,0x8
    80001000:	8cf72e23          	sw	a5,-1828(a4) # 800088d8 <started>
    80001004:	b789                	j	80000f46 <main+0x56>

0000000080001006 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001006:	1141                	addi	sp,sp,-16
    80001008:	e406                	sd	ra,8(sp)
    8000100a:	e022                	sd	s0,0(sp)
    8000100c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000100e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001012:	00008797          	auipc	a5,0x8
    80001016:	8ce7b783          	ld	a5,-1842(a5) # 800088e0 <kernel_pagetable>
    8000101a:	83b1                	srli	a5,a5,0xc
    8000101c:	577d                	li	a4,-1
    8000101e:	177e                	slli	a4,a4,0x3f
    80001020:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001022:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001026:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000102a:	60a2                	ld	ra,8(sp)
    8000102c:	6402                	ld	s0,0(sp)
    8000102e:	0141                	addi	sp,sp,16
    80001030:	8082                	ret

0000000080001032 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001032:	7139                	addi	sp,sp,-64
    80001034:	fc06                	sd	ra,56(sp)
    80001036:	f822                	sd	s0,48(sp)
    80001038:	f426                	sd	s1,40(sp)
    8000103a:	f04a                	sd	s2,32(sp)
    8000103c:	ec4e                	sd	s3,24(sp)
    8000103e:	e852                	sd	s4,16(sp)
    80001040:	e456                	sd	s5,8(sp)
    80001042:	e05a                	sd	s6,0(sp)
    80001044:	0080                	addi	s0,sp,64
    80001046:	84aa                	mv	s1,a0
    80001048:	89ae                	mv	s3,a1
    8000104a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001052:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001054:	04b7e263          	bltu	a5,a1,80001098 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001058:	0149d933          	srl	s2,s3,s4
    8000105c:	1ff97913          	andi	s2,s2,511
    80001060:	090e                	slli	s2,s2,0x3
    80001062:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001064:	00093483          	ld	s1,0(s2)
    80001068:	0014f793          	andi	a5,s1,1
    8000106c:	cf95                	beqz	a5,800010a8 <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000106e:	80a9                	srli	s1,s1,0xa
    80001070:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001072:	3a5d                	addiw	s4,s4,-9
    80001074:	ff6a12e3          	bne	s4,s6,80001058 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001078:	00c9d513          	srli	a0,s3,0xc
    8000107c:	1ff57513          	andi	a0,a0,511
    80001080:	050e                	slli	a0,a0,0x3
    80001082:	9526                	add	a0,a0,s1
}
    80001084:	70e2                	ld	ra,56(sp)
    80001086:	7442                	ld	s0,48(sp)
    80001088:	74a2                	ld	s1,40(sp)
    8000108a:	7902                	ld	s2,32(sp)
    8000108c:	69e2                	ld	s3,24(sp)
    8000108e:	6a42                	ld	s4,16(sp)
    80001090:	6aa2                	ld	s5,8(sp)
    80001092:	6b02                	ld	s6,0(sp)
    80001094:	6121                	addi	sp,sp,64
    80001096:	8082                	ret
    panic("walk");
    80001098:	00007517          	auipc	a0,0x7
    8000109c:	01850513          	addi	a0,a0,24 # 800080b0 <etext+0xb0>
    800010a0:	fffff097          	auipc	ra,0xfffff
    800010a4:	4c0080e7          	jalr	1216(ra) # 80000560 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010a8:	020a8663          	beqz	s5,800010d4 <walk+0xa2>
    800010ac:	00000097          	auipc	ra,0x0
    800010b0:	a9e080e7          	jalr	-1378(ra) # 80000b4a <kalloc>
    800010b4:	84aa                	mv	s1,a0
    800010b6:	d579                	beqz	a0,80001084 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010b8:	6605                	lui	a2,0x1
    800010ba:	4581                	li	a1,0
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	c7a080e7          	jalr	-902(ra) # 80000d36 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010c4:	00c4d793          	srli	a5,s1,0xc
    800010c8:	07aa                	slli	a5,a5,0xa
    800010ca:	0017e793          	ori	a5,a5,1
    800010ce:	00f93023          	sd	a5,0(s2)
    800010d2:	b745                	j	80001072 <walk+0x40>
        return 0;
    800010d4:	4501                	li	a0,0
    800010d6:	b77d                	j	80001084 <walk+0x52>

00000000800010d8 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d8:	57fd                	li	a5,-1
    800010da:	83e9                	srli	a5,a5,0x1a
    800010dc:	00b7f463          	bgeu	a5,a1,800010e4 <walkaddr+0xc>
    return 0;
    800010e0:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e2:	8082                	ret
{
    800010e4:	1141                	addi	sp,sp,-16
    800010e6:	e406                	sd	ra,8(sp)
    800010e8:	e022                	sd	s0,0(sp)
    800010ea:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ec:	4601                	li	a2,0
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	f44080e7          	jalr	-188(ra) # 80001032 <walk>
  if(pte == 0)
    800010f6:	c105                	beqz	a0,80001116 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010fa:	0117f693          	andi	a3,a5,17
    800010fe:	4745                	li	a4,17
    return 0;
    80001100:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001102:	00e68663          	beq	a3,a4,8000110e <walkaddr+0x36>
}
    80001106:	60a2                	ld	ra,8(sp)
    80001108:	6402                	ld	s0,0(sp)
    8000110a:	0141                	addi	sp,sp,16
    8000110c:	8082                	ret
  pa = PTE2PA(*pte);
    8000110e:	83a9                	srli	a5,a5,0xa
    80001110:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001114:	bfcd                	j	80001106 <walkaddr+0x2e>
    return 0;
    80001116:	4501                	li	a0,0
    80001118:	b7fd                	j	80001106 <walkaddr+0x2e>

000000008000111a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000111a:	715d                	addi	sp,sp,-80
    8000111c:	e486                	sd	ra,72(sp)
    8000111e:	e0a2                	sd	s0,64(sp)
    80001120:	fc26                	sd	s1,56(sp)
    80001122:	f84a                	sd	s2,48(sp)
    80001124:	f44e                	sd	s3,40(sp)
    80001126:	f052                	sd	s4,32(sp)
    80001128:	ec56                	sd	s5,24(sp)
    8000112a:	e85a                	sd	s6,16(sp)
    8000112c:	e45e                	sd	s7,8(sp)
    8000112e:	e062                	sd	s8,0(sp)
    80001130:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001132:	ca21                	beqz	a2,80001182 <mappages+0x68>
    80001134:	8aaa                	mv	s5,a0
    80001136:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001138:	777d                	lui	a4,0xfffff
    8000113a:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000113e:	fff58993          	addi	s3,a1,-1
    80001142:	99b2                	add	s3,s3,a2
    80001144:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001148:	893e                	mv	s2,a5
    8000114a:	40f68a33          	sub	s4,a3,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    8000114e:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001150:	6c05                	lui	s8,0x1
    80001152:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001156:	865e                	mv	a2,s7
    80001158:	85ca                	mv	a1,s2
    8000115a:	8556                	mv	a0,s5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	ed6080e7          	jalr	-298(ra) # 80001032 <walk>
    80001164:	cd1d                	beqz	a0,800011a2 <mappages+0x88>
    if(*pte & PTE_V)
    80001166:	611c                	ld	a5,0(a0)
    80001168:	8b85                	andi	a5,a5,1
    8000116a:	e785                	bnez	a5,80001192 <mappages+0x78>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000116c:	80b1                	srli	s1,s1,0xc
    8000116e:	04aa                	slli	s1,s1,0xa
    80001170:	0164e4b3          	or	s1,s1,s6
    80001174:	0014e493          	ori	s1,s1,1
    80001178:	e104                	sd	s1,0(a0)
    if(a == last)
    8000117a:	05390163          	beq	s2,s3,800011bc <mappages+0xa2>
    a += PGSIZE;
    8000117e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    80001180:	bfc9                	j	80001152 <mappages+0x38>
    panic("mappages: size");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	f3650513          	addi	a0,a0,-202 # 800080b8 <etext+0xb8>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3d6080e7          	jalr	982(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001192:	00007517          	auipc	a0,0x7
    80001196:	f3650513          	addi	a0,a0,-202 # 800080c8 <etext+0xc8>
    8000119a:	fffff097          	auipc	ra,0xfffff
    8000119e:	3c6080e7          	jalr	966(ra) # 80000560 <panic>
      return -1;
    800011a2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011a4:	60a6                	ld	ra,72(sp)
    800011a6:	6406                	ld	s0,64(sp)
    800011a8:	74e2                	ld	s1,56(sp)
    800011aa:	7942                	ld	s2,48(sp)
    800011ac:	79a2                	ld	s3,40(sp)
    800011ae:	7a02                	ld	s4,32(sp)
    800011b0:	6ae2                	ld	s5,24(sp)
    800011b2:	6b42                	ld	s6,16(sp)
    800011b4:	6ba2                	ld	s7,8(sp)
    800011b6:	6c02                	ld	s8,0(sp)
    800011b8:	6161                	addi	sp,sp,80
    800011ba:	8082                	ret
  return 0;
    800011bc:	4501                	li	a0,0
    800011be:	b7dd                	j	800011a4 <mappages+0x8a>

00000000800011c0 <kvmmap>:
{
    800011c0:	1141                	addi	sp,sp,-16
    800011c2:	e406                	sd	ra,8(sp)
    800011c4:	e022                	sd	s0,0(sp)
    800011c6:	0800                	addi	s0,sp,16
    800011c8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011ca:	86b2                	mv	a3,a2
    800011cc:	863e                	mv	a2,a5
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f4c080e7          	jalr	-180(ra) # 8000111a <mappages>
    800011d6:	e509                	bnez	a0,800011e0 <kvmmap+0x20>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret
    panic("kvmmap");
    800011e0:	00007517          	auipc	a0,0x7
    800011e4:	ef850513          	addi	a0,a0,-264 # 800080d8 <etext+0xd8>
    800011e8:	fffff097          	auipc	ra,0xfffff
    800011ec:	378080e7          	jalr	888(ra) # 80000560 <panic>

00000000800011f0 <kvmmake>:
{
    800011f0:	1101                	addi	sp,sp,-32
    800011f2:	ec06                	sd	ra,24(sp)
    800011f4:	e822                	sd	s0,16(sp)
    800011f6:	e426                	sd	s1,8(sp)
    800011f8:	e04a                	sd	s2,0(sp)
    800011fa:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	94e080e7          	jalr	-1714(ra) # 80000b4a <kalloc>
    80001204:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001206:	6605                	lui	a2,0x1
    80001208:	4581                	li	a1,0
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	b2c080e7          	jalr	-1236(ra) # 80000d36 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	6685                	lui	a3,0x1
    80001216:	10000637          	lui	a2,0x10000
    8000121a:	85b2                	mv	a1,a2
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	fa2080e7          	jalr	-94(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001226:	4719                	li	a4,6
    80001228:	6685                	lui	a3,0x1
    8000122a:	10001637          	lui	a2,0x10001
    8000122e:	85b2                	mv	a1,a2
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f8e080e7          	jalr	-114(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	004006b7          	lui	a3,0x400
    80001240:	0c000637          	lui	a2,0xc000
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f78080e7          	jalr	-136(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001250:	00007917          	auipc	s2,0x7
    80001254:	db090913          	addi	s2,s2,-592 # 80008000 <etext>
    80001258:	4729                	li	a4,10
    8000125a:	80007697          	auipc	a3,0x80007
    8000125e:	da668693          	addi	a3,a3,-602 # 8000 <_entry-0x7fff8000>
    80001262:	4605                	li	a2,1
    80001264:	067e                	slli	a2,a2,0x1f
    80001266:	85b2                	mv	a1,a2
    80001268:	8526                	mv	a0,s1
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	f56080e7          	jalr	-170(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001272:	4719                	li	a4,6
    80001274:	46c5                	li	a3,17
    80001276:	06ee                	slli	a3,a3,0x1b
    80001278:	412686b3          	sub	a3,a3,s2
    8000127c:	864a                	mv	a2,s2
    8000127e:	85ca                	mv	a1,s2
    80001280:	8526                	mv	a0,s1
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f3e080e7          	jalr	-194(ra) # 800011c0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000128a:	4729                	li	a4,10
    8000128c:	6685                	lui	a3,0x1
    8000128e:	00006617          	auipc	a2,0x6
    80001292:	d7260613          	addi	a2,a2,-654 # 80007000 <_trampoline>
    80001296:	040005b7          	lui	a1,0x4000
    8000129a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000129c:	05b2                	slli	a1,a1,0xc
    8000129e:	8526                	mv	a0,s1
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f20080e7          	jalr	-224(ra) # 800011c0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012a8:	8526                	mv	a0,s1
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	624080e7          	jalr	1572(ra) # 800018ce <proc_mapstacks>
}
    800012b2:	8526                	mv	a0,s1
    800012b4:	60e2                	ld	ra,24(sp)
    800012b6:	6442                	ld	s0,16(sp)
    800012b8:	64a2                	ld	s1,8(sp)
    800012ba:	6902                	ld	s2,0(sp)
    800012bc:	6105                	addi	sp,sp,32
    800012be:	8082                	ret

00000000800012c0 <kvminit>:
{
    800012c0:	1141                	addi	sp,sp,-16
    800012c2:	e406                	sd	ra,8(sp)
    800012c4:	e022                	sd	s0,0(sp)
    800012c6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	f28080e7          	jalr	-216(ra) # 800011f0 <kvmmake>
    800012d0:	00007797          	auipc	a5,0x7
    800012d4:	60a7b823          	sd	a0,1552(a5) # 800088e0 <kernel_pagetable>
}
    800012d8:	60a2                	ld	ra,8(sp)
    800012da:	6402                	ld	s0,0(sp)
    800012dc:	0141                	addi	sp,sp,16
    800012de:	8082                	ret

00000000800012e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012e0:	715d                	addi	sp,sp,-80
    800012e2:	e486                	sd	ra,72(sp)
    800012e4:	e0a2                	sd	s0,64(sp)
    800012e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012e8:	03459793          	slli	a5,a1,0x34
    800012ec:	e39d                	bnez	a5,80001312 <uvmunmap+0x32>
    800012ee:	f84a                	sd	s2,48(sp)
    800012f0:	f44e                	sd	s3,40(sp)
    800012f2:	f052                	sd	s4,32(sp)
    800012f4:	ec56                	sd	s5,24(sp)
    800012f6:	e85a                	sd	s6,16(sp)
    800012f8:	e45e                	sd	s7,8(sp)
    800012fa:	8a2a                	mv	s4,a0
    800012fc:	892e                	mv	s2,a1
    800012fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001300:	0632                	slli	a2,a2,0xc
    80001302:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001306:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001308:	6b05                	lui	s6,0x1
    8000130a:	0935fb63          	bgeu	a1,s3,800013a0 <uvmunmap+0xc0>
    8000130e:	fc26                	sd	s1,56(sp)
    80001310:	a8a9                	j	8000136a <uvmunmap+0x8a>
    80001312:	fc26                	sd	s1,56(sp)
    80001314:	f84a                	sd	s2,48(sp)
    80001316:	f44e                	sd	s3,40(sp)
    80001318:	f052                	sd	s4,32(sp)
    8000131a:	ec56                	sd	s5,24(sp)
    8000131c:	e85a                	sd	s6,16(sp)
    8000131e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001320:	00007517          	auipc	a0,0x7
    80001324:	dc050513          	addi	a0,a0,-576 # 800080e0 <etext+0xe0>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	238080e7          	jalr	568(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    80001330:	00007517          	auipc	a0,0x7
    80001334:	dc850513          	addi	a0,a0,-568 # 800080f8 <etext+0xf8>
    80001338:	fffff097          	auipc	ra,0xfffff
    8000133c:	228080e7          	jalr	552(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001340:	00007517          	auipc	a0,0x7
    80001344:	dc850513          	addi	a0,a0,-568 # 80008108 <etext+0x108>
    80001348:	fffff097          	auipc	ra,0xfffff
    8000134c:	218080e7          	jalr	536(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001350:	00007517          	auipc	a0,0x7
    80001354:	dd050513          	addi	a0,a0,-560 # 80008120 <etext+0x120>
    80001358:	fffff097          	auipc	ra,0xfffff
    8000135c:	208080e7          	jalr	520(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001360:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001364:	995a                	add	s2,s2,s6
    80001366:	03397c63          	bgeu	s2,s3,8000139e <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000136a:	4601                	li	a2,0
    8000136c:	85ca                	mv	a1,s2
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	cc2080e7          	jalr	-830(ra) # 80001032 <walk>
    80001378:	84aa                	mv	s1,a0
    8000137a:	d95d                	beqz	a0,80001330 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000137c:	6108                	ld	a0,0(a0)
    8000137e:	00157793          	andi	a5,a0,1
    80001382:	dfdd                	beqz	a5,80001340 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001384:	3ff57793          	andi	a5,a0,1023
    80001388:	fd7784e3          	beq	a5,s7,80001350 <uvmunmap+0x70>
    if(do_free){
    8000138c:	fc0a8ae3          	beqz	s5,80001360 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001390:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001392:	0532                	slli	a0,a0,0xc
    80001394:	fffff097          	auipc	ra,0xfffff
    80001398:	6b8080e7          	jalr	1720(ra) # 80000a4c <kfree>
    8000139c:	b7d1                	j	80001360 <uvmunmap+0x80>
    8000139e:	74e2                	ld	s1,56(sp)
    800013a0:	7942                	ld	s2,48(sp)
    800013a2:	79a2                	ld	s3,40(sp)
    800013a4:	7a02                	ld	s4,32(sp)
    800013a6:	6ae2                	ld	s5,24(sp)
    800013a8:	6b42                	ld	s6,16(sp)
    800013aa:	6ba2                	ld	s7,8(sp)
  }
}
    800013ac:	60a6                	ld	ra,72(sp)
    800013ae:	6406                	ld	s0,64(sp)
    800013b0:	6161                	addi	sp,sp,80
    800013b2:	8082                	ret

00000000800013b4 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013b4:	1101                	addi	sp,sp,-32
    800013b6:	ec06                	sd	ra,24(sp)
    800013b8:	e822                	sd	s0,16(sp)
    800013ba:	e426                	sd	s1,8(sp)
    800013bc:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	78c080e7          	jalr	1932(ra) # 80000b4a <kalloc>
    800013c6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013c8:	c519                	beqz	a0,800013d6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ca:	6605                	lui	a2,0x1
    800013cc:	4581                	li	a1,0
    800013ce:	00000097          	auipc	ra,0x0
    800013d2:	968080e7          	jalr	-1688(ra) # 80000d36 <memset>
  return pagetable;
}
    800013d6:	8526                	mv	a0,s1
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6105                	addi	sp,sp,32
    800013e0:	8082                	ret

00000000800013e2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013e2:	7179                	addi	sp,sp,-48
    800013e4:	f406                	sd	ra,40(sp)
    800013e6:	f022                	sd	s0,32(sp)
    800013e8:	ec26                	sd	s1,24(sp)
    800013ea:	e84a                	sd	s2,16(sp)
    800013ec:	e44e                	sd	s3,8(sp)
    800013ee:	e052                	sd	s4,0(sp)
    800013f0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013f2:	6785                	lui	a5,0x1
    800013f4:	04f67863          	bgeu	a2,a5,80001444 <uvmfirst+0x62>
    800013f8:	8a2a                	mv	s4,a0
    800013fa:	89ae                	mv	s3,a1
    800013fc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	74c080e7          	jalr	1868(ra) # 80000b4a <kalloc>
    80001406:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001408:	6605                	lui	a2,0x1
    8000140a:	4581                	li	a1,0
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	92a080e7          	jalr	-1750(ra) # 80000d36 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001414:	4779                	li	a4,30
    80001416:	86ca                	mv	a3,s2
    80001418:	6605                	lui	a2,0x1
    8000141a:	4581                	li	a1,0
    8000141c:	8552                	mv	a0,s4
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	cfc080e7          	jalr	-772(ra) # 8000111a <mappages>
  memmove(mem, src, sz);
    80001426:	8626                	mv	a2,s1
    80001428:	85ce                	mv	a1,s3
    8000142a:	854a                	mv	a0,s2
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	96e080e7          	jalr	-1682(ra) # 80000d9a <memmove>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret
    panic("uvmfirst: more than a page");
    80001444:	00007517          	auipc	a0,0x7
    80001448:	cf450513          	addi	a0,a0,-780 # 80008138 <etext+0x138>
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	114080e7          	jalr	276(ra) # 80000560 <panic>

0000000080001454 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001454:	1101                	addi	sp,sp,-32
    80001456:	ec06                	sd	ra,24(sp)
    80001458:	e822                	sd	s0,16(sp)
    8000145a:	e426                	sd	s1,8(sp)
    8000145c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000145e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001460:	00b67d63          	bgeu	a2,a1,8000147a <uvmdealloc+0x26>
    80001464:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001466:	6785                	lui	a5,0x1
    80001468:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000146a:	00f60733          	add	a4,a2,a5
    8000146e:	76fd                	lui	a3,0xfffff
    80001470:	8f75                	and	a4,a4,a3
    80001472:	97ae                	add	a5,a5,a1
    80001474:	8ff5                	and	a5,a5,a3
    80001476:	00f76863          	bltu	a4,a5,80001486 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000147a:	8526                	mv	a0,s1
    8000147c:	60e2                	ld	ra,24(sp)
    8000147e:	6442                	ld	s0,16(sp)
    80001480:	64a2                	ld	s1,8(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001486:	8f99                	sub	a5,a5,a4
    80001488:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000148a:	4685                	li	a3,1
    8000148c:	0007861b          	sext.w	a2,a5
    80001490:	85ba                	mv	a1,a4
    80001492:	00000097          	auipc	ra,0x0
    80001496:	e4e080e7          	jalr	-434(ra) # 800012e0 <uvmunmap>
    8000149a:	b7c5                	j	8000147a <uvmdealloc+0x26>

000000008000149c <uvmalloc>:
  if(newsz < oldsz)
    8000149c:	0ab66f63          	bltu	a2,a1,8000155a <uvmalloc+0xbe>
{
    800014a0:	715d                	addi	sp,sp,-80
    800014a2:	e486                	sd	ra,72(sp)
    800014a4:	e0a2                	sd	s0,64(sp)
    800014a6:	f052                	sd	s4,32(sp)
    800014a8:	ec56                	sd	s5,24(sp)
    800014aa:	e85a                	sd	s6,16(sp)
    800014ac:	0880                	addi	s0,sp,80
    800014ae:	8b2a                	mv	s6,a0
    800014b0:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    800014b2:	6785                	lui	a5,0x1
    800014b4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014b6:	95be                	add	a1,a1,a5
    800014b8:	77fd                	lui	a5,0xfffff
    800014ba:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014be:	0aca7063          	bgeu	s4,a2,8000155e <uvmalloc+0xc2>
    800014c2:	fc26                	sd	s1,56(sp)
    800014c4:	f84a                	sd	s2,48(sp)
    800014c6:	f44e                	sd	s3,40(sp)
    800014c8:	e45e                	sd	s7,8(sp)
    800014ca:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    800014cc:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014ce:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	678080e7          	jalr	1656(ra) # 80000b4a <kalloc>
    800014da:	84aa                	mv	s1,a0
    if(mem == 0){
    800014dc:	c915                	beqz	a0,80001510 <uvmalloc+0x74>
    memset(mem, 0, PGSIZE);
    800014de:	864e                	mv	a2,s3
    800014e0:	4581                	li	a1,0
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	854080e7          	jalr	-1964(ra) # 80000d36 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014ea:	875e                	mv	a4,s7
    800014ec:	86a6                	mv	a3,s1
    800014ee:	864e                	mv	a2,s3
    800014f0:	85ca                	mv	a1,s2
    800014f2:	855a                	mv	a0,s6
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	c26080e7          	jalr	-986(ra) # 8000111a <mappages>
    800014fc:	ed0d                	bnez	a0,80001536 <uvmalloc+0x9a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014fe:	994e                	add	s2,s2,s3
    80001500:	fd5969e3          	bltu	s2,s5,800014d2 <uvmalloc+0x36>
  return newsz;
    80001504:	8556                	mv	a0,s5
    80001506:	74e2                	ld	s1,56(sp)
    80001508:	7942                	ld	s2,48(sp)
    8000150a:	79a2                	ld	s3,40(sp)
    8000150c:	6ba2                	ld	s7,8(sp)
    8000150e:	a829                	j	80001528 <uvmalloc+0x8c>
      uvmdealloc(pagetable, a, oldsz);
    80001510:	8652                	mv	a2,s4
    80001512:	85ca                	mv	a1,s2
    80001514:	855a                	mv	a0,s6
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	f3e080e7          	jalr	-194(ra) # 80001454 <uvmdealloc>
      return 0;
    8000151e:	4501                	li	a0,0
    80001520:	74e2                	ld	s1,56(sp)
    80001522:	7942                	ld	s2,48(sp)
    80001524:	79a2                	ld	s3,40(sp)
    80001526:	6ba2                	ld	s7,8(sp)
}
    80001528:	60a6                	ld	ra,72(sp)
    8000152a:	6406                	ld	s0,64(sp)
    8000152c:	7a02                	ld	s4,32(sp)
    8000152e:	6ae2                	ld	s5,24(sp)
    80001530:	6b42                	ld	s6,16(sp)
    80001532:	6161                	addi	sp,sp,80
    80001534:	8082                	ret
      kfree(mem);
    80001536:	8526                	mv	a0,s1
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	514080e7          	jalr	1300(ra) # 80000a4c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001540:	8652                	mv	a2,s4
    80001542:	85ca                	mv	a1,s2
    80001544:	855a                	mv	a0,s6
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f0e080e7          	jalr	-242(ra) # 80001454 <uvmdealloc>
      return 0;
    8000154e:	4501                	li	a0,0
    80001550:	74e2                	ld	s1,56(sp)
    80001552:	7942                	ld	s2,48(sp)
    80001554:	79a2                	ld	s3,40(sp)
    80001556:	6ba2                	ld	s7,8(sp)
    80001558:	bfc1                	j	80001528 <uvmalloc+0x8c>
    return oldsz;
    8000155a:	852e                	mv	a0,a1
}
    8000155c:	8082                	ret
  return newsz;
    8000155e:	8532                	mv	a0,a2
    80001560:	b7e1                	j	80001528 <uvmalloc+0x8c>

0000000080001562 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001562:	7179                	addi	sp,sp,-48
    80001564:	f406                	sd	ra,40(sp)
    80001566:	f022                	sd	s0,32(sp)
    80001568:	ec26                	sd	s1,24(sp)
    8000156a:	e84a                	sd	s2,16(sp)
    8000156c:	e44e                	sd	s3,8(sp)
    8000156e:	e052                	sd	s4,0(sp)
    80001570:	1800                	addi	s0,sp,48
    80001572:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001574:	84aa                	mv	s1,a0
    80001576:	6905                	lui	s2,0x1
    80001578:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000157a:	4985                	li	s3,1
    8000157c:	a829                	j	80001596 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000157e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001580:	00c79513          	slli	a0,a5,0xc
    80001584:	00000097          	auipc	ra,0x0
    80001588:	fde080e7          	jalr	-34(ra) # 80001562 <freewalk>
      pagetable[i] = 0;
    8000158c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001590:	04a1                	addi	s1,s1,8
    80001592:	03248163          	beq	s1,s2,800015b4 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001596:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001598:	00f7f713          	andi	a4,a5,15
    8000159c:	ff3701e3          	beq	a4,s3,8000157e <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015a0:	8b85                	andi	a5,a5,1
    800015a2:	d7fd                	beqz	a5,80001590 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015a4:	00007517          	auipc	a0,0x7
    800015a8:	bb450513          	addi	a0,a0,-1100 # 80008158 <etext+0x158>
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	fb4080e7          	jalr	-76(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    800015b4:	8552                	mv	a0,s4
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	496080e7          	jalr	1174(ra) # 80000a4c <kfree>
}
    800015be:	70a2                	ld	ra,40(sp)
    800015c0:	7402                	ld	s0,32(sp)
    800015c2:	64e2                	ld	s1,24(sp)
    800015c4:	6942                	ld	s2,16(sp)
    800015c6:	69a2                	ld	s3,8(sp)
    800015c8:	6a02                	ld	s4,0(sp)
    800015ca:	6145                	addi	sp,sp,48
    800015cc:	8082                	ret

00000000800015ce <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ce:	1101                	addi	sp,sp,-32
    800015d0:	ec06                	sd	ra,24(sp)
    800015d2:	e822                	sd	s0,16(sp)
    800015d4:	e426                	sd	s1,8(sp)
    800015d6:	1000                	addi	s0,sp,32
    800015d8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015da:	e999                	bnez	a1,800015f0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015dc:	8526                	mv	a0,s1
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	f84080e7          	jalr	-124(ra) # 80001562 <freewalk>
}
    800015e6:	60e2                	ld	ra,24(sp)
    800015e8:	6442                	ld	s0,16(sp)
    800015ea:	64a2                	ld	s1,8(sp)
    800015ec:	6105                	addi	sp,sp,32
    800015ee:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f0:	6785                	lui	a5,0x1
    800015f2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015f4:	95be                	add	a1,a1,a5
    800015f6:	4685                	li	a3,1
    800015f8:	00c5d613          	srli	a2,a1,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	ce2080e7          	jalr	-798(ra) # 800012e0 <uvmunmap>
    80001606:	bfd9                	j	800015dc <uvmfree+0xe>

0000000080001608 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001608:	ca69                	beqz	a2,800016da <uvmcopy+0xd2>
{
    8000160a:	715d                	addi	sp,sp,-80
    8000160c:	e486                	sd	ra,72(sp)
    8000160e:	e0a2                	sd	s0,64(sp)
    80001610:	fc26                	sd	s1,56(sp)
    80001612:	f84a                	sd	s2,48(sp)
    80001614:	f44e                	sd	s3,40(sp)
    80001616:	f052                	sd	s4,32(sp)
    80001618:	ec56                	sd	s5,24(sp)
    8000161a:	e85a                	sd	s6,16(sp)
    8000161c:	e45e                	sd	s7,8(sp)
    8000161e:	e062                	sd	s8,0(sp)
    80001620:	0880                	addi	s0,sp,80
    80001622:	8baa                	mv	s7,a0
    80001624:	8b2e                	mv	s6,a1
    80001626:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162a:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000162c:	4601                	li	a2,0
    8000162e:	85ce                	mv	a1,s3
    80001630:	855e                	mv	a0,s7
    80001632:	00000097          	auipc	ra,0x0
    80001636:	a00080e7          	jalr	-1536(ra) # 80001032 <walk>
    8000163a:	c529                	beqz	a0,80001684 <uvmcopy+0x7c>
    if((*pte & PTE_V) == 0)
    8000163c:	6118                	ld	a4,0(a0)
    8000163e:	00177793          	andi	a5,a4,1
    80001642:	cba9                	beqz	a5,80001694 <uvmcopy+0x8c>
    pa = PTE2PA(*pte);
    80001644:	00a75593          	srli	a1,a4,0xa
    80001648:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000164c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	4fa080e7          	jalr	1274(ra) # 80000b4a <kalloc>
    80001658:	892a                	mv	s2,a0
    8000165a:	c931                	beqz	a0,800016ae <uvmcopy+0xa6>
    memmove(mem, (char*)pa, PGSIZE);
    8000165c:	8652                	mv	a2,s4
    8000165e:	85e2                	mv	a1,s8
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	73a080e7          	jalr	1850(ra) # 80000d9a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001668:	8726                	mv	a4,s1
    8000166a:	86ca                	mv	a3,s2
    8000166c:	8652                	mv	a2,s4
    8000166e:	85ce                	mv	a1,s3
    80001670:	855a                	mv	a0,s6
    80001672:	00000097          	auipc	ra,0x0
    80001676:	aa8080e7          	jalr	-1368(ra) # 8000111a <mappages>
    8000167a:	e50d                	bnez	a0,800016a4 <uvmcopy+0x9c>
  for(i = 0; i < sz; i += PGSIZE){
    8000167c:	99d2                	add	s3,s3,s4
    8000167e:	fb59e7e3          	bltu	s3,s5,8000162c <uvmcopy+0x24>
    80001682:	a081                	j	800016c2 <uvmcopy+0xba>
      panic("uvmcopy: pte should exist");
    80001684:	00007517          	auipc	a0,0x7
    80001688:	ae450513          	addi	a0,a0,-1308 # 80008168 <etext+0x168>
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	ed4080e7          	jalr	-300(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001694:	00007517          	auipc	a0,0x7
    80001698:	af450513          	addi	a0,a0,-1292 # 80008188 <etext+0x188>
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	ec4080e7          	jalr	-316(ra) # 80000560 <panic>
      kfree(mem);
    800016a4:	854a                	mv	a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	3a6080e7          	jalr	934(ra) # 80000a4c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ae:	4685                	li	a3,1
    800016b0:	00c9d613          	srli	a2,s3,0xc
    800016b4:	4581                	li	a1,0
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	c28080e7          	jalr	-984(ra) # 800012e0 <uvmunmap>
  return -1;
    800016c0:	557d                	li	a0,-1
}
    800016c2:	60a6                	ld	ra,72(sp)
    800016c4:	6406                	ld	s0,64(sp)
    800016c6:	74e2                	ld	s1,56(sp)
    800016c8:	7942                	ld	s2,48(sp)
    800016ca:	79a2                	ld	s3,40(sp)
    800016cc:	7a02                	ld	s4,32(sp)
    800016ce:	6ae2                	ld	s5,24(sp)
    800016d0:	6b42                	ld	s6,16(sp)
    800016d2:	6ba2                	ld	s7,8(sp)
    800016d4:	6c02                	ld	s8,0(sp)
    800016d6:	6161                	addi	sp,sp,80
    800016d8:	8082                	ret
  return 0;
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret

00000000800016de <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016de:	1141                	addi	sp,sp,-16
    800016e0:	e406                	sd	ra,8(sp)
    800016e2:	e022                	sd	s0,0(sp)
    800016e4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e6:	4601                	li	a2,0
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	94a080e7          	jalr	-1718(ra) # 80001032 <walk>
  if(pte == 0)
    800016f0:	c901                	beqz	a0,80001700 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016f2:	611c                	ld	a5,0(a0)
    800016f4:	9bbd                	andi	a5,a5,-17
    800016f6:	e11c                	sd	a5,0(a0)
}
    800016f8:	60a2                	ld	ra,8(sp)
    800016fa:	6402                	ld	s0,0(sp)
    800016fc:	0141                	addi	sp,sp,16
    800016fe:	8082                	ret
    panic("uvmclear");
    80001700:	00007517          	auipc	a0,0x7
    80001704:	aa850513          	addi	a0,a0,-1368 # 800081a8 <etext+0x1a8>
    80001708:	fffff097          	auipc	ra,0xfffff
    8000170c:	e58080e7          	jalr	-424(ra) # 80000560 <panic>

0000000080001710 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyout+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8c2e                	mv	s8,a1
    8000172e:	8a32                	mv	s4,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	85d2                	mv	a1,s4
    80001740:	41250533          	sub	a0,a0,s2
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	656080e7          	jalr	1622(ra) # 80000d9a <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001750:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	976080e7          	jalr	-1674(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyout+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyout+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyout+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000179c:	caa5                	beqz	a3,8000180c <copyin+0x70>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	e062                	sd	s8,0(sp)
    800017b4:	0880                	addi	s0,sp,80
    800017b6:	8b2a                	mv	s6,a0
    800017b8:	8a2e                	mv	s4,a1
    800017ba:	8c32                	mv	s8,a2
    800017bc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017be:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c0:	6a85                	lui	s5,0x1
    800017c2:	a01d                	j	800017e8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017c4:	018505b3          	add	a1,a0,s8
    800017c8:	0004861b          	sext.w	a2,s1
    800017cc:	412585b3          	sub	a1,a1,s2
    800017d0:	8552                	mv	a0,s4
    800017d2:	fffff097          	auipc	ra,0xfffff
    800017d6:	5c8080e7          	jalr	1480(ra) # 80000d9a <memmove>

    len -= n;
    800017da:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017de:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017e0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e4:	02098263          	beqz	s3,80001808 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017ec:	85ca                	mv	a1,s2
    800017ee:	855a                	mv	a0,s6
    800017f0:	00000097          	auipc	ra,0x0
    800017f4:	8e8080e7          	jalr	-1816(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    800017f8:	cd01                	beqz	a0,80001810 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017fa:	418904b3          	sub	s1,s2,s8
    800017fe:	94d6                	add	s1,s1,s5
    if(n > len)
    80001800:	fc99f2e3          	bgeu	s3,s1,800017c4 <copyin+0x28>
    80001804:	84ce                	mv	s1,s3
    80001806:	bf7d                	j	800017c4 <copyin+0x28>
  }
  return 0;
    80001808:	4501                	li	a0,0
    8000180a:	a021                	j	80001812 <copyin+0x76>
    8000180c:	4501                	li	a0,0
}
    8000180e:	8082                	ret
      return -1;
    80001810:	557d                	li	a0,-1
}
    80001812:	60a6                	ld	ra,72(sp)
    80001814:	6406                	ld	s0,64(sp)
    80001816:	74e2                	ld	s1,56(sp)
    80001818:	7942                	ld	s2,48(sp)
    8000181a:	79a2                	ld	s3,40(sp)
    8000181c:	7a02                	ld	s4,32(sp)
    8000181e:	6ae2                	ld	s5,24(sp)
    80001820:	6b42                	ld	s6,16(sp)
    80001822:	6ba2                	ld	s7,8(sp)
    80001824:	6c02                	ld	s8,0(sp)
    80001826:	6161                	addi	sp,sp,80
    80001828:	8082                	ret

000000008000182a <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    8000182a:	715d                	addi	sp,sp,-80
    8000182c:	e486                	sd	ra,72(sp)
    8000182e:	e0a2                	sd	s0,64(sp)
    80001830:	fc26                	sd	s1,56(sp)
    80001832:	f84a                	sd	s2,48(sp)
    80001834:	f44e                	sd	s3,40(sp)
    80001836:	f052                	sd	s4,32(sp)
    80001838:	ec56                	sd	s5,24(sp)
    8000183a:	e85a                	sd	s6,16(sp)
    8000183c:	e45e                	sd	s7,8(sp)
    8000183e:	0880                	addi	s0,sp,80
    80001840:	8aaa                	mv	s5,a0
    80001842:	89ae                	mv	s3,a1
    80001844:	8bb2                	mv	s7,a2
    80001846:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    80001848:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000184a:	6a05                	lui	s4,0x1
    8000184c:	a02d                	j	80001876 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184e:	00078023          	sb	zero,0(a5)
    80001852:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001854:	0017c793          	xori	a5,a5,1
    80001858:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000185c:	60a6                	ld	ra,72(sp)
    8000185e:	6406                	ld	s0,64(sp)
    80001860:	74e2                	ld	s1,56(sp)
    80001862:	7942                	ld	s2,48(sp)
    80001864:	79a2                	ld	s3,40(sp)
    80001866:	7a02                	ld	s4,32(sp)
    80001868:	6ae2                	ld	s5,24(sp)
    8000186a:	6b42                	ld	s6,16(sp)
    8000186c:	6ba2                	ld	s7,8(sp)
    8000186e:	6161                	addi	sp,sp,80
    80001870:	8082                	ret
    srcva = va0 + PGSIZE;
    80001872:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001876:	c8a1                	beqz	s1,800018c6 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001878:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000187c:	85ca                	mv	a1,s2
    8000187e:	8556                	mv	a0,s5
    80001880:	00000097          	auipc	ra,0x0
    80001884:	858080e7          	jalr	-1960(ra) # 800010d8 <walkaddr>
    if(pa0 == 0)
    80001888:	c129                	beqz	a0,800018ca <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    8000188a:	41790633          	sub	a2,s2,s7
    8000188e:	9652                	add	a2,a2,s4
    if(n > max)
    80001890:	00c4f363          	bgeu	s1,a2,80001896 <copyinstr+0x6c>
    80001894:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001896:	412b8bb3          	sub	s7,s7,s2
    8000189a:	9baa                	add	s7,s7,a0
    while(n > 0){
    8000189c:	da79                	beqz	a2,80001872 <copyinstr+0x48>
    8000189e:	87ce                	mv	a5,s3
      if(*p == '\0'){
    800018a0:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    800018a4:	964e                	add	a2,a2,s3
    800018a6:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018a8:	00f68733          	add	a4,a3,a5
    800018ac:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9e90>
    800018b0:	df59                	beqz	a4,8000184e <copyinstr+0x24>
        *dst = *p;
    800018b2:	00e78023          	sb	a4,0(a5)
      dst++;
    800018b6:	0785                	addi	a5,a5,1
    while(n > 0){
    800018b8:	fec797e3          	bne	a5,a2,800018a6 <copyinstr+0x7c>
    800018bc:	14fd                	addi	s1,s1,-1
    800018be:	94ce                	add	s1,s1,s3
      --max;
    800018c0:	8c8d                	sub	s1,s1,a1
    800018c2:	89be                	mv	s3,a5
    800018c4:	b77d                	j	80001872 <copyinstr+0x48>
    800018c6:	4781                	li	a5,0
    800018c8:	b771                	j	80001854 <copyinstr+0x2a>
      return -1;
    800018ca:	557d                	li	a0,-1
    800018cc:	bf41                	j	8000185c <copyinstr+0x32>

00000000800018ce <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    800018ce:	715d                	addi	sp,sp,-80
    800018d0:	e486                	sd	ra,72(sp)
    800018d2:	e0a2                	sd	s0,64(sp)
    800018d4:	fc26                	sd	s1,56(sp)
    800018d6:	f84a                	sd	s2,48(sp)
    800018d8:	f44e                	sd	s3,40(sp)
    800018da:	f052                	sd	s4,32(sp)
    800018dc:	ec56                	sd	s5,24(sp)
    800018de:	e85a                	sd	s6,16(sp)
    800018e0:	e45e                	sd	s7,8(sp)
    800018e2:	e062                	sd	s8,0(sp)
    800018e4:	0880                	addi	s0,sp,80
    800018e6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800018e8:	0000f497          	auipc	s1,0xf
    800018ec:	6a848493          	addi	s1,s1,1704 # 80010f90 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800018f0:	8c26                	mv	s8,s1
    800018f2:	e327b7b7          	lui	a5,0xe327b
    800018f6:	97778793          	addi	a5,a5,-1673 # ffffffffe327a977 <end+0xffffffff63255807>
    800018fa:	193d5937          	lui	s2,0x193d5
    800018fe:	bb890913          	addi	s2,s2,-1096 # 193d4bb8 <_entry-0x66c2b448>
    80001902:	1902                	slli	s2,s2,0x20
    80001904:	993e                	add	s2,s2,a5
    80001906:	040009b7          	lui	s3,0x4000
    8000190a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000190c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000190e:	4b99                	li	s7,6
    80001910:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++)
    80001912:	00018a97          	auipc	s5,0x18
    80001916:	47ea8a93          	addi	s5,s5,1150 # 80019d90 <tickslock>
    char *pa = kalloc();
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	230080e7          	jalr	560(ra) # 80000b4a <kalloc>
    80001922:	862a                	mv	a2,a0
    if (pa == 0)
    80001924:	c131                	beqz	a0,80001968 <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int)(p - proc));
    80001926:	418485b3          	sub	a1,s1,s8
    8000192a:	858d                	srai	a1,a1,0x3
    8000192c:	032585b3          	mul	a1,a1,s2
    80001930:	2585                	addiw	a1,a1,1
    80001932:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001936:	875e                	mv	a4,s7
    80001938:	86da                	mv	a3,s6
    8000193a:	40b985b3          	sub	a1,s3,a1
    8000193e:	8552                	mv	a0,s4
    80001940:	00000097          	auipc	ra,0x0
    80001944:	880080e7          	jalr	-1920(ra) # 800011c0 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001948:	23848493          	addi	s1,s1,568
    8000194c:	fd5497e3          	bne	s1,s5,8000191a <proc_mapstacks+0x4c>
  }
}
    80001950:	60a6                	ld	ra,72(sp)
    80001952:	6406                	ld	s0,64(sp)
    80001954:	74e2                	ld	s1,56(sp)
    80001956:	7942                	ld	s2,48(sp)
    80001958:	79a2                	ld	s3,40(sp)
    8000195a:	7a02                	ld	s4,32(sp)
    8000195c:	6ae2                	ld	s5,24(sp)
    8000195e:	6b42                	ld	s6,16(sp)
    80001960:	6ba2                	ld	s7,8(sp)
    80001962:	6c02                	ld	s8,0(sp)
    80001964:	6161                	addi	sp,sp,80
    80001966:	8082                	ret
      panic("kalloc");
    80001968:	00007517          	auipc	a0,0x7
    8000196c:	85050513          	addi	a0,a0,-1968 # 800081b8 <etext+0x1b8>
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	bf0080e7          	jalr	-1040(ra) # 80000560 <panic>

0000000080001978 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001978:	7139                	addi	sp,sp,-64
    8000197a:	fc06                	sd	ra,56(sp)
    8000197c:	f822                	sd	s0,48(sp)
    8000197e:	f426                	sd	s1,40(sp)
    80001980:	f04a                	sd	s2,32(sp)
    80001982:	ec4e                	sd	s3,24(sp)
    80001984:	e852                	sd	s4,16(sp)
    80001986:	e456                	sd	s5,8(sp)
    80001988:	e05a                	sd	s6,0(sp)
    8000198a:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000198c:	00007597          	auipc	a1,0x7
    80001990:	83458593          	addi	a1,a1,-1996 # 800081c0 <etext+0x1c0>
    80001994:	0000f517          	auipc	a0,0xf
    80001998:	1cc50513          	addi	a0,a0,460 # 80010b60 <pid_lock>
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	20e080e7          	jalr	526(ra) # 80000baa <initlock>
  initlock(&wait_lock, "wait_lock");
    800019a4:	00007597          	auipc	a1,0x7
    800019a8:	82458593          	addi	a1,a1,-2012 # 800081c8 <etext+0x1c8>
    800019ac:	0000f517          	auipc	a0,0xf
    800019b0:	1cc50513          	addi	a0,a0,460 # 80010b78 <wait_lock>
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	1f6080e7          	jalr	502(ra) # 80000baa <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    800019bc:	0000f497          	auipc	s1,0xf
    800019c0:	5d448493          	addi	s1,s1,1492 # 80010f90 <proc>
  {
    initlock(&p->lock, "proc");
    800019c4:	00007b17          	auipc	s6,0x7
    800019c8:	814b0b13          	addi	s6,s6,-2028 # 800081d8 <etext+0x1d8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800019cc:	8aa6                	mv	s5,s1
    800019ce:	e327b7b7          	lui	a5,0xe327b
    800019d2:	97778793          	addi	a5,a5,-1673 # ffffffffe327a977 <end+0xffffffff63255807>
    800019d6:	193d5937          	lui	s2,0x193d5
    800019da:	bb890913          	addi	s2,s2,-1096 # 193d4bb8 <_entry-0x66c2b448>
    800019de:	1902                	slli	s2,s2,0x20
    800019e0:	993e                	add	s2,s2,a5
    800019e2:	040009b7          	lui	s3,0x4000
    800019e6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019e8:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800019ea:	00018a17          	auipc	s4,0x18
    800019ee:	3a6a0a13          	addi	s4,s4,934 # 80019d90 <tickslock>
    initlock(&p->lock, "proc");
    800019f2:	85da                	mv	a1,s6
    800019f4:	8526                	mv	a0,s1
    800019f6:	fffff097          	auipc	ra,0xfffff
    800019fa:	1b4080e7          	jalr	436(ra) # 80000baa <initlock>
    p->state = UNUSED;
    800019fe:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001a02:	415487b3          	sub	a5,s1,s5
    80001a06:	878d                	srai	a5,a5,0x3
    80001a08:	032787b3          	mul	a5,a5,s2
    80001a0c:	2785                	addiw	a5,a5,1
    80001a0e:	00d7979b          	slliw	a5,a5,0xd
    80001a12:	40f987b3          	sub	a5,s3,a5
    80001a16:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a18:	23848493          	addi	s1,s1,568
    80001a1c:	fd449be3          	bne	s1,s4,800019f2 <procinit+0x7a>
  }
}
    80001a20:	70e2                	ld	ra,56(sp)
    80001a22:	7442                	ld	s0,48(sp)
    80001a24:	74a2                	ld	s1,40(sp)
    80001a26:	7902                	ld	s2,32(sp)
    80001a28:	69e2                	ld	s3,24(sp)
    80001a2a:	6a42                	ld	s4,16(sp)
    80001a2c:	6aa2                	ld	s5,8(sp)
    80001a2e:	6b02                	ld	s6,0(sp)
    80001a30:	6121                	addi	sp,sp,64
    80001a32:	8082                	ret

0000000080001a34 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001a34:	1141                	addi	sp,sp,-16
    80001a36:	e406                	sd	ra,8(sp)
    80001a38:	e022                	sd	s0,0(sp)
    80001a3a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a3c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a3e:	2501                	sext.w	a0,a0
    80001a40:	60a2                	ld	ra,8(sp)
    80001a42:	6402                	ld	s0,0(sp)
    80001a44:	0141                	addi	sp,sp,16
    80001a46:	8082                	ret

0000000080001a48 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001a48:	1141                	addi	sp,sp,-16
    80001a4a:	e406                	sd	ra,8(sp)
    80001a4c:	e022                	sd	s0,0(sp)
    80001a4e:	0800                	addi	s0,sp,16
    80001a50:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a52:	2781                	sext.w	a5,a5
    80001a54:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a56:	0000f517          	auipc	a0,0xf
    80001a5a:	13a50513          	addi	a0,a0,314 # 80010b90 <cpus>
    80001a5e:	953e                	add	a0,a0,a5
    80001a60:	60a2                	ld	ra,8(sp)
    80001a62:	6402                	ld	s0,0(sp)
    80001a64:	0141                	addi	sp,sp,16
    80001a66:	8082                	ret

0000000080001a68 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001a68:	1101                	addi	sp,sp,-32
    80001a6a:	ec06                	sd	ra,24(sp)
    80001a6c:	e822                	sd	s0,16(sp)
    80001a6e:	e426                	sd	s1,8(sp)
    80001a70:	1000                	addi	s0,sp,32
  push_off();
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	180080e7          	jalr	384(ra) # 80000bf2 <push_off>
    80001a7a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a7c:	2781                	sext.w	a5,a5
    80001a7e:	079e                	slli	a5,a5,0x7
    80001a80:	0000f717          	auipc	a4,0xf
    80001a84:	0e070713          	addi	a4,a4,224 # 80010b60 <pid_lock>
    80001a88:	97ba                	add	a5,a5,a4
    80001a8a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	206080e7          	jalr	518(ra) # 80000c92 <pop_off>
  return p;
}
    80001a94:	8526                	mv	a0,s1
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	64a2                	ld	s1,8(sp)
    80001a9c:	6105                	addi	sp,sp,32
    80001a9e:	8082                	ret

0000000080001aa0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001aa0:	1141                	addi	sp,sp,-16
    80001aa2:	e406                	sd	ra,8(sp)
    80001aa4:	e022                	sd	s0,0(sp)
    80001aa6:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001aa8:	00000097          	auipc	ra,0x0
    80001aac:	fc0080e7          	jalr	-64(ra) # 80001a68 <myproc>
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	23e080e7          	jalr	574(ra) # 80000cee <release>

  if (first)
    80001ab8:	00007797          	auipc	a5,0x7
    80001abc:	da87a783          	lw	a5,-600(a5) # 80008860 <first.1>
    80001ac0:	eb89                	bnez	a5,80001ad2 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ac2:	00001097          	auipc	ra,0x1
    80001ac6:	19e080e7          	jalr	414(ra) # 80002c60 <usertrapret>
}
    80001aca:	60a2                	ld	ra,8(sp)
    80001acc:	6402                	ld	s0,0(sp)
    80001ace:	0141                	addi	sp,sp,16
    80001ad0:	8082                	ret
    first = 0;
    80001ad2:	00007797          	auipc	a5,0x7
    80001ad6:	d807a723          	sw	zero,-626(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001ada:	4505                	li	a0,1
    80001adc:	00002097          	auipc	ra,0x2
    80001ae0:	11a080e7          	jalr	282(ra) # 80003bf6 <fsinit>
    80001ae4:	bff9                	j	80001ac2 <forkret+0x22>

0000000080001ae6 <allocpid>:
{
    80001ae6:	1101                	addi	sp,sp,-32
    80001ae8:	ec06                	sd	ra,24(sp)
    80001aea:	e822                	sd	s0,16(sp)
    80001aec:	e426                	sd	s1,8(sp)
    80001aee:	e04a                	sd	s2,0(sp)
    80001af0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001af2:	0000f917          	auipc	s2,0xf
    80001af6:	06e90913          	addi	s2,s2,110 # 80010b60 <pid_lock>
    80001afa:	854a                	mv	a0,s2
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	142080e7          	jalr	322(ra) # 80000c3e <acquire>
  pid = nextpid;
    80001b04:	00007797          	auipc	a5,0x7
    80001b08:	d6478793          	addi	a5,a5,-668 # 80008868 <nextpid>
    80001b0c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b0e:	0014871b          	addiw	a4,s1,1
    80001b12:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b14:	854a                	mv	a0,s2
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	1d8080e7          	jalr	472(ra) # 80000cee <release>
}
    80001b1e:	8526                	mv	a0,s1
    80001b20:	60e2                	ld	ra,24(sp)
    80001b22:	6442                	ld	s0,16(sp)
    80001b24:	64a2                	ld	s1,8(sp)
    80001b26:	6902                	ld	s2,0(sp)
    80001b28:	6105                	addi	sp,sp,32
    80001b2a:	8082                	ret

0000000080001b2c <proc_pagetable>:
{
    80001b2c:	1101                	addi	sp,sp,-32
    80001b2e:	ec06                	sd	ra,24(sp)
    80001b30:	e822                	sd	s0,16(sp)
    80001b32:	e426                	sd	s1,8(sp)
    80001b34:	e04a                	sd	s2,0(sp)
    80001b36:	1000                	addi	s0,sp,32
    80001b38:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b3a:	00000097          	auipc	ra,0x0
    80001b3e:	87a080e7          	jalr	-1926(ra) # 800013b4 <uvmcreate>
    80001b42:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b44:	c121                	beqz	a0,80001b84 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b46:	4729                	li	a4,10
    80001b48:	00005697          	auipc	a3,0x5
    80001b4c:	4b868693          	addi	a3,a3,1208 # 80007000 <_trampoline>
    80001b50:	6605                	lui	a2,0x1
    80001b52:	040005b7          	lui	a1,0x4000
    80001b56:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b58:	05b2                	slli	a1,a1,0xc
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	5c0080e7          	jalr	1472(ra) # 8000111a <mappages>
    80001b62:	02054863          	bltz	a0,80001b92 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b66:	4719                	li	a4,6
    80001b68:	05893683          	ld	a3,88(s2)
    80001b6c:	6605                	lui	a2,0x1
    80001b6e:	020005b7          	lui	a1,0x2000
    80001b72:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b74:	05b6                	slli	a1,a1,0xd
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	5a2080e7          	jalr	1442(ra) # 8000111a <mappages>
    80001b80:	02054163          	bltz	a0,80001ba2 <proc_pagetable+0x76>
}
    80001b84:	8526                	mv	a0,s1
    80001b86:	60e2                	ld	ra,24(sp)
    80001b88:	6442                	ld	s0,16(sp)
    80001b8a:	64a2                	ld	s1,8(sp)
    80001b8c:	6902                	ld	s2,0(sp)
    80001b8e:	6105                	addi	sp,sp,32
    80001b90:	8082                	ret
    uvmfree(pagetable, 0);
    80001b92:	4581                	li	a1,0
    80001b94:	8526                	mv	a0,s1
    80001b96:	00000097          	auipc	ra,0x0
    80001b9a:	a38080e7          	jalr	-1480(ra) # 800015ce <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	b7d5                	j	80001b84 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba2:	4681                	li	a3,0
    80001ba4:	4605                	li	a2,1
    80001ba6:	040005b7          	lui	a1,0x4000
    80001baa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bac:	05b2                	slli	a1,a1,0xc
    80001bae:	8526                	mv	a0,s1
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	730080e7          	jalr	1840(ra) # 800012e0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bb8:	4581                	li	a1,0
    80001bba:	8526                	mv	a0,s1
    80001bbc:	00000097          	auipc	ra,0x0
    80001bc0:	a12080e7          	jalr	-1518(ra) # 800015ce <uvmfree>
    return 0;
    80001bc4:	4481                	li	s1,0
    80001bc6:	bf7d                	j	80001b84 <proc_pagetable+0x58>

0000000080001bc8 <proc_freepagetable>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	e04a                	sd	s2,0(sp)
    80001bd2:	1000                	addi	s0,sp,32
    80001bd4:	84aa                	mv	s1,a0
    80001bd6:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bd8:	4681                	li	a3,0
    80001bda:	4605                	li	a2,1
    80001bdc:	040005b7          	lui	a1,0x4000
    80001be0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001be2:	05b2                	slli	a1,a1,0xc
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	6fc080e7          	jalr	1788(ra) # 800012e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bec:	4681                	li	a3,0
    80001bee:	4605                	li	a2,1
    80001bf0:	020005b7          	lui	a1,0x2000
    80001bf4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bf6:	05b6                	slli	a1,a1,0xd
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	6e6080e7          	jalr	1766(ra) # 800012e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c02:	85ca                	mv	a1,s2
    80001c04:	8526                	mv	a0,s1
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	9c8080e7          	jalr	-1592(ra) # 800015ce <uvmfree>
}
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6902                	ld	s2,0(sp)
    80001c16:	6105                	addi	sp,sp,32
    80001c18:	8082                	ret

0000000080001c1a <freeproc>:
{
    80001c1a:	1101                	addi	sp,sp,-32
    80001c1c:	ec06                	sd	ra,24(sp)
    80001c1e:	e822                	sd	s0,16(sp)
    80001c20:	e426                	sd	s1,8(sp)
    80001c22:	1000                	addi	s0,sp,32
    80001c24:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c26:	6d28                	ld	a0,88(a0)
    80001c28:	c509                	beqz	a0,80001c32 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	e22080e7          	jalr	-478(ra) # 80000a4c <kfree>
  p->trapframe = 0;
    80001c32:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c36:	68a8                	ld	a0,80(s1)
    80001c38:	c511                	beqz	a0,80001c44 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c3a:	64ac                	ld	a1,72(s1)
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	f8c080e7          	jalr	-116(ra) # 80001bc8 <proc_freepagetable>
  p->pagetable = 0;
    80001c44:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c48:	0404b423          	sd	zero,72(s1)
  p->parent = 0;
    80001c4c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c50:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c54:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c58:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c5c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c60:	0004ac23          	sw	zero,24(s1)
}
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret

0000000080001c6e <allocproc>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	e04a                	sd	s2,0(sp)
    80001c78:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c7a:	0000f497          	auipc	s1,0xf
    80001c7e:	31648493          	addi	s1,s1,790 # 80010f90 <proc>
    80001c82:	00018917          	auipc	s2,0x18
    80001c86:	10e90913          	addi	s2,s2,270 # 80019d90 <tickslock>
    acquire(&p->lock);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	fb2080e7          	jalr	-78(ra) # 80000c3e <acquire>
    if (p->state == UNUSED)
    80001c94:	4c9c                	lw	a5,24(s1)
    80001c96:	cf81                	beqz	a5,80001cae <allocproc+0x40>
      release(&p->lock);
    80001c98:	8526                	mv	a0,s1
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	054080e7          	jalr	84(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ca2:	23848493          	addi	s1,s1,568
    80001ca6:	ff2492e3          	bne	s1,s2,80001c8a <allocproc+0x1c>
  return 0;
    80001caa:	4481                	li	s1,0
    80001cac:	a849                	j	80001d3e <allocproc+0xd0>
  p->pid = allocpid();
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	e38080e7          	jalr	-456(ra) # 80001ae6 <allocpid>
    80001cb6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cb8:	4785                	li	a5,1
    80001cba:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	e8e080e7          	jalr	-370(ra) # 80000b4a <kalloc>
    80001cc4:	892a                	mv	s2,a0
    80001cc6:	eca8                	sd	a0,88(s1)
    80001cc8:	c151                	beqz	a0,80001d4c <allocproc+0xde>
  p->pagetable = proc_pagetable(p);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	e60080e7          	jalr	-416(ra) # 80001b2c <proc_pagetable>
    80001cd4:	892a                	mv	s2,a0
    80001cd6:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001cd8:	c551                	beqz	a0,80001d64 <allocproc+0xf6>
  memset(&p->context, 0, sizeof(p->context));
    80001cda:	07000613          	li	a2,112
    80001cde:	4581                	li	a1,0
    80001ce0:	06048513          	addi	a0,s1,96
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	052080e7          	jalr	82(ra) # 80000d36 <memset>
  p->context.ra = (uint64)forkret;
    80001cec:	00000797          	auipc	a5,0x0
    80001cf0:	db478793          	addi	a5,a5,-588 # 80001aa0 <forkret>
    80001cf4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cf6:	60bc                	ld	a5,64(s1)
    80001cf8:	6705                	lui	a4,0x1
    80001cfa:	97ba                	add	a5,a5,a4
    80001cfc:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001cfe:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001d02:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001d06:	00007697          	auipc	a3,0x7
    80001d0a:	bea6a683          	lw	a3,-1046(a3) # 800088f0 <ticks>
    80001d0e:	16d4a623          	sw	a3,364(s1)
  for (int i = 0; i < 32; i++)
    80001d12:	17448793          	addi	a5,s1,372
    80001d16:	1f448713          	addi	a4,s1,500
    p->syscall_count[i] = 0;
    80001d1a:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 32; i++)
    80001d1e:	0791                	addi	a5,a5,4
    80001d20:	fee79de3          	bne	a5,a4,80001d1a <allocproc+0xac>
  p->tickets = 1; // By default, each process starts with 1 ticket.
    80001d24:	4785                	li	a5,1
    80001d26:	20f4ac23          	sw	a5,536(s1)
  p->creation_time = ticks;
    80001d2a:	1682                	slli	a3,a3,0x20
    80001d2c:	9281                	srli	a3,a3,0x20
    80001d2e:	22d4b023          	sd	a3,544(s1)
  p->priority_level = 0;
    80001d32:	2204a423          	sw	zero,552(s1)
  p->count = 0;
    80001d36:	2204a823          	sw	zero,560(s1)
  p->time_taken = 0;
    80001d3a:	2204a623          	sw	zero,556(s1)
}
    80001d3e:	8526                	mv	a0,s1
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6902                	ld	s2,0(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret
    freeproc(p);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	00000097          	auipc	ra,0x0
    80001d52:	ecc080e7          	jalr	-308(ra) # 80001c1a <freeproc>
    release(&p->lock);
    80001d56:	8526                	mv	a0,s1
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	f96080e7          	jalr	-106(ra) # 80000cee <release>
    return 0;
    80001d60:	84ca                	mv	s1,s2
    80001d62:	bff1                	j	80001d3e <allocproc+0xd0>
    freeproc(p);
    80001d64:	8526                	mv	a0,s1
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	eb4080e7          	jalr	-332(ra) # 80001c1a <freeproc>
    release(&p->lock);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	f7e080e7          	jalr	-130(ra) # 80000cee <release>
    return 0;
    80001d78:	84ca                	mv	s1,s2
    80001d7a:	b7d1                	j	80001d3e <allocproc+0xd0>

0000000080001d7c <userinit>:
{
    80001d7c:	1101                	addi	sp,sp,-32
    80001d7e:	ec06                	sd	ra,24(sp)
    80001d80:	e822                	sd	s0,16(sp)
    80001d82:	e426                	sd	s1,8(sp)
    80001d84:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	ee8080e7          	jalr	-280(ra) # 80001c6e <allocproc>
    80001d8e:	84aa                	mv	s1,a0
  initproc = p;
    80001d90:	00007797          	auipc	a5,0x7
    80001d94:	b4a7bc23          	sd	a0,-1192(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d98:	03400613          	li	a2,52
    80001d9c:	00007597          	auipc	a1,0x7
    80001da0:	ad458593          	addi	a1,a1,-1324 # 80008870 <initcode>
    80001da4:	6928                	ld	a0,80(a0)
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	63c080e7          	jalr	1596(ra) # 800013e2 <uvmfirst>
  p->sz = PGSIZE;
    80001dae:	6785                	lui	a5,0x1
    80001db0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001db2:	6cb8                	ld	a4,88(s1)
    80001db4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001db8:	6cb8                	ld	a4,88(s1)
    80001dba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dbc:	4641                	li	a2,16
    80001dbe:	00006597          	auipc	a1,0x6
    80001dc2:	42258593          	addi	a1,a1,1058 # 800081e0 <etext+0x1e0>
    80001dc6:	15848513          	addi	a0,s1,344
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	0c2080e7          	jalr	194(ra) # 80000e8c <safestrcpy>
  p->cwd = namei("/");
    80001dd2:	00006517          	auipc	a0,0x6
    80001dd6:	41e50513          	addi	a0,a0,1054 # 800081f0 <etext+0x1f0>
    80001dda:	00003097          	auipc	ra,0x3
    80001dde:	884080e7          	jalr	-1916(ra) # 8000465e <namei>
    80001de2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001de6:	478d                	li	a5,3
    80001de8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dea:	8526                	mv	a0,s1
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	f02080e7          	jalr	-254(ra) # 80000cee <release>
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret

0000000080001dfe <growproc>:
{
    80001dfe:	1101                	addi	sp,sp,-32
    80001e00:	ec06                	sd	ra,24(sp)
    80001e02:	e822                	sd	s0,16(sp)
    80001e04:	e426                	sd	s1,8(sp)
    80001e06:	e04a                	sd	s2,0(sp)
    80001e08:	1000                	addi	s0,sp,32
    80001e0a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	c5c080e7          	jalr	-932(ra) # 80001a68 <myproc>
    80001e14:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e16:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001e18:	01204c63          	bgtz	s2,80001e30 <growproc+0x32>
  else if (n < 0)
    80001e1c:	02094663          	bltz	s2,80001e48 <growproc+0x4a>
  p->sz = sz;
    80001e20:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e22:	4501                	li	a0,0
}
    80001e24:	60e2                	ld	ra,24(sp)
    80001e26:	6442                	ld	s0,16(sp)
    80001e28:	64a2                	ld	s1,8(sp)
    80001e2a:	6902                	ld	s2,0(sp)
    80001e2c:	6105                	addi	sp,sp,32
    80001e2e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e30:	4691                	li	a3,4
    80001e32:	00b90633          	add	a2,s2,a1
    80001e36:	6928                	ld	a0,80(a0)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	664080e7          	jalr	1636(ra) # 8000149c <uvmalloc>
    80001e40:	85aa                	mv	a1,a0
    80001e42:	fd79                	bnez	a0,80001e20 <growproc+0x22>
      return -1;
    80001e44:	557d                	li	a0,-1
    80001e46:	bff9                	j	80001e24 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e48:	00b90633          	add	a2,s2,a1
    80001e4c:	6928                	ld	a0,80(a0)
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	606080e7          	jalr	1542(ra) # 80001454 <uvmdealloc>
    80001e56:	85aa                	mv	a1,a0
    80001e58:	b7e1                	j	80001e20 <growproc+0x22>

0000000080001e5a <fork>:
{
    80001e5a:	7139                	addi	sp,sp,-64
    80001e5c:	fc06                	sd	ra,56(sp)
    80001e5e:	f822                	sd	s0,48(sp)
    80001e60:	f04a                	sd	s2,32(sp)
    80001e62:	e456                	sd	s5,8(sp)
    80001e64:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e66:	00000097          	auipc	ra,0x0
    80001e6a:	c02080e7          	jalr	-1022(ra) # 80001a68 <myproc>
    80001e6e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	dfe080e7          	jalr	-514(ra) # 80001c6e <allocproc>
    80001e78:	12050063          	beqz	a0,80001f98 <fork+0x13e>
    80001e7c:	e852                	sd	s4,16(sp)
    80001e7e:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e80:	048ab603          	ld	a2,72(s5)
    80001e84:	692c                	ld	a1,80(a0)
    80001e86:	050ab503          	ld	a0,80(s5)
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	77e080e7          	jalr	1918(ra) # 80001608 <uvmcopy>
    80001e92:	04054a63          	bltz	a0,80001ee6 <fork+0x8c>
    80001e96:	f426                	sd	s1,40(sp)
    80001e98:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e9a:	048ab783          	ld	a5,72(s5)
    80001e9e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ea2:	058ab683          	ld	a3,88(s5)
    80001ea6:	87b6                	mv	a5,a3
    80001ea8:	058a3703          	ld	a4,88(s4)
    80001eac:	12068693          	addi	a3,a3,288
    80001eb0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001eb4:	6788                	ld	a0,8(a5)
    80001eb6:	6b8c                	ld	a1,16(a5)
    80001eb8:	6f90                	ld	a2,24(a5)
    80001eba:	01073023          	sd	a6,0(a4)
    80001ebe:	e708                	sd	a0,8(a4)
    80001ec0:	eb0c                	sd	a1,16(a4)
    80001ec2:	ef10                	sd	a2,24(a4)
    80001ec4:	02078793          	addi	a5,a5,32
    80001ec8:	02070713          	addi	a4,a4,32
    80001ecc:	fed792e3          	bne	a5,a3,80001eb0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ed0:	058a3783          	ld	a5,88(s4)
    80001ed4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ed8:	0d0a8493          	addi	s1,s5,208
    80001edc:	0d0a0913          	addi	s2,s4,208
    80001ee0:	150a8993          	addi	s3,s5,336
    80001ee4:	a015                	j	80001f08 <fork+0xae>
    freeproc(np);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	d32080e7          	jalr	-718(ra) # 80001c1a <freeproc>
    release(&np->lock);
    80001ef0:	8552                	mv	a0,s4
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	dfc080e7          	jalr	-516(ra) # 80000cee <release>
    return -1;
    80001efa:	597d                	li	s2,-1
    80001efc:	6a42                	ld	s4,16(sp)
    80001efe:	a071                	j	80001f8a <fork+0x130>
  for (i = 0; i < NOFILE; i++)
    80001f00:	04a1                	addi	s1,s1,8
    80001f02:	0921                	addi	s2,s2,8
    80001f04:	01348b63          	beq	s1,s3,80001f1a <fork+0xc0>
    if (p->ofile[i])
    80001f08:	6088                	ld	a0,0(s1)
    80001f0a:	d97d                	beqz	a0,80001f00 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f0c:	00003097          	auipc	ra,0x3
    80001f10:	dd6080e7          	jalr	-554(ra) # 80004ce2 <filedup>
    80001f14:	00a93023          	sd	a0,0(s2)
    80001f18:	b7e5                	j	80001f00 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f1a:	150ab503          	ld	a0,336(s5)
    80001f1e:	00002097          	auipc	ra,0x2
    80001f22:	f1e080e7          	jalr	-226(ra) # 80003e3c <idup>
    80001f26:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f2a:	4641                	li	a2,16
    80001f2c:	158a8593          	addi	a1,s5,344
    80001f30:	158a0513          	addi	a0,s4,344
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	f58080e7          	jalr	-168(ra) # 80000e8c <safestrcpy>
  pid = np->pid;
    80001f3c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f40:	8552                	mv	a0,s4
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	dac080e7          	jalr	-596(ra) # 80000cee <release>
  acquire(&wait_lock);
    80001f4a:	0000f497          	auipc	s1,0xf
    80001f4e:	c2e48493          	addi	s1,s1,-978 # 80010b78 <wait_lock>
    80001f52:	8526                	mv	a0,s1
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	cea080e7          	jalr	-790(ra) # 80000c3e <acquire>
  np->parent = p;
    80001f5c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	d8c080e7          	jalr	-628(ra) # 80000cee <release>
  acquire(&np->lock);
    80001f6a:	8552                	mv	a0,s4
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	cd2080e7          	jalr	-814(ra) # 80000c3e <acquire>
  np->state = RUNNABLE;
    80001f74:	478d                	li	a5,3
    80001f76:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f7a:	8552                	mv	a0,s4
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d72080e7          	jalr	-654(ra) # 80000cee <release>
  return pid;
    80001f84:	74a2                	ld	s1,40(sp)
    80001f86:	69e2                	ld	s3,24(sp)
    80001f88:	6a42                	ld	s4,16(sp)
}
    80001f8a:	854a                	mv	a0,s2
    80001f8c:	70e2                	ld	ra,56(sp)
    80001f8e:	7442                	ld	s0,48(sp)
    80001f90:	7902                	ld	s2,32(sp)
    80001f92:	6aa2                	ld	s5,8(sp)
    80001f94:	6121                	addi	sp,sp,64
    80001f96:	8082                	ret
    return -1;
    80001f98:	597d                	li	s2,-1
    80001f9a:	bfc5                	j	80001f8a <fork+0x130>

0000000080001f9c <rand>:
{
    80001f9c:	1141                	addi	sp,sp,-16
    80001f9e:	e406                	sd	ra,8(sp)
    80001fa0:	e022                	sd	s0,0(sp)
    80001fa2:	0800                	addi	s0,sp,16
  next = next * 1664525 + 1013904223;
    80001fa4:	00007697          	auipc	a3,0x7
    80001fa8:	8c068693          	addi	a3,a3,-1856 # 80008864 <next>
    80001fac:	429c                	lw	a5,0(a3)
    80001fae:	00196737          	lui	a4,0x196
    80001fb2:	60d7071b          	addiw	a4,a4,1549 # 19660d <_entry-0x7fe699f3>
    80001fb6:	02f7073b          	mulw	a4,a4,a5
    80001fba:	3c6ef7b7          	lui	a5,0x3c6ef
    80001fbe:	35f7879b          	addiw	a5,a5,863 # 3c6ef35f <_entry-0x43910ca1>
    80001fc2:	9fb9                	addw	a5,a5,a4
    80001fc4:	c29c                	sw	a5,0(a3)
  return (next % RAND_MAX);
    80001fc6:	02079713          	slli	a4,a5,0x20
    80001fca:	9301                	srli	a4,a4,0x20
    80001fcc:	00171693          	slli	a3,a4,0x1
    80001fd0:	96ba                	add	a3,a3,a4
    80001fd2:	9281                	srli	a3,a3,0x20
    80001fd4:	40d7873b          	subw	a4,a5,a3
    80001fd8:	0017571b          	srliw	a4,a4,0x1
    80001fdc:	9f35                	addw	a4,a4,a3
    80001fde:	01e7571b          	srliw	a4,a4,0x1e
    80001fe2:	01f7151b          	slliw	a0,a4,0x1f
    80001fe6:	9d19                	subw	a0,a0,a4
}
    80001fe8:	40a7853b          	subw	a0,a5,a0
    80001fec:	60a2                	ld	ra,8(sp)
    80001fee:	6402                	ld	s0,0(sp)
    80001ff0:	0141                	addi	sp,sp,16
    80001ff2:	8082                	ret

0000000080001ff4 <srand>:
{
    80001ff4:	1141                	addi	sp,sp,-16
    80001ff6:	e406                	sd	ra,8(sp)
    80001ff8:	e022                	sd	s0,0(sp)
    80001ffa:	0800                	addi	s0,sp,16
  next = seed;
    80001ffc:	00007797          	auipc	a5,0x7
    80002000:	86a7a423          	sw	a0,-1944(a5) # 80008864 <next>
}
    80002004:	60a2                	ld	ra,8(sp)
    80002006:	6402                	ld	s0,0(sp)
    80002008:	0141                	addi	sp,sp,16
    8000200a:	8082                	ret

000000008000200c <round_robin_scheduler>:
{
    8000200c:	7139                	addi	sp,sp,-64
    8000200e:	fc06                	sd	ra,56(sp)
    80002010:	f822                	sd	s0,48(sp)
    80002012:	f426                	sd	s1,40(sp)
    80002014:	f04a                	sd	s2,32(sp)
    80002016:	ec4e                	sd	s3,24(sp)
    80002018:	e852                	sd	s4,16(sp)
    8000201a:	e456                	sd	s5,8(sp)
    8000201c:	e05a                	sd	s6,0(sp)
    8000201e:	0080                	addi	s0,sp,64
    80002020:	8792                	mv	a5,tp
  int id = r_tp();
    80002022:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002024:	00779a93          	slli	s5,a5,0x7
    80002028:	0000f717          	auipc	a4,0xf
    8000202c:	b3870713          	addi	a4,a4,-1224 # 80010b60 <pid_lock>
    80002030:	9756                	add	a4,a4,s5
    80002032:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002036:	0000f717          	auipc	a4,0xf
    8000203a:	b6270713          	addi	a4,a4,-1182 # 80010b98 <cpus+0x8>
    8000203e:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80002040:	498d                	li	s3,3
        p->state = RUNNING;
    80002042:	4b11                	li	s6,4
        c->proc = p;
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	0000fa17          	auipc	s4,0xf
    8000204a:	b1aa0a13          	addi	s4,s4,-1254 # 80010b60 <pid_lock>
    8000204e:	9a3e                	add	s4,s4,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002050:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002054:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002058:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000205c:	0000f497          	auipc	s1,0xf
    80002060:	f3448493          	addi	s1,s1,-204 # 80010f90 <proc>
    80002064:	00018917          	auipc	s2,0x18
    80002068:	d2c90913          	addi	s2,s2,-724 # 80019d90 <tickslock>
    8000206c:	a811                	j	80002080 <round_robin_scheduler+0x74>
      release(&p->lock);
    8000206e:	8526                	mv	a0,s1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	c7e080e7          	jalr	-898(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002078:	23848493          	addi	s1,s1,568
    8000207c:	fd248ae3          	beq	s1,s2,80002050 <round_robin_scheduler+0x44>
      acquire(&p->lock);
    80002080:	8526                	mv	a0,s1
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	bbc080e7          	jalr	-1092(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    8000208a:	4c9c                	lw	a5,24(s1)
    8000208c:	ff3791e3          	bne	a5,s3,8000206e <round_robin_scheduler+0x62>
        p->state = RUNNING;
    80002090:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002094:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002098:	06048593          	addi	a1,s1,96
    8000209c:	8556                	mv	a0,s5
    8000209e:	00001097          	auipc	ra,0x1
    800020a2:	b14080e7          	jalr	-1260(ra) # 80002bb2 <swtch>
        c->proc = 0;
    800020a6:	020a3823          	sd	zero,48(s4)
    800020aa:	b7d1                	j	8000206e <round_robin_scheduler+0x62>

00000000800020ac <lottery_scheduler>:
{
    800020ac:	7139                	addi	sp,sp,-64
    800020ae:	fc06                	sd	ra,56(sp)
    800020b0:	f822                	sd	s0,48(sp)
    800020b2:	f426                	sd	s1,40(sp)
    800020b4:	f04a                	sd	s2,32(sp)
    800020b6:	ec4e                	sd	s3,24(sp)
    800020b8:	e456                	sd	s5,8(sp)
    800020ba:	e05a                	sd	s6,0(sp)
    800020bc:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    800020be:	8a92                	mv	s5,tp
  int id = r_tp();
    800020c0:	2a81                	sext.w	s5,s5
  c->proc = 0;
    800020c2:	007a9713          	slli	a4,s5,0x7
    800020c6:	0000f797          	auipc	a5,0xf
    800020ca:	a9a78793          	addi	a5,a5,-1382 # 80010b60 <pid_lock>
    800020ce:	97ba                	add	a5,a5,a4
    800020d0:	0207b823          	sd	zero,48(a5)
  int total_tickets = 0;
    800020d4:	4b01                	li	s6,0
  for (p = proc; p < &proc[NPROC]; p++)
    800020d6:	0000f497          	auipc	s1,0xf
    800020da:	eba48493          	addi	s1,s1,-326 # 80010f90 <proc>
    if (p->state == RUNNABLE)
    800020de:	498d                	li	s3,3
  for (p = proc; p < &proc[NPROC]; p++)
    800020e0:	00018917          	auipc	s2,0x18
    800020e4:	cb090913          	addi	s2,s2,-848 # 80019d90 <tickslock>
    800020e8:	a811                	j	800020fc <lottery_scheduler+0x50>
    release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	c02080e7          	jalr	-1022(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800020f4:	23848493          	addi	s1,s1,568
    800020f8:	01248f63          	beq	s1,s2,80002116 <lottery_scheduler+0x6a>
    acquire(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	b40080e7          	jalr	-1216(ra) # 80000c3e <acquire>
    if (p->state == RUNNABLE)
    80002106:	4c9c                	lw	a5,24(s1)
    80002108:	ff3791e3          	bne	a5,s3,800020ea <lottery_scheduler+0x3e>
      total_tickets += p->tickets;
    8000210c:	2184a783          	lw	a5,536(s1)
    80002110:	01678b3b          	addw	s6,a5,s6
    80002114:	bfd9                	j	800020ea <lottery_scheduler+0x3e>
  if (total_tickets == 0)
    80002116:	000b1b63          	bnez	s6,8000212c <lottery_scheduler+0x80>
}
    8000211a:	70e2                	ld	ra,56(sp)
    8000211c:	7442                	ld	s0,48(sp)
    8000211e:	74a2                	ld	s1,40(sp)
    80002120:	7902                	ld	s2,32(sp)
    80002122:	69e2                	ld	s3,24(sp)
    80002124:	6aa2                	ld	s5,8(sp)
    80002126:	6b02                	ld	s6,0(sp)
    80002128:	6121                	addi	sp,sp,64
    8000212a:	8082                	ret
    8000212c:	e852                	sd	s4,16(sp)
  int winning_ticket = rand() % total_tickets;
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	e6e080e7          	jalr	-402(ra) # 80001f9c <rand>
    80002136:	03657b3b          	remuw	s6,a0,s6
  int current_sum = 0;
    8000213a:	4901                	li	s2,0
  for (p = proc; p < &proc[NPROC]; p++)
    8000213c:	0000f497          	auipc	s1,0xf
    80002140:	e5448493          	addi	s1,s1,-428 # 80010f90 <proc>
    if (p->state == RUNNABLE)
    80002144:	498d                	li	s3,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002146:	00018a17          	auipc	s4,0x18
    8000214a:	c4aa0a13          	addi	s4,s4,-950 # 80019d90 <tickslock>
    8000214e:	a811                	j	80002162 <lottery_scheduler+0xb6>
    release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b9c080e7          	jalr	-1124(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000215a:	23848493          	addi	s1,s1,568
    8000215e:	05448e63          	beq	s1,s4,800021ba <lottery_scheduler+0x10e>
    acquire(&p->lock);
    80002162:	8526                	mv	a0,s1
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	ada080e7          	jalr	-1318(ra) # 80000c3e <acquire>
    if (p->state == RUNNABLE)
    8000216c:	4c9c                	lw	a5,24(s1)
    8000216e:	ff3791e3          	bne	a5,s3,80002150 <lottery_scheduler+0xa4>
      current_sum += p->tickets;
    80002172:	2184a783          	lw	a5,536(s1)
    80002176:	0127893b          	addw	s2,a5,s2
      if (current_sum > winning_ticket)
    8000217a:	fd2b5be3          	bge	s6,s2,80002150 <lottery_scheduler+0xa4>
        p->state = RUNNING;
    8000217e:	4791                	li	a5,4
    80002180:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    80002182:	0a9e                	slli	s5,s5,0x7
    80002184:	0000f917          	auipc	s2,0xf
    80002188:	9dc90913          	addi	s2,s2,-1572 # 80010b60 <pid_lock>
    8000218c:	9956                	add	s2,s2,s5
    8000218e:	02993823          	sd	s1,48(s2)
        swtch(&c->context, &p->context);
    80002192:	06048593          	addi	a1,s1,96
    80002196:	0000f517          	auipc	a0,0xf
    8000219a:	a0250513          	addi	a0,a0,-1534 # 80010b98 <cpus+0x8>
    8000219e:	9556                	add	a0,a0,s5
    800021a0:	00001097          	auipc	ra,0x1
    800021a4:	a12080e7          	jalr	-1518(ra) # 80002bb2 <swtch>
        c->proc = 0;
    800021a8:	02093823          	sd	zero,48(s2)
        release(&p->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	b40080e7          	jalr	-1216(ra) # 80000cee <release>
        break;
    800021b6:	6a42                	ld	s4,16(sp)
    800021b8:	b78d                	j	8000211a <lottery_scheduler+0x6e>
    800021ba:	6a42                	ld	s4,16(sp)
    800021bc:	bfb9                	j	8000211a <lottery_scheduler+0x6e>

00000000800021be <mlfq_scheduler>:
{
    800021be:	711d                	addi	sp,sp,-96
    800021c0:	ec86                	sd	ra,88(sp)
    800021c2:	e8a2                	sd	s0,80(sp)
    800021c4:	e4a6                	sd	s1,72(sp)
    800021c6:	e0ca                	sd	s2,64(sp)
    800021c8:	fc4e                	sd	s3,56(sp)
    800021ca:	f852                	sd	s4,48(sp)
    800021cc:	f456                	sd	s5,40(sp)
    800021ce:	f05a                	sd	s6,32(sp)
    800021d0:	ec5e                	sd	s7,24(sp)
    800021d2:	e862                	sd	s8,16(sp)
    800021d4:	e466                	sd	s9,8(sp)
    800021d6:	e06a                	sd	s10,0(sp)
    800021d8:	1080                	addi	s0,sp,96
    800021da:	8c92                	mv	s9,tp
  int id = r_tp();
    800021dc:	2c81                	sext.w	s9,s9
  c->proc = 0;
    800021de:	007c9713          	slli	a4,s9,0x7
    800021e2:	0000f797          	auipc	a5,0xf
    800021e6:	97e78793          	addi	a5,a5,-1666 # 80010b60 <pid_lock>
    800021ea:	97ba                	add	a5,a5,a4
    800021ec:	0207b823          	sd	zero,48(a5)
        swtch(&c->context, &high_priority_proc->context); // Context switch
    800021f0:	0000f797          	auipc	a5,0xf
    800021f4:	9a878793          	addi	a5,a5,-1624 # 80010b98 <cpus+0x8>
    800021f8:	97ba                	add	a5,a5,a4
    800021fa:	8d3e                	mv	s10,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800021fc:	00018997          	auipc	s3,0x18
    80002200:	b9498993          	addi	s3,s3,-1132 # 80019d90 <tickslock>
        if (ticks % 48 == 0)
    80002204:	00006b97          	auipc	s7,0x6
    80002208:	6ecb8b93          	addi	s7,s7,1772 # 800088f0 <ticks>
    8000220c:	000abb37          	lui	s6,0xab
    80002210:	aabb0b13          	addi	s6,s6,-1365 # aaaab <_entry-0x7ff55555>
    80002214:	0b32                	slli	s6,s6,0xc
    80002216:	aabb0b13          	addi	s6,s6,-1365
    8000221a:	a8f1                	j	800022f6 <mlfq_scheduler+0x138>
    8000221c:	000ba683          	lw	a3,0(s7)
    80002220:	02069793          	slli	a5,a3,0x20
    80002224:	9381                	srli	a5,a5,0x20
    80002226:	036787b3          	mul	a5,a5,s6
    8000222a:	9395                	srli	a5,a5,0x25
    8000222c:	0017971b          	slliw	a4,a5,0x1
    80002230:	9fb9                	addw	a5,a5,a4
    80002232:	0047979b          	slliw	a5,a5,0x4
    80002236:	9e9d                	subw	a3,a3,a5
    80002238:	ea9d                	bnez	a3,8000226e <mlfq_scheduler+0xb0>
          p->time_taken = 0;
    8000223a:	2204a623          	sw	zero,556(s1)
          p->priority_level = 0;
    8000223e:	2204a423          	sw	zero,552(s1)
        if (p->time_taken >= max_time_per_priority[p->priority_level])
    80002242:	038aa783          	lw	a5,56(s5)
    80002246:	04f05a63          	blez	a5,8000229a <mlfq_scheduler+0xdc>
        if (high_priority_proc == 0)
    8000224a:	0a0a0863          	beqz	s4,800022fa <mlfq_scheduler+0x13c>
        else if (high_priority_proc->priority_level > p->priority_level)
    8000224e:	228a2703          	lw	a4,552(s4)
    80002252:	2284a783          	lw	a5,552(s1)
    80002256:	0ae7c463          	blt	a5,a4,800022fe <mlfq_scheduler+0x140>
        else if (high_priority_proc->priority_level == p->priority_level)
    8000225a:	0af71363          	bne	a4,a5,80002300 <mlfq_scheduler+0x142>
          if (high_priority_proc->time_taken < p->time_taken)
    8000225e:	22ca2703          	lw	a4,556(s4)
    80002262:	22c4a783          	lw	a5,556(s1)
    80002266:	08f75d63          	bge	a4,a5,80002300 <mlfq_scheduler+0x142>
            high_priority_proc = p;
    8000226a:	8a26                	mv	s4,s1
    8000226c:	a851                	j	80002300 <mlfq_scheduler+0x142>
        if (p->time_taken >= max_time_per_priority[p->priority_level])
    8000226e:	2284a783          	lw	a5,552(s1)
    80002272:	00279713          	slli	a4,a5,0x2
    80002276:	9756                	add	a4,a4,s5
    80002278:	22c4a683          	lw	a3,556(s1)
    8000227c:	5f18                	lw	a4,56(a4)
    8000227e:	fce6c6e3          	blt	a3,a4,8000224a <mlfq_scheduler+0x8c>
          if (p->priority_level < 3)
    80002282:	00fc5d63          	bge	s8,a5,8000229c <mlfq_scheduler+0xde>
          else if (p->priority_level == 3)
    80002286:	fd2792e3          	bne	a5,s2,8000224a <mlfq_scheduler+0x8c>
            p->time_taken = 0;
    8000228a:	2204a623          	sw	zero,556(s1)
            p->count++;
    8000228e:	2304a783          	lw	a5,560(s1)
    80002292:	2785                	addiw	a5,a5,1
    80002294:	22f4a823          	sw	a5,560(s1)
    80002298:	bf4d                	j	8000224a <mlfq_scheduler+0x8c>
        if (p->time_taken >= max_time_per_priority[p->priority_level])
    8000229a:	4781                	li	a5,0
            p->time_taken = 0;
    8000229c:	2204a623          	sw	zero,556(s1)
            p->priority_level++; // Demote to lower priority
    800022a0:	2785                	addiw	a5,a5,1
    800022a2:	22f4a423          	sw	a5,552(s1)
    800022a6:	b755                	j	8000224a <mlfq_scheduler+0x8c>
      acquire(&high_priority_proc->lock); // Acquire lock before running the process
    800022a8:	8952                	mv	s2,s4
    800022aa:	8552                	mv	a0,s4
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	992080e7          	jalr	-1646(ra) # 80000c3e <acquire>
      if (high_priority_proc->state == RUNNABLE)
    800022b4:	018a2703          	lw	a4,24(s4)
    800022b8:	478d                	li	a5,3
    800022ba:	02f71963          	bne	a4,a5,800022ec <mlfq_scheduler+0x12e>
        high_priority_proc->count = 0;
    800022be:	220a2823          	sw	zero,560(s4)
        high_priority_proc->state = RUNNING;
    800022c2:	4791                	li	a5,4
    800022c4:	00fa2c23          	sw	a5,24(s4)
        c->proc = high_priority_proc;
    800022c8:	007c9793          	slli	a5,s9,0x7
    800022cc:	0000f497          	auipc	s1,0xf
    800022d0:	89448493          	addi	s1,s1,-1900 # 80010b60 <pid_lock>
    800022d4:	94be                	add	s1,s1,a5
    800022d6:	0344b823          	sd	s4,48(s1)
        swtch(&c->context, &high_priority_proc->context); // Context switch
    800022da:	060a0593          	addi	a1,s4,96
    800022de:	856a                	mv	a0,s10
    800022e0:	00001097          	auipc	ra,0x1
    800022e4:	8d2080e7          	jalr	-1838(ra) # 80002bb2 <swtch>
        c->proc = 0;                                      // Clear CPU process pointer
    800022e8:	0204b823          	sd	zero,48(s1)
      release(&high_priority_proc->lock); // Release the lock after switching
    800022ec:	854a                	mv	a0,s2
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	a00080e7          	jalr	-1536(ra) # 80000cee <release>
      if (p->state == RUNNABLE)
    800022f6:	490d                	li	s2,3
    800022f8:	a081                	j	80002338 <mlfq_scheduler+0x17a>
          high_priority_proc = p; // Select this process to run
    800022fa:	8a26                	mv	s4,s1
    800022fc:	a011                	j	80002300 <mlfq_scheduler+0x142>
          high_priority_proc = p;
    800022fe:	8a26                	mv	s4,s1
      release(&p->lock); // Release the lock after checking/modifying the process
    80002300:	8526                	mv	a0,s1
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	9ec080e7          	jalr	-1556(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000230a:	23848493          	addi	s1,s1,568
    8000230e:	f9348de3          	beq	s1,s3,800022a8 <mlfq_scheduler+0xea>
      acquire(&p->lock); // Acquire the lock first
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	92a080e7          	jalr	-1750(ra) # 80000c3e <acquire>
      if (p->state == RUNNABLE)
    8000231c:	4c9c                	lw	a5,24(s1)
    8000231e:	ef278fe3          	beq	a5,s2,8000221c <mlfq_scheduler+0x5e>
      release(&p->lock); // Release the lock after checking/modifying the process
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	9ca080e7          	jalr	-1590(ra) # 80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000232c:	23848493          	addi	s1,s1,568
    80002330:	ff3491e3          	bne	s1,s3,80002312 <mlfq_scheduler+0x154>
    if (high_priority_proc != 0)
    80002334:	f60a1ae3          	bnez	s4,800022a8 <mlfq_scheduler+0xea>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002338:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000233c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002340:	10079073          	csrw	sstatus,a5
    struct proc *high_priority_proc = 0;
    80002344:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002346:	0000f497          	auipc	s1,0xf
    8000234a:	c4a48493          	addi	s1,s1,-950 # 80010f90 <proc>
        if (p->time_taken >= max_time_per_priority[p->priority_level])
    8000234e:	00006a97          	auipc	s5,0x6
    80002352:	522a8a93          	addi	s5,s5,1314 # 80008870 <initcode>
          if (p->priority_level < 3)
    80002356:	4c09                	li	s8,2
    80002358:	bf6d                	j	80002312 <mlfq_scheduler+0x154>

000000008000235a <scheduler>:
{
    8000235a:	1141                	addi	sp,sp,-16
    8000235c:	e406                	sd	ra,8(sp)
    8000235e:	e022                	sd	s0,0(sp)
    80002360:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002362:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002366:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000236a:	10079073          	csrw	sstatus,a5
    mlfq_scheduler();
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	e50080e7          	jalr	-432(ra) # 800021be <mlfq_scheduler>

0000000080002376 <sched>:
{
    80002376:	7179                	addi	sp,sp,-48
    80002378:	f406                	sd	ra,40(sp)
    8000237a:	f022                	sd	s0,32(sp)
    8000237c:	ec26                	sd	s1,24(sp)
    8000237e:	e84a                	sd	s2,16(sp)
    80002380:	e44e                	sd	s3,8(sp)
    80002382:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	6e4080e7          	jalr	1764(ra) # 80001a68 <myproc>
    8000238c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	836080e7          	jalr	-1994(ra) # 80000bc4 <holding>
    80002396:	c93d                	beqz	a0,8000240c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002398:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000239a:	2781                	sext.w	a5,a5
    8000239c:	079e                	slli	a5,a5,0x7
    8000239e:	0000e717          	auipc	a4,0xe
    800023a2:	7c270713          	addi	a4,a4,1986 # 80010b60 <pid_lock>
    800023a6:	97ba                	add	a5,a5,a4
    800023a8:	0a87a703          	lw	a4,168(a5)
    800023ac:	4785                	li	a5,1
    800023ae:	06f71763          	bne	a4,a5,8000241c <sched+0xa6>
  if (p->state == RUNNING)
    800023b2:	4c98                	lw	a4,24(s1)
    800023b4:	4791                	li	a5,4
    800023b6:	06f70b63          	beq	a4,a5,8000242c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023be:	8b89                	andi	a5,a5,2
  if (intr_get())
    800023c0:	efb5                	bnez	a5,8000243c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023c2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023c4:	0000e917          	auipc	s2,0xe
    800023c8:	79c90913          	addi	s2,s2,1948 # 80010b60 <pid_lock>
    800023cc:	2781                	sext.w	a5,a5
    800023ce:	079e                	slli	a5,a5,0x7
    800023d0:	97ca                	add	a5,a5,s2
    800023d2:	0ac7a983          	lw	s3,172(a5)
    800023d6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023d8:	2781                	sext.w	a5,a5
    800023da:	079e                	slli	a5,a5,0x7
    800023dc:	0000e597          	auipc	a1,0xe
    800023e0:	7bc58593          	addi	a1,a1,1980 # 80010b98 <cpus+0x8>
    800023e4:	95be                	add	a1,a1,a5
    800023e6:	06048513          	addi	a0,s1,96
    800023ea:	00000097          	auipc	ra,0x0
    800023ee:	7c8080e7          	jalr	1992(ra) # 80002bb2 <swtch>
    800023f2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023f4:	2781                	sext.w	a5,a5
    800023f6:	079e                	slli	a5,a5,0x7
    800023f8:	993e                	add	s2,s2,a5
    800023fa:	0b392623          	sw	s3,172(s2)
}
    800023fe:	70a2                	ld	ra,40(sp)
    80002400:	7402                	ld	s0,32(sp)
    80002402:	64e2                	ld	s1,24(sp)
    80002404:	6942                	ld	s2,16(sp)
    80002406:	69a2                	ld	s3,8(sp)
    80002408:	6145                	addi	sp,sp,48
    8000240a:	8082                	ret
    panic("sched p->lock");
    8000240c:	00006517          	auipc	a0,0x6
    80002410:	dec50513          	addi	a0,a0,-532 # 800081f8 <etext+0x1f8>
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	14c080e7          	jalr	332(ra) # 80000560 <panic>
    panic("sched locks");
    8000241c:	00006517          	auipc	a0,0x6
    80002420:	dec50513          	addi	a0,a0,-532 # 80008208 <etext+0x208>
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	13c080e7          	jalr	316(ra) # 80000560 <panic>
    panic("sched running");
    8000242c:	00006517          	auipc	a0,0x6
    80002430:	dec50513          	addi	a0,a0,-532 # 80008218 <etext+0x218>
    80002434:	ffffe097          	auipc	ra,0xffffe
    80002438:	12c080e7          	jalr	300(ra) # 80000560 <panic>
    panic("sched interruptible");
    8000243c:	00006517          	auipc	a0,0x6
    80002440:	dec50513          	addi	a0,a0,-532 # 80008228 <etext+0x228>
    80002444:	ffffe097          	auipc	ra,0xffffe
    80002448:	11c080e7          	jalr	284(ra) # 80000560 <panic>

000000008000244c <yield>:
{
    8000244c:	1101                	addi	sp,sp,-32
    8000244e:	ec06                	sd	ra,24(sp)
    80002450:	e822                	sd	s0,16(sp)
    80002452:	e426                	sd	s1,8(sp)
    80002454:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	612080e7          	jalr	1554(ra) # 80001a68 <myproc>
    8000245e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	7de080e7          	jalr	2014(ra) # 80000c3e <acquire>
  p->state = RUNNABLE;
    80002468:	478d                	li	a5,3
    8000246a:	cc9c                	sw	a5,24(s1)
  sched();
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	f0a080e7          	jalr	-246(ra) # 80002376 <sched>
  release(&p->lock);
    80002474:	8526                	mv	a0,s1
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	878080e7          	jalr	-1928(ra) # 80000cee <release>
}
    8000247e:	60e2                	ld	ra,24(sp)
    80002480:	6442                	ld	s0,16(sp)
    80002482:	64a2                	ld	s1,8(sp)
    80002484:	6105                	addi	sp,sp,32
    80002486:	8082                	ret

0000000080002488 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002488:	7179                	addi	sp,sp,-48
    8000248a:	f406                	sd	ra,40(sp)
    8000248c:	f022                	sd	s0,32(sp)
    8000248e:	ec26                	sd	s1,24(sp)
    80002490:	e84a                	sd	s2,16(sp)
    80002492:	e44e                	sd	s3,8(sp)
    80002494:	1800                	addi	s0,sp,48
    80002496:	89aa                	mv	s3,a0
    80002498:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	5ce080e7          	jalr	1486(ra) # 80001a68 <myproc>
    800024a2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	79a080e7          	jalr	1946(ra) # 80000c3e <acquire>
  release(lk);
    800024ac:	854a                	mv	a0,s2
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	840080e7          	jalr	-1984(ra) # 80000cee <release>

  // Go to sleep.
  p->chan = chan;
    800024b6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024ba:	4789                	li	a5,2
    800024bc:	cc9c                	sw	a5,24(s1)

  sched();
    800024be:	00000097          	auipc	ra,0x0
    800024c2:	eb8080e7          	jalr	-328(ra) # 80002376 <sched>

  // Tidy up.
  p->chan = 0;
    800024c6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	822080e7          	jalr	-2014(ra) # 80000cee <release>
  acquire(lk);
    800024d4:	854a                	mv	a0,s2
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	768080e7          	jalr	1896(ra) # 80000c3e <acquire>
}
    800024de:	70a2                	ld	ra,40(sp)
    800024e0:	7402                	ld	s0,32(sp)
    800024e2:	64e2                	ld	s1,24(sp)
    800024e4:	6942                	ld	s2,16(sp)
    800024e6:	69a2                	ld	s3,8(sp)
    800024e8:	6145                	addi	sp,sp,48
    800024ea:	8082                	ret

00000000800024ec <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024ec:	7139                	addi	sp,sp,-64
    800024ee:	fc06                	sd	ra,56(sp)
    800024f0:	f822                	sd	s0,48(sp)
    800024f2:	f426                	sd	s1,40(sp)
    800024f4:	f04a                	sd	s2,32(sp)
    800024f6:	ec4e                	sd	s3,24(sp)
    800024f8:	e852                	sd	s4,16(sp)
    800024fa:	e456                	sd	s5,8(sp)
    800024fc:	0080                	addi	s0,sp,64
    800024fe:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002500:	0000f497          	auipc	s1,0xf
    80002504:	a9048493          	addi	s1,s1,-1392 # 80010f90 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002508:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000250a:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    8000250c:	00018917          	auipc	s2,0x18
    80002510:	88490913          	addi	s2,s2,-1916 # 80019d90 <tickslock>
    80002514:	a811                	j	80002528 <wakeup+0x3c>
      }
      release(&p->lock);
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	7d6080e7          	jalr	2006(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002520:	23848493          	addi	s1,s1,568
    80002524:	03248663          	beq	s1,s2,80002550 <wakeup+0x64>
    if (p != myproc())
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	540080e7          	jalr	1344(ra) # 80001a68 <myproc>
    80002530:	fea488e3          	beq	s1,a0,80002520 <wakeup+0x34>
      acquire(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	708080e7          	jalr	1800(ra) # 80000c3e <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000253e:	4c9c                	lw	a5,24(s1)
    80002540:	fd379be3          	bne	a5,s3,80002516 <wakeup+0x2a>
    80002544:	709c                	ld	a5,32(s1)
    80002546:	fd4798e3          	bne	a5,s4,80002516 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000254a:	0154ac23          	sw	s5,24(s1)
    8000254e:	b7e1                	j	80002516 <wakeup+0x2a>
    }
  }
}
    80002550:	70e2                	ld	ra,56(sp)
    80002552:	7442                	ld	s0,48(sp)
    80002554:	74a2                	ld	s1,40(sp)
    80002556:	7902                	ld	s2,32(sp)
    80002558:	69e2                	ld	s3,24(sp)
    8000255a:	6a42                	ld	s4,16(sp)
    8000255c:	6aa2                	ld	s5,8(sp)
    8000255e:	6121                	addi	sp,sp,64
    80002560:	8082                	ret

0000000080002562 <reparent>:
{
    80002562:	7179                	addi	sp,sp,-48
    80002564:	f406                	sd	ra,40(sp)
    80002566:	f022                	sd	s0,32(sp)
    80002568:	ec26                	sd	s1,24(sp)
    8000256a:	e84a                	sd	s2,16(sp)
    8000256c:	e44e                	sd	s3,8(sp)
    8000256e:	e052                	sd	s4,0(sp)
    80002570:	1800                	addi	s0,sp,48
    80002572:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002574:	0000f497          	auipc	s1,0xf
    80002578:	a1c48493          	addi	s1,s1,-1508 # 80010f90 <proc>
      pp->parent = initproc;
    8000257c:	00006a17          	auipc	s4,0x6
    80002580:	36ca0a13          	addi	s4,s4,876 # 800088e8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002584:	00018997          	auipc	s3,0x18
    80002588:	80c98993          	addi	s3,s3,-2036 # 80019d90 <tickslock>
    8000258c:	a029                	j	80002596 <reparent+0x34>
    8000258e:	23848493          	addi	s1,s1,568
    80002592:	01348d63          	beq	s1,s3,800025ac <reparent+0x4a>
    if (pp->parent == p)
    80002596:	7c9c                	ld	a5,56(s1)
    80002598:	ff279be3          	bne	a5,s2,8000258e <reparent+0x2c>
      pp->parent = initproc;
    8000259c:	000a3503          	ld	a0,0(s4)
    800025a0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025a2:	00000097          	auipc	ra,0x0
    800025a6:	f4a080e7          	jalr	-182(ra) # 800024ec <wakeup>
    800025aa:	b7d5                	j	8000258e <reparent+0x2c>
}
    800025ac:	70a2                	ld	ra,40(sp)
    800025ae:	7402                	ld	s0,32(sp)
    800025b0:	64e2                	ld	s1,24(sp)
    800025b2:	6942                	ld	s2,16(sp)
    800025b4:	69a2                	ld	s3,8(sp)
    800025b6:	6a02                	ld	s4,0(sp)
    800025b8:	6145                	addi	sp,sp,48
    800025ba:	8082                	ret

00000000800025bc <exit>:
{
    800025bc:	7179                	addi	sp,sp,-48
    800025be:	f406                	sd	ra,40(sp)
    800025c0:	f022                	sd	s0,32(sp)
    800025c2:	ec26                	sd	s1,24(sp)
    800025c4:	e84a                	sd	s2,16(sp)
    800025c6:	e44e                	sd	s3,8(sp)
    800025c8:	e052                	sd	s4,0(sp)
    800025ca:	1800                	addi	s0,sp,48
    800025cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	49a080e7          	jalr	1178(ra) # 80001a68 <myproc>
    800025d6:	89aa                	mv	s3,a0
  if (p == initproc)
    800025d8:	00006797          	auipc	a5,0x6
    800025dc:	3107b783          	ld	a5,784(a5) # 800088e8 <initproc>
    800025e0:	0d050493          	addi	s1,a0,208
    800025e4:	15050913          	addi	s2,a0,336
    800025e8:	00a79d63          	bne	a5,a0,80002602 <exit+0x46>
    panic("init exiting");
    800025ec:	00006517          	auipc	a0,0x6
    800025f0:	c5450513          	addi	a0,a0,-940 # 80008240 <etext+0x240>
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	f6c080e7          	jalr	-148(ra) # 80000560 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    800025fc:	04a1                	addi	s1,s1,8
    800025fe:	01248b63          	beq	s1,s2,80002614 <exit+0x58>
    if (p->ofile[fd])
    80002602:	6088                	ld	a0,0(s1)
    80002604:	dd65                	beqz	a0,800025fc <exit+0x40>
      fileclose(f);
    80002606:	00002097          	auipc	ra,0x2
    8000260a:	72e080e7          	jalr	1838(ra) # 80004d34 <fileclose>
      p->ofile[fd] = 0;
    8000260e:	0004b023          	sd	zero,0(s1)
    80002612:	b7ed                	j	800025fc <exit+0x40>
  begin_op();
    80002614:	00002097          	auipc	ra,0x2
    80002618:	250080e7          	jalr	592(ra) # 80004864 <begin_op>
  iput(p->cwd);
    8000261c:	1509b503          	ld	a0,336(s3)
    80002620:	00002097          	auipc	ra,0x2
    80002624:	a18080e7          	jalr	-1512(ra) # 80004038 <iput>
  end_op();
    80002628:	00002097          	auipc	ra,0x2
    8000262c:	2b6080e7          	jalr	694(ra) # 800048de <end_op>
  p->cwd = 0;
    80002630:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002634:	0000e497          	auipc	s1,0xe
    80002638:	54448493          	addi	s1,s1,1348 # 80010b78 <wait_lock>
    8000263c:	8526                	mv	a0,s1
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	600080e7          	jalr	1536(ra) # 80000c3e <acquire>
  reparent(p);
    80002646:	854e                	mv	a0,s3
    80002648:	00000097          	auipc	ra,0x0
    8000264c:	f1a080e7          	jalr	-230(ra) # 80002562 <reparent>
  wakeup(p->parent);
    80002650:	0389b503          	ld	a0,56(s3)
    80002654:	00000097          	auipc	ra,0x0
    80002658:	e98080e7          	jalr	-360(ra) # 800024ec <wakeup>
  acquire(&p->lock);
    8000265c:	854e                	mv	a0,s3
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	5e0080e7          	jalr	1504(ra) # 80000c3e <acquire>
  p->xstate = status;
    80002666:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000266a:	4795                	li	a5,5
    8000266c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002670:	00006797          	auipc	a5,0x6
    80002674:	2807a783          	lw	a5,640(a5) # 800088f0 <ticks>
    80002678:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	670080e7          	jalr	1648(ra) # 80000cee <release>
  sched();
    80002686:	00000097          	auipc	ra,0x0
    8000268a:	cf0080e7          	jalr	-784(ra) # 80002376 <sched>
  panic("zombie exit");
    8000268e:	00006517          	auipc	a0,0x6
    80002692:	bc250513          	addi	a0,a0,-1086 # 80008250 <etext+0x250>
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	eca080e7          	jalr	-310(ra) # 80000560 <panic>

000000008000269e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000269e:	7179                	addi	sp,sp,-48
    800026a0:	f406                	sd	ra,40(sp)
    800026a2:	f022                	sd	s0,32(sp)
    800026a4:	ec26                	sd	s1,24(sp)
    800026a6:	e84a                	sd	s2,16(sp)
    800026a8:	e44e                	sd	s3,8(sp)
    800026aa:	1800                	addi	s0,sp,48
    800026ac:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800026ae:	0000f497          	auipc	s1,0xf
    800026b2:	8e248493          	addi	s1,s1,-1822 # 80010f90 <proc>
    800026b6:	00017997          	auipc	s3,0x17
    800026ba:	6da98993          	addi	s3,s3,1754 # 80019d90 <tickslock>
  {
    acquire(&p->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	57e080e7          	jalr	1406(ra) # 80000c3e <acquire>
    if (p->pid == pid)
    800026c8:	589c                	lw	a5,48(s1)
    800026ca:	01278d63          	beq	a5,s2,800026e4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	61e080e7          	jalr	1566(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800026d8:	23848493          	addi	s1,s1,568
    800026dc:	ff3491e3          	bne	s1,s3,800026be <kill+0x20>
  }
  return -1;
    800026e0:	557d                	li	a0,-1
    800026e2:	a829                	j	800026fc <kill+0x5e>
      p->killed = 1;
    800026e4:	4785                	li	a5,1
    800026e6:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800026e8:	4c98                	lw	a4,24(s1)
    800026ea:	4789                	li	a5,2
    800026ec:	00f70f63          	beq	a4,a5,8000270a <kill+0x6c>
      release(&p->lock);
    800026f0:	8526                	mv	a0,s1
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	5fc080e7          	jalr	1532(ra) # 80000cee <release>
      return 0;
    800026fa:	4501                	li	a0,0
}
    800026fc:	70a2                	ld	ra,40(sp)
    800026fe:	7402                	ld	s0,32(sp)
    80002700:	64e2                	ld	s1,24(sp)
    80002702:	6942                	ld	s2,16(sp)
    80002704:	69a2                	ld	s3,8(sp)
    80002706:	6145                	addi	sp,sp,48
    80002708:	8082                	ret
        p->state = RUNNABLE;
    8000270a:	478d                	li	a5,3
    8000270c:	cc9c                	sw	a5,24(s1)
    8000270e:	b7cd                	j	800026f0 <kill+0x52>

0000000080002710 <setkilled>:

void setkilled(struct proc *p)
{
    80002710:	1101                	addi	sp,sp,-32
    80002712:	ec06                	sd	ra,24(sp)
    80002714:	e822                	sd	s0,16(sp)
    80002716:	e426                	sd	s1,8(sp)
    80002718:	1000                	addi	s0,sp,32
    8000271a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	522080e7          	jalr	1314(ra) # 80000c3e <acquire>
  p->killed = 1;
    80002724:	4785                	li	a5,1
    80002726:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002728:	8526                	mv	a0,s1
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	5c4080e7          	jalr	1476(ra) # 80000cee <release>
}
    80002732:	60e2                	ld	ra,24(sp)
    80002734:	6442                	ld	s0,16(sp)
    80002736:	64a2                	ld	s1,8(sp)
    80002738:	6105                	addi	sp,sp,32
    8000273a:	8082                	ret

000000008000273c <killed>:

int killed(struct proc *p)
{
    8000273c:	1101                	addi	sp,sp,-32
    8000273e:	ec06                	sd	ra,24(sp)
    80002740:	e822                	sd	s0,16(sp)
    80002742:	e426                	sd	s1,8(sp)
    80002744:	e04a                	sd	s2,0(sp)
    80002746:	1000                	addi	s0,sp,32
    80002748:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	4f4080e7          	jalr	1268(ra) # 80000c3e <acquire>
  k = p->killed;
    80002752:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002756:	8526                	mv	a0,s1
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	596080e7          	jalr	1430(ra) # 80000cee <release>
  return k;
}
    80002760:	854a                	mv	a0,s2
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6902                	ld	s2,0(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret

000000008000276e <wait>:
{
    8000276e:	715d                	addi	sp,sp,-80
    80002770:	e486                	sd	ra,72(sp)
    80002772:	e0a2                	sd	s0,64(sp)
    80002774:	fc26                	sd	s1,56(sp)
    80002776:	f84a                	sd	s2,48(sp)
    80002778:	f44e                	sd	s3,40(sp)
    8000277a:	f052                	sd	s4,32(sp)
    8000277c:	ec56                	sd	s5,24(sp)
    8000277e:	e85a                	sd	s6,16(sp)
    80002780:	e45e                	sd	s7,8(sp)
    80002782:	0880                	addi	s0,sp,80
    80002784:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002786:	fffff097          	auipc	ra,0xfffff
    8000278a:	2e2080e7          	jalr	738(ra) # 80001a68 <myproc>
    8000278e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002790:	0000e517          	auipc	a0,0xe
    80002794:	3e850513          	addi	a0,a0,1000 # 80010b78 <wait_lock>
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	4a6080e7          	jalr	1190(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    800027a0:	4a95                	li	s5,5
        havekids = 1;
    800027a2:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027a4:	00017997          	auipc	s3,0x17
    800027a8:	5ec98993          	addi	s3,s3,1516 # 80019d90 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027ac:	0000eb97          	auipc	s7,0xe
    800027b0:	3ccb8b93          	addi	s7,s7,972 # 80010b78 <wait_lock>
    800027b4:	a8f9                	j	80002892 <wait+0x124>
    800027b6:	17490793          	addi	a5,s2,372
    800027ba:	17448693          	addi	a3,s1,372
    800027be:	1f490593          	addi	a1,s2,500
            p->syscall_count[i] += pp->syscall_count[i];
    800027c2:	4390                	lw	a2,0(a5)
    800027c4:	4298                	lw	a4,0(a3)
    800027c6:	9f31                	addw	a4,a4,a2
    800027c8:	c398                	sw	a4,0(a5)
          for (int i = 0; i < 32; i++)
    800027ca:	0791                	addi	a5,a5,4
    800027cc:	0691                	addi	a3,a3,4
    800027ce:	feb79ae3          	bne	a5,a1,800027c2 <wait+0x54>
          pid = pp->pid;
    800027d2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027d6:	000a0e63          	beqz	s4,800027f2 <wait+0x84>
    800027da:	4691                	li	a3,4
    800027dc:	02c48613          	addi	a2,s1,44
    800027e0:	85d2                	mv	a1,s4
    800027e2:	05093503          	ld	a0,80(s2)
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	f2a080e7          	jalr	-214(ra) # 80001710 <copyout>
    800027ee:	04054063          	bltz	a0,8000282e <wait+0xc0>
          freeproc(pp);
    800027f2:	8526                	mv	a0,s1
    800027f4:	fffff097          	auipc	ra,0xfffff
    800027f8:	426080e7          	jalr	1062(ra) # 80001c1a <freeproc>
          release(&pp->lock);
    800027fc:	8526                	mv	a0,s1
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	4f0080e7          	jalr	1264(ra) # 80000cee <release>
          release(&wait_lock);
    80002806:	0000e517          	auipc	a0,0xe
    8000280a:	37250513          	addi	a0,a0,882 # 80010b78 <wait_lock>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	4e0080e7          	jalr	1248(ra) # 80000cee <release>
}
    80002816:	854e                	mv	a0,s3
    80002818:	60a6                	ld	ra,72(sp)
    8000281a:	6406                	ld	s0,64(sp)
    8000281c:	74e2                	ld	s1,56(sp)
    8000281e:	7942                	ld	s2,48(sp)
    80002820:	79a2                	ld	s3,40(sp)
    80002822:	7a02                	ld	s4,32(sp)
    80002824:	6ae2                	ld	s5,24(sp)
    80002826:	6b42                	ld	s6,16(sp)
    80002828:	6ba2                	ld	s7,8(sp)
    8000282a:	6161                	addi	sp,sp,80
    8000282c:	8082                	ret
            release(&pp->lock);
    8000282e:	8526                	mv	a0,s1
    80002830:	ffffe097          	auipc	ra,0xffffe
    80002834:	4be080e7          	jalr	1214(ra) # 80000cee <release>
            release(&wait_lock);
    80002838:	0000e517          	auipc	a0,0xe
    8000283c:	34050513          	addi	a0,a0,832 # 80010b78 <wait_lock>
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	4ae080e7          	jalr	1198(ra) # 80000cee <release>
            return -1;
    80002848:	59fd                	li	s3,-1
    8000284a:	b7f1                	j	80002816 <wait+0xa8>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000284c:	23848493          	addi	s1,s1,568
    80002850:	03348463          	beq	s1,s3,80002878 <wait+0x10a>
      if (pp->parent == p)
    80002854:	7c9c                	ld	a5,56(s1)
    80002856:	ff279be3          	bne	a5,s2,8000284c <wait+0xde>
        acquire(&pp->lock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	3e2080e7          	jalr	994(ra) # 80000c3e <acquire>
        if (pp->state == ZOMBIE)
    80002864:	4c9c                	lw	a5,24(s1)
    80002866:	f55788e3          	beq	a5,s5,800027b6 <wait+0x48>
        release(&pp->lock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	482080e7          	jalr	1154(ra) # 80000cee <release>
        havekids = 1;
    80002874:	875a                	mv	a4,s6
    80002876:	bfd9                	j	8000284c <wait+0xde>
    if (!havekids || killed(p))
    80002878:	c31d                	beqz	a4,8000289e <wait+0x130>
    8000287a:	854a                	mv	a0,s2
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	ec0080e7          	jalr	-320(ra) # 8000273c <killed>
    80002884:	ed09                	bnez	a0,8000289e <wait+0x130>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002886:	85de                	mv	a1,s7
    80002888:	854a                	mv	a0,s2
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	bfe080e7          	jalr	-1026(ra) # 80002488 <sleep>
    havekids = 0;
    80002892:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002894:	0000e497          	auipc	s1,0xe
    80002898:	6fc48493          	addi	s1,s1,1788 # 80010f90 <proc>
    8000289c:	bf65                	j	80002854 <wait+0xe6>
      release(&wait_lock);
    8000289e:	0000e517          	auipc	a0,0xe
    800028a2:	2da50513          	addi	a0,a0,730 # 80010b78 <wait_lock>
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	448080e7          	jalr	1096(ra) # 80000cee <release>
      return -1;
    800028ae:	59fd                	li	s3,-1
    800028b0:	b79d                	j	80002816 <wait+0xa8>

00000000800028b2 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028b2:	7179                	addi	sp,sp,-48
    800028b4:	f406                	sd	ra,40(sp)
    800028b6:	f022                	sd	s0,32(sp)
    800028b8:	ec26                	sd	s1,24(sp)
    800028ba:	e84a                	sd	s2,16(sp)
    800028bc:	e44e                	sd	s3,8(sp)
    800028be:	e052                	sd	s4,0(sp)
    800028c0:	1800                	addi	s0,sp,48
    800028c2:	84aa                	mv	s1,a0
    800028c4:	892e                	mv	s2,a1
    800028c6:	89b2                	mv	s3,a2
    800028c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028ca:	fffff097          	auipc	ra,0xfffff
    800028ce:	19e080e7          	jalr	414(ra) # 80001a68 <myproc>
  if (user_dst)
    800028d2:	c08d                	beqz	s1,800028f4 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800028d4:	86d2                	mv	a3,s4
    800028d6:	864e                	mv	a2,s3
    800028d8:	85ca                	mv	a1,s2
    800028da:	6928                	ld	a0,80(a0)
    800028dc:	fffff097          	auipc	ra,0xfffff
    800028e0:	e34080e7          	jalr	-460(ra) # 80001710 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028e4:	70a2                	ld	ra,40(sp)
    800028e6:	7402                	ld	s0,32(sp)
    800028e8:	64e2                	ld	s1,24(sp)
    800028ea:	6942                	ld	s2,16(sp)
    800028ec:	69a2                	ld	s3,8(sp)
    800028ee:	6a02                	ld	s4,0(sp)
    800028f0:	6145                	addi	sp,sp,48
    800028f2:	8082                	ret
    memmove((char *)dst, src, len);
    800028f4:	000a061b          	sext.w	a2,s4
    800028f8:	85ce                	mv	a1,s3
    800028fa:	854a                	mv	a0,s2
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	49e080e7          	jalr	1182(ra) # 80000d9a <memmove>
    return 0;
    80002904:	8526                	mv	a0,s1
    80002906:	bff9                	j	800028e4 <either_copyout+0x32>

0000000080002908 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002908:	7179                	addi	sp,sp,-48
    8000290a:	f406                	sd	ra,40(sp)
    8000290c:	f022                	sd	s0,32(sp)
    8000290e:	ec26                	sd	s1,24(sp)
    80002910:	e84a                	sd	s2,16(sp)
    80002912:	e44e                	sd	s3,8(sp)
    80002914:	e052                	sd	s4,0(sp)
    80002916:	1800                	addi	s0,sp,48
    80002918:	892a                	mv	s2,a0
    8000291a:	84ae                	mv	s1,a1
    8000291c:	89b2                	mv	s3,a2
    8000291e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	148080e7          	jalr	328(ra) # 80001a68 <myproc>
  if (user_src)
    80002928:	c08d                	beqz	s1,8000294a <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000292a:	86d2                	mv	a3,s4
    8000292c:	864e                	mv	a2,s3
    8000292e:	85ca                	mv	a1,s2
    80002930:	6928                	ld	a0,80(a0)
    80002932:	fffff097          	auipc	ra,0xfffff
    80002936:	e6a080e7          	jalr	-406(ra) # 8000179c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000293a:	70a2                	ld	ra,40(sp)
    8000293c:	7402                	ld	s0,32(sp)
    8000293e:	64e2                	ld	s1,24(sp)
    80002940:	6942                	ld	s2,16(sp)
    80002942:	69a2                	ld	s3,8(sp)
    80002944:	6a02                	ld	s4,0(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    memmove(dst, (char *)src, len);
    8000294a:	000a061b          	sext.w	a2,s4
    8000294e:	85ce                	mv	a1,s3
    80002950:	854a                	mv	a0,s2
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	448080e7          	jalr	1096(ra) # 80000d9a <memmove>
    return 0;
    8000295a:	8526                	mv	a0,s1
    8000295c:	bff9                	j	8000293a <either_copyin+0x32>

000000008000295e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000295e:	715d                	addi	sp,sp,-80
    80002960:	e486                	sd	ra,72(sp)
    80002962:	e0a2                	sd	s0,64(sp)
    80002964:	fc26                	sd	s1,56(sp)
    80002966:	f84a                	sd	s2,48(sp)
    80002968:	f44e                	sd	s3,40(sp)
    8000296a:	f052                	sd	s4,32(sp)
    8000296c:	ec56                	sd	s5,24(sp)
    8000296e:	e85a                	sd	s6,16(sp)
    80002970:	e45e                	sd	s7,8(sp)
    80002972:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002974:	00005517          	auipc	a0,0x5
    80002978:	69c50513          	addi	a0,a0,1692 # 80008010 <etext+0x10>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	c2e080e7          	jalr	-978(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002984:	0000e497          	auipc	s1,0xe
    80002988:	76448493          	addi	s1,s1,1892 # 800110e8 <proc+0x158>
    8000298c:	00017917          	auipc	s2,0x17
    80002990:	55c90913          	addi	s2,s2,1372 # 80019ee8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002994:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002996:	00006997          	auipc	s3,0x6
    8000299a:	8ca98993          	addi	s3,s3,-1846 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    8000299e:	00006a97          	auipc	s5,0x6
    800029a2:	8caa8a93          	addi	s5,s5,-1846 # 80008268 <etext+0x268>
    printf("\n");
    800029a6:	00005a17          	auipc	s4,0x5
    800029aa:	66aa0a13          	addi	s4,s4,1642 # 80008010 <etext+0x10>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029ae:	00006b97          	auipc	s7,0x6
    800029b2:	d92b8b93          	addi	s7,s7,-622 # 80008740 <states.0>
    800029b6:	a00d                	j	800029d8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800029b8:	ed86a583          	lw	a1,-296(a3)
    800029bc:	8556                	mv	a0,s5
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	bec080e7          	jalr	-1044(ra) # 800005aa <printf>
    printf("\n");
    800029c6:	8552                	mv	a0,s4
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	be2080e7          	jalr	-1054(ra) # 800005aa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800029d0:	23848493          	addi	s1,s1,568
    800029d4:	03248263          	beq	s1,s2,800029f8 <procdump+0x9a>
    if (p->state == UNUSED)
    800029d8:	86a6                	mv	a3,s1
    800029da:	ec04a783          	lw	a5,-320(s1)
    800029de:	dbed                	beqz	a5,800029d0 <procdump+0x72>
      state = "???";
    800029e0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029e2:	fcfb6be3          	bltu	s6,a5,800029b8 <procdump+0x5a>
    800029e6:	02079713          	slli	a4,a5,0x20
    800029ea:	01d75793          	srli	a5,a4,0x1d
    800029ee:	97de                	add	a5,a5,s7
    800029f0:	6390                	ld	a2,0(a5)
    800029f2:	f279                	bnez	a2,800029b8 <procdump+0x5a>
      state = "???";
    800029f4:	864e                	mv	a2,s3
    800029f6:	b7c9                	j	800029b8 <procdump+0x5a>
  }
}
    800029f8:	60a6                	ld	ra,72(sp)
    800029fa:	6406                	ld	s0,64(sp)
    800029fc:	74e2                	ld	s1,56(sp)
    800029fe:	7942                	ld	s2,48(sp)
    80002a00:	79a2                	ld	s3,40(sp)
    80002a02:	7a02                	ld	s4,32(sp)
    80002a04:	6ae2                	ld	s5,24(sp)
    80002a06:	6b42                	ld	s6,16(sp)
    80002a08:	6ba2                	ld	s7,8(sp)
    80002a0a:	6161                	addi	sp,sp,80
    80002a0c:	8082                	ret

0000000080002a0e <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002a0e:	711d                	addi	sp,sp,-96
    80002a10:	ec86                	sd	ra,88(sp)
    80002a12:	e8a2                	sd	s0,80(sp)
    80002a14:	e4a6                	sd	s1,72(sp)
    80002a16:	e0ca                	sd	s2,64(sp)
    80002a18:	fc4e                	sd	s3,56(sp)
    80002a1a:	f852                	sd	s4,48(sp)
    80002a1c:	f456                	sd	s5,40(sp)
    80002a1e:	f05a                	sd	s6,32(sp)
    80002a20:	ec5e                	sd	s7,24(sp)
    80002a22:	e862                	sd	s8,16(sp)
    80002a24:	e466                	sd	s9,8(sp)
    80002a26:	1080                	addi	s0,sp,96
    80002a28:	8b2a                	mv	s6,a0
    80002a2a:	8bae                	mv	s7,a1
    80002a2c:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	03a080e7          	jalr	58(ra) # 80001a68 <myproc>
    80002a36:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002a38:	0000e517          	auipc	a0,0xe
    80002a3c:	14050513          	addi	a0,a0,320 # 80010b78 <wait_lock>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	1fe080e7          	jalr	510(ra) # 80000c3e <acquire>
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002a48:	4a15                	li	s4,5
        havekids = 1;
    80002a4a:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002a4c:	00017997          	auipc	s3,0x17
    80002a50:	34498993          	addi	s3,s3,836 # 80019d90 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002a54:	0000ec97          	auipc	s9,0xe
    80002a58:	124c8c93          	addi	s9,s9,292 # 80010b78 <wait_lock>
    80002a5c:	a8e1                	j	80002b34 <waitx+0x126>
          pid = np->pid;
    80002a5e:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002a62:	1684a783          	lw	a5,360(s1)
    80002a66:	00fc2023          	sw	a5,0(s8) # 1000 <_entry-0x7ffff000>
          *wtime = np->etime - np->ctime - np->rtime;
    80002a6a:	16c4a703          	lw	a4,364(s1)
    80002a6e:	9f3d                	addw	a4,a4,a5
    80002a70:	1704a783          	lw	a5,368(s1)
    80002a74:	9f99                	subw	a5,a5,a4
    80002a76:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002a7a:	000b0e63          	beqz	s6,80002a96 <waitx+0x88>
    80002a7e:	4691                	li	a3,4
    80002a80:	02c48613          	addi	a2,s1,44
    80002a84:	85da                	mv	a1,s6
    80002a86:	05093503          	ld	a0,80(s2)
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	c86080e7          	jalr	-890(ra) # 80001710 <copyout>
    80002a92:	04054263          	bltz	a0,80002ad6 <waitx+0xc8>
          freeproc(np);
    80002a96:	8526                	mv	a0,s1
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	182080e7          	jalr	386(ra) # 80001c1a <freeproc>
          release(&np->lock);
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	24c080e7          	jalr	588(ra) # 80000cee <release>
          release(&wait_lock);
    80002aaa:	0000e517          	auipc	a0,0xe
    80002aae:	0ce50513          	addi	a0,a0,206 # 80010b78 <wait_lock>
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	23c080e7          	jalr	572(ra) # 80000cee <release>
  }
}
    80002aba:	854e                	mv	a0,s3
    80002abc:	60e6                	ld	ra,88(sp)
    80002abe:	6446                	ld	s0,80(sp)
    80002ac0:	64a6                	ld	s1,72(sp)
    80002ac2:	6906                	ld	s2,64(sp)
    80002ac4:	79e2                	ld	s3,56(sp)
    80002ac6:	7a42                	ld	s4,48(sp)
    80002ac8:	7aa2                	ld	s5,40(sp)
    80002aca:	7b02                	ld	s6,32(sp)
    80002acc:	6be2                	ld	s7,24(sp)
    80002ace:	6c42                	ld	s8,16(sp)
    80002ad0:	6ca2                	ld	s9,8(sp)
    80002ad2:	6125                	addi	sp,sp,96
    80002ad4:	8082                	ret
            release(&np->lock);
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	216080e7          	jalr	534(ra) # 80000cee <release>
            release(&wait_lock);
    80002ae0:	0000e517          	auipc	a0,0xe
    80002ae4:	09850513          	addi	a0,a0,152 # 80010b78 <wait_lock>
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	206080e7          	jalr	518(ra) # 80000cee <release>
            return -1;
    80002af0:	59fd                	li	s3,-1
    80002af2:	b7e1                	j	80002aba <waitx+0xac>
    for (np = proc; np < &proc[NPROC]; np++)
    80002af4:	23848493          	addi	s1,s1,568
    80002af8:	03348463          	beq	s1,s3,80002b20 <waitx+0x112>
      if (np->parent == p)
    80002afc:	7c9c                	ld	a5,56(s1)
    80002afe:	ff279be3          	bne	a5,s2,80002af4 <waitx+0xe6>
        acquire(&np->lock);
    80002b02:	8526                	mv	a0,s1
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	13a080e7          	jalr	314(ra) # 80000c3e <acquire>
        if (np->state == ZOMBIE)
    80002b0c:	4c9c                	lw	a5,24(s1)
    80002b0e:	f54788e3          	beq	a5,s4,80002a5e <waitx+0x50>
        release(&np->lock);
    80002b12:	8526                	mv	a0,s1
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	1da080e7          	jalr	474(ra) # 80000cee <release>
        havekids = 1;
    80002b1c:	8756                	mv	a4,s5
    80002b1e:	bfd9                	j	80002af4 <waitx+0xe6>
    if (!havekids || p->killed)
    80002b20:	c305                	beqz	a4,80002b40 <waitx+0x132>
    80002b22:	02892783          	lw	a5,40(s2)
    80002b26:	ef89                	bnez	a5,80002b40 <waitx+0x132>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002b28:	85e6                	mv	a1,s9
    80002b2a:	854a                	mv	a0,s2
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	95c080e7          	jalr	-1700(ra) # 80002488 <sleep>
    havekids = 0;
    80002b34:	4701                	li	a4,0
    for (np = proc; np < &proc[NPROC]; np++)
    80002b36:	0000e497          	auipc	s1,0xe
    80002b3a:	45a48493          	addi	s1,s1,1114 # 80010f90 <proc>
    80002b3e:	bf7d                	j	80002afc <waitx+0xee>
      release(&wait_lock);
    80002b40:	0000e517          	auipc	a0,0xe
    80002b44:	03850513          	addi	a0,a0,56 # 80010b78 <wait_lock>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	1a6080e7          	jalr	422(ra) # 80000cee <release>
      return -1;
    80002b50:	59fd                	li	s3,-1
    80002b52:	b7a5                	j	80002aba <waitx+0xac>

0000000080002b54 <update_time>:

void update_time()
{
    80002b54:	7179                	addi	sp,sp,-48
    80002b56:	f406                	sd	ra,40(sp)
    80002b58:	f022                	sd	s0,32(sp)
    80002b5a:	ec26                	sd	s1,24(sp)
    80002b5c:	e84a                	sd	s2,16(sp)
    80002b5e:	e44e                	sd	s3,8(sp)
    80002b60:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002b62:	0000e497          	auipc	s1,0xe
    80002b66:	42e48493          	addi	s1,s1,1070 # 80010f90 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002b6a:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002b6c:	00017917          	auipc	s2,0x17
    80002b70:	22490913          	addi	s2,s2,548 # 80019d90 <tickslock>
    80002b74:	a811                	j	80002b88 <update_time+0x34>
    // }
    // if (p->pid > 3)
    // {
    //   printf("pid: %d,queue: %d,ticks: %d\n", p->pid, p->priority_level, ticks);
    // }
    release(&p->lock);
    80002b76:	8526                	mv	a0,s1
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	176080e7          	jalr	374(ra) # 80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b80:	23848493          	addi	s1,s1,568
    80002b84:	03248063          	beq	s1,s2,80002ba4 <update_time+0x50>
    acquire(&p->lock);
    80002b88:	8526                	mv	a0,s1
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	0b4080e7          	jalr	180(ra) # 80000c3e <acquire>
    if (p->state == RUNNING)
    80002b92:	4c9c                	lw	a5,24(s1)
    80002b94:	ff3791e3          	bne	a5,s3,80002b76 <update_time+0x22>
      p->rtime++;
    80002b98:	1684a783          	lw	a5,360(s1)
    80002b9c:	2785                	addiw	a5,a5,1
    80002b9e:	16f4a423          	sw	a5,360(s1)
    80002ba2:	bfd1                	j	80002b76 <update_time+0x22>
  }
    80002ba4:	70a2                	ld	ra,40(sp)
    80002ba6:	7402                	ld	s0,32(sp)
    80002ba8:	64e2                	ld	s1,24(sp)
    80002baa:	6942                	ld	s2,16(sp)
    80002bac:	69a2                	ld	s3,8(sp)
    80002bae:	6145                	addi	sp,sp,48
    80002bb0:	8082                	ret

0000000080002bb2 <swtch>:
    80002bb2:	00153023          	sd	ra,0(a0)
    80002bb6:	00253423          	sd	sp,8(a0)
    80002bba:	e900                	sd	s0,16(a0)
    80002bbc:	ed04                	sd	s1,24(a0)
    80002bbe:	03253023          	sd	s2,32(a0)
    80002bc2:	03353423          	sd	s3,40(a0)
    80002bc6:	03453823          	sd	s4,48(a0)
    80002bca:	03553c23          	sd	s5,56(a0)
    80002bce:	05653023          	sd	s6,64(a0)
    80002bd2:	05753423          	sd	s7,72(a0)
    80002bd6:	05853823          	sd	s8,80(a0)
    80002bda:	05953c23          	sd	s9,88(a0)
    80002bde:	07a53023          	sd	s10,96(a0)
    80002be2:	07b53423          	sd	s11,104(a0)
    80002be6:	0005b083          	ld	ra,0(a1)
    80002bea:	0085b103          	ld	sp,8(a1)
    80002bee:	6980                	ld	s0,16(a1)
    80002bf0:	6d84                	ld	s1,24(a1)
    80002bf2:	0205b903          	ld	s2,32(a1)
    80002bf6:	0285b983          	ld	s3,40(a1)
    80002bfa:	0305ba03          	ld	s4,48(a1)
    80002bfe:	0385ba83          	ld	s5,56(a1)
    80002c02:	0405bb03          	ld	s6,64(a1)
    80002c06:	0485bb83          	ld	s7,72(a1)
    80002c0a:	0505bc03          	ld	s8,80(a1)
    80002c0e:	0585bc83          	ld	s9,88(a1)
    80002c12:	0605bd03          	ld	s10,96(a1)
    80002c16:	0685bd83          	ld	s11,104(a1)
    80002c1a:	8082                	ret

0000000080002c1c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002c1c:	1141                	addi	sp,sp,-16
    80002c1e:	e406                	sd	ra,8(sp)
    80002c20:	e022                	sd	s0,0(sp)
    80002c22:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c24:	00005597          	auipc	a1,0x5
    80002c28:	68458593          	addi	a1,a1,1668 # 800082a8 <etext+0x2a8>
    80002c2c:	00017517          	auipc	a0,0x17
    80002c30:	16450513          	addi	a0,a0,356 # 80019d90 <tickslock>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	f76080e7          	jalr	-138(ra) # 80000baa <initlock>
}
    80002c3c:	60a2                	ld	ra,8(sp)
    80002c3e:	6402                	ld	s0,0(sp)
    80002c40:	0141                	addi	sp,sp,16
    80002c42:	8082                	ret

0000000080002c44 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002c44:	1141                	addi	sp,sp,-16
    80002c46:	e406                	sd	ra,8(sp)
    80002c48:	e022                	sd	s0,0(sp)
    80002c4a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c4c:	00004797          	auipc	a5,0x4
    80002c50:	83478793          	addi	a5,a5,-1996 # 80006480 <kernelvec>
    80002c54:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c58:	60a2                	ld	ra,8(sp)
    80002c5a:	6402                	ld	s0,0(sp)
    80002c5c:	0141                	addi	sp,sp,16
    80002c5e:	8082                	ret

0000000080002c60 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002c60:	1141                	addi	sp,sp,-16
    80002c62:	e406                	sd	ra,8(sp)
    80002c64:	e022                	sd	s0,0(sp)
    80002c66:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	e00080e7          	jalr	-512(ra) # 80001a68 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c70:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c74:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c76:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c7a:	00004697          	auipc	a3,0x4
    80002c7e:	38668693          	addi	a3,a3,902 # 80007000 <_trampoline>
    80002c82:	00004717          	auipc	a4,0x4
    80002c86:	37e70713          	addi	a4,a4,894 # 80007000 <_trampoline>
    80002c8a:	8f15                	sub	a4,a4,a3
    80002c8c:	040007b7          	lui	a5,0x4000
    80002c90:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002c92:	07b2                	slli	a5,a5,0xc
    80002c94:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c96:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c9a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c9c:	18002673          	csrr	a2,satp
    80002ca0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ca2:	6d30                	ld	a2,88(a0)
    80002ca4:	6138                	ld	a4,64(a0)
    80002ca6:	6585                	lui	a1,0x1
    80002ca8:	972e                	add	a4,a4,a1
    80002caa:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002cac:	6d38                	ld	a4,88(a0)
    80002cae:	00000617          	auipc	a2,0x0
    80002cb2:	14660613          	addi	a2,a2,326 # 80002df4 <usertrap>
    80002cb6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002cb8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002cba:	8612                	mv	a2,tp
    80002cbc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cbe:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002cc2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002cc6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cca:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002cce:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cd0:	6f18                	ld	a4,24(a4)
    80002cd2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002cd6:	6928                	ld	a0,80(a0)
    80002cd8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002cda:	00004717          	auipc	a4,0x4
    80002cde:	3c270713          	addi	a4,a4,962 # 8000709c <userret>
    80002ce2:	8f15                	sub	a4,a4,a3
    80002ce4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ce6:	577d                	li	a4,-1
    80002ce8:	177e                	slli	a4,a4,0x3f
    80002cea:	8d59                	or	a0,a0,a4
    80002cec:	9782                	jalr	a5
}
    80002cee:	60a2                	ld	ra,8(sp)
    80002cf0:	6402                	ld	s0,0(sp)
    80002cf2:	0141                	addi	sp,sp,16
    80002cf4:	8082                	ret

0000000080002cf6 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002cf6:	1101                	addi	sp,sp,-32
    80002cf8:	ec06                	sd	ra,24(sp)
    80002cfa:	e822                	sd	s0,16(sp)
    80002cfc:	e426                	sd	s1,8(sp)
    80002cfe:	e04a                	sd	s2,0(sp)
    80002d00:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d02:	00017917          	auipc	s2,0x17
    80002d06:	08e90913          	addi	s2,s2,142 # 80019d90 <tickslock>
    80002d0a:	854a                	mv	a0,s2
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	f32080e7          	jalr	-206(ra) # 80000c3e <acquire>
  ticks++;
    80002d14:	00006497          	auipc	s1,0x6
    80002d18:	bdc48493          	addi	s1,s1,-1060 # 800088f0 <ticks>
    80002d1c:	409c                	lw	a5,0(s1)
    80002d1e:	2785                	addiw	a5,a5,1
    80002d20:	c09c                	sw	a5,0(s1)
  update_time();
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	e32080e7          	jalr	-462(ra) # 80002b54 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	7c0080e7          	jalr	1984(ra) # 800024ec <wakeup>
  release(&tickslock);
    80002d34:	854a                	mv	a0,s2
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	fb8080e7          	jalr	-72(ra) # 80000cee <release>
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	64a2                	ld	s1,8(sp)
    80002d44:	6902                	ld	s2,0(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d4a:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002d4e:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002d50:	0a07d163          	bgez	a5,80002df2 <devintr+0xa8>
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002d5c:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002d60:	46a5                	li	a3,9
    80002d62:	00d70c63          	beq	a4,a3,80002d7a <devintr+0x30>
  else if (scause == 0x8000000000000001L)
    80002d66:	577d                	li	a4,-1
    80002d68:	177e                	slli	a4,a4,0x3f
    80002d6a:	0705                	addi	a4,a4,1
    return 0;
    80002d6c:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002d6e:	06e78163          	beq	a5,a4,80002dd0 <devintr+0x86>
  }
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret
    80002d7a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002d7c:	00004097          	auipc	ra,0x4
    80002d80:	810080e7          	jalr	-2032(ra) # 8000658c <plic_claim>
    80002d84:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002d86:	47a9                	li	a5,10
    80002d88:	00f50963          	beq	a0,a5,80002d9a <devintr+0x50>
    else if (irq == VIRTIO0_IRQ)
    80002d8c:	4785                	li	a5,1
    80002d8e:	00f50b63          	beq	a0,a5,80002da4 <devintr+0x5a>
    return 1;
    80002d92:	4505                	li	a0,1
    else if (irq)
    80002d94:	ec89                	bnez	s1,80002dae <devintr+0x64>
    80002d96:	64a2                	ld	s1,8(sp)
    80002d98:	bfe9                	j	80002d72 <devintr+0x28>
      uartintr();
    80002d9a:	ffffe097          	auipc	ra,0xffffe
    80002d9e:	c62080e7          	jalr	-926(ra) # 800009fc <uartintr>
    if (irq)
    80002da2:	a839                	j	80002dc0 <devintr+0x76>
      virtio_disk_intr();
    80002da4:	00004097          	auipc	ra,0x4
    80002da8:	cdc080e7          	jalr	-804(ra) # 80006a80 <virtio_disk_intr>
    if (irq)
    80002dac:	a811                	j	80002dc0 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dae:	85a6                	mv	a1,s1
    80002db0:	00005517          	auipc	a0,0x5
    80002db4:	50050513          	addi	a0,a0,1280 # 800082b0 <etext+0x2b0>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	7f2080e7          	jalr	2034(ra) # 800005aa <printf>
      plic_complete(irq);
    80002dc0:	8526                	mv	a0,s1
    80002dc2:	00003097          	auipc	ra,0x3
    80002dc6:	7ee080e7          	jalr	2030(ra) # 800065b0 <plic_complete>
    return 1;
    80002dca:	4505                	li	a0,1
    80002dcc:	64a2                	ld	s1,8(sp)
    80002dce:	b755                	j	80002d72 <devintr+0x28>
    if (cpuid() == 0)
    80002dd0:	fffff097          	auipc	ra,0xfffff
    80002dd4:	c64080e7          	jalr	-924(ra) # 80001a34 <cpuid>
    80002dd8:	c901                	beqz	a0,80002de8 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002dda:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002dde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002de0:	14479073          	csrw	sip,a5
    return 2;
    80002de4:	4509                	li	a0,2
    80002de6:	b771                	j	80002d72 <devintr+0x28>
      clockintr();
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	f0e080e7          	jalr	-242(ra) # 80002cf6 <clockintr>
    80002df0:	b7ed                	j	80002dda <devintr+0x90>
}
    80002df2:	8082                	ret

0000000080002df4 <usertrap>:
{
    80002df4:	1101                	addi	sp,sp,-32
    80002df6:	ec06                	sd	ra,24(sp)
    80002df8:	e822                	sd	s0,16(sp)
    80002dfa:	e426                	sd	s1,8(sp)
    80002dfc:	e04a                	sd	s2,0(sp)
    80002dfe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e00:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e04:	1007f793          	andi	a5,a5,256
    80002e08:	e3b1                	bnez	a5,80002e4c <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e0a:	00003797          	auipc	a5,0x3
    80002e0e:	67678793          	addi	a5,a5,1654 # 80006480 <kernelvec>
    80002e12:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e16:	fffff097          	auipc	ra,0xfffff
    80002e1a:	c52080e7          	jalr	-942(ra) # 80001a68 <myproc>
    80002e1e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e20:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e22:	14102773          	csrr	a4,sepc
    80002e26:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e28:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e2c:	47a1                	li	a5,8
    80002e2e:	02f70763          	beq	a4,a5,80002e5c <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	f18080e7          	jalr	-232(ra) # 80002d4a <devintr>
    80002e3a:	892a                	mv	s2,a0
    80002e3c:	c92d                	beqz	a0,80002eae <usertrap+0xba>
  if (killed(p))
    80002e3e:	8526                	mv	a0,s1
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	8fc080e7          	jalr	-1796(ra) # 8000273c <killed>
    80002e48:	c555                	beqz	a0,80002ef4 <usertrap+0x100>
    80002e4a:	a045                	j	80002eea <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002e4c:	00005517          	auipc	a0,0x5
    80002e50:	48450513          	addi	a0,a0,1156 # 800082d0 <etext+0x2d0>
    80002e54:	ffffd097          	auipc	ra,0xffffd
    80002e58:	70c080e7          	jalr	1804(ra) # 80000560 <panic>
    if (killed(p))
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	8e0080e7          	jalr	-1824(ra) # 8000273c <killed>
    80002e64:	ed1d                	bnez	a0,80002ea2 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002e66:	6cb8                	ld	a4,88(s1)
    80002e68:	6f1c                	ld	a5,24(a4)
    80002e6a:	0791                	addi	a5,a5,4
    80002e6c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e72:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e76:	10079073          	csrw	sstatus,a5
    syscall();
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	32a080e7          	jalr	810(ra) # 800031a4 <syscall>
  if (killed(p))
    80002e82:	8526                	mv	a0,s1
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	8b8080e7          	jalr	-1864(ra) # 8000273c <killed>
    80002e8c:	ed31                	bnez	a0,80002ee8 <usertrap+0xf4>
  usertrapret();
    80002e8e:	00000097          	auipc	ra,0x0
    80002e92:	dd2080e7          	jalr	-558(ra) # 80002c60 <usertrapret>
}
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	64a2                	ld	s1,8(sp)
    80002e9c:	6902                	ld	s2,0(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret
      exit(-1);
    80002ea2:	557d                	li	a0,-1
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	718080e7          	jalr	1816(ra) # 800025bc <exit>
    80002eac:	bf6d                	j	80002e66 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002eae:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002eb2:	5890                	lw	a2,48(s1)
    80002eb4:	00005517          	auipc	a0,0x5
    80002eb8:	43c50513          	addi	a0,a0,1084 # 800082f0 <etext+0x2f0>
    80002ebc:	ffffd097          	auipc	ra,0xffffd
    80002ec0:	6ee080e7          	jalr	1774(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ec4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ec8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ecc:	00005517          	auipc	a0,0x5
    80002ed0:	45450513          	addi	a0,a0,1108 # 80008320 <etext+0x320>
    80002ed4:	ffffd097          	auipc	ra,0xffffd
    80002ed8:	6d6080e7          	jalr	1750(ra) # 800005aa <printf>
    setkilled(p);
    80002edc:	8526                	mv	a0,s1
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	832080e7          	jalr	-1998(ra) # 80002710 <setkilled>
    80002ee6:	bf71                	j	80002e82 <usertrap+0x8e>
  if (killed(p))
    80002ee8:	4901                	li	s2,0
    exit(-1);
    80002eea:	557d                	li	a0,-1
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	6d0080e7          	jalr	1744(ra) # 800025bc <exit>
  if (which_dev == 2)
    80002ef4:	4789                	li	a5,2
    80002ef6:	04f91e63          	bne	s2,a5,80002f52 <usertrap+0x15e>
    if (p->in_handlefunc == 0)
    80002efa:	2144c783          	lbu	a5,532(s1)
    80002efe:	e799                	bnez	a5,80002f0c <usertrap+0x118>
      p->left_ticks = p->left_ticks - 1;
    80002f00:	2104a783          	lw	a5,528(s1)
    80002f04:	37fd                	addiw	a5,a5,-1
    80002f06:	20f4a823          	sw	a5,528(s1)
      if (p->left_ticks == 0)
    80002f0a:	cb91                	beqz	a5,80002f1e <usertrap+0x12a>
    if (p->state == RUNNING)
    80002f0c:	4c98                	lw	a4,24(s1)
    80002f0e:	4791                	li	a5,4
    80002f10:	02f70b63          	beq	a4,a5,80002f46 <usertrap+0x152>
    yield();
    80002f14:	fffff097          	auipc	ra,0xfffff
    80002f18:	538080e7          	jalr	1336(ra) # 8000244c <yield>
    80002f1c:	bf8d                	j	80002e8e <usertrap+0x9a>
        p->in_handlefunc = 1;
    80002f1e:	4785                	li	a5,1
    80002f20:	20f48a23          	sb	a5,532(s1)
        p->tf_stored = (struct trapframe *)kalloc();
    80002f24:	ffffe097          	auipc	ra,0xffffe
    80002f28:	c26080e7          	jalr	-986(ra) # 80000b4a <kalloc>
    80002f2c:	1ea4bc23          	sd	a0,504(s1)
        memmove(p->tf_stored, p->trapframe, PGSIZE);
    80002f30:	6605                	lui	a2,0x1
    80002f32:	6cac                	ld	a1,88(s1)
    80002f34:	ffffe097          	auipc	ra,0xffffe
    80002f38:	e66080e7          	jalr	-410(ra) # 80000d9a <memmove>
        p->trapframe->epc = p->handler_function;
    80002f3c:	6cbc                	ld	a5,88(s1)
    80002f3e:	2084b703          	ld	a4,520(s1)
    80002f42:	ef98                	sd	a4,24(a5)
    80002f44:	b7e1                	j	80002f0c <usertrap+0x118>
      p->time_taken++;
    80002f46:	22c4a783          	lw	a5,556(s1)
    80002f4a:	2785                	addiw	a5,a5,1
    80002f4c:	22f4a623          	sw	a5,556(s1)
    80002f50:	b7d1                	j	80002f14 <usertrap+0x120>
  else if (which_dev == 1)
    80002f52:	4785                	li	a5,1
    80002f54:	f2f91de3          	bne	s2,a5,80002e8e <usertrap+0x9a>
    yield();
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	4f4080e7          	jalr	1268(ra) # 8000244c <yield>
    80002f60:	b73d                	j	80002e8e <usertrap+0x9a>

0000000080002f62 <kerneltrap>:
{
    80002f62:	7179                	addi	sp,sp,-48
    80002f64:	f406                	sd	ra,40(sp)
    80002f66:	f022                	sd	s0,32(sp)
    80002f68:	ec26                	sd	s1,24(sp)
    80002f6a:	e84a                	sd	s2,16(sp)
    80002f6c:	e44e                	sd	s3,8(sp)
    80002f6e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f70:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f74:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f78:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002f7c:	1004f793          	andi	a5,s1,256
    80002f80:	cb85                	beqz	a5,80002fb0 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f82:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f86:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002f88:	ef85                	bnez	a5,80002fc0 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	dc0080e7          	jalr	-576(ra) # 80002d4a <devintr>
    80002f92:	cd1d                	beqz	a0,80002fd0 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f94:	4789                	li	a5,2
    80002f96:	06f50a63          	beq	a0,a5,8000300a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f9a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f9e:	10049073          	csrw	sstatus,s1
}
    80002fa2:	70a2                	ld	ra,40(sp)
    80002fa4:	7402                	ld	s0,32(sp)
    80002fa6:	64e2                	ld	s1,24(sp)
    80002fa8:	6942                	ld	s2,16(sp)
    80002faa:	69a2                	ld	s3,8(sp)
    80002fac:	6145                	addi	sp,sp,48
    80002fae:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002fb0:	00005517          	auipc	a0,0x5
    80002fb4:	39050513          	addi	a0,a0,912 # 80008340 <etext+0x340>
    80002fb8:	ffffd097          	auipc	ra,0xffffd
    80002fbc:	5a8080e7          	jalr	1448(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002fc0:	00005517          	auipc	a0,0x5
    80002fc4:	3a850513          	addi	a0,a0,936 # 80008368 <etext+0x368>
    80002fc8:	ffffd097          	auipc	ra,0xffffd
    80002fcc:	598080e7          	jalr	1432(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002fd0:	85ce                	mv	a1,s3
    80002fd2:	00005517          	auipc	a0,0x5
    80002fd6:	3b650513          	addi	a0,a0,950 # 80008388 <etext+0x388>
    80002fda:	ffffd097          	auipc	ra,0xffffd
    80002fde:	5d0080e7          	jalr	1488(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fe2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fe6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fea:	00005517          	auipc	a0,0x5
    80002fee:	3ae50513          	addi	a0,a0,942 # 80008398 <etext+0x398>
    80002ff2:	ffffd097          	auipc	ra,0xffffd
    80002ff6:	5b8080e7          	jalr	1464(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002ffa:	00005517          	auipc	a0,0x5
    80002ffe:	3b650513          	addi	a0,a0,950 # 800083b0 <etext+0x3b0>
    80003002:	ffffd097          	auipc	ra,0xffffd
    80003006:	55e080e7          	jalr	1374(ra) # 80000560 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000300a:	fffff097          	auipc	ra,0xfffff
    8000300e:	a5e080e7          	jalr	-1442(ra) # 80001a68 <myproc>
    80003012:	d541                	beqz	a0,80002f9a <kerneltrap+0x38>
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	a54080e7          	jalr	-1452(ra) # 80001a68 <myproc>
    8000301c:	4d18                	lw	a4,24(a0)
    8000301e:	4791                	li	a5,4
    80003020:	f6f71de3          	bne	a4,a5,80002f9a <kerneltrap+0x38>
    yield();
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	428080e7          	jalr	1064(ra) # 8000244c <yield>
    8000302c:	b7bd                	j	80002f9a <kerneltrap+0x38>

000000008000302e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000303a:	fffff097          	auipc	ra,0xfffff
    8000303e:	a2e080e7          	jalr	-1490(ra) # 80001a68 <myproc>
  switch (n)
    80003042:	4795                	li	a5,5
    80003044:	0497e163          	bltu	a5,s1,80003086 <argraw+0x58>
    80003048:	048a                	slli	s1,s1,0x2
    8000304a:	00005717          	auipc	a4,0x5
    8000304e:	72670713          	addi	a4,a4,1830 # 80008770 <states.0+0x30>
    80003052:	94ba                	add	s1,s1,a4
    80003054:	409c                	lw	a5,0(s1)
    80003056:	97ba                	add	a5,a5,a4
    80003058:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    8000305a:	6d3c                	ld	a5,88(a0)
    8000305c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000305e:	60e2                	ld	ra,24(sp)
    80003060:	6442                	ld	s0,16(sp)
    80003062:	64a2                	ld	s1,8(sp)
    80003064:	6105                	addi	sp,sp,32
    80003066:	8082                	ret
    return p->trapframe->a1;
    80003068:	6d3c                	ld	a5,88(a0)
    8000306a:	7fa8                	ld	a0,120(a5)
    8000306c:	bfcd                	j	8000305e <argraw+0x30>
    return p->trapframe->a2;
    8000306e:	6d3c                	ld	a5,88(a0)
    80003070:	63c8                	ld	a0,128(a5)
    80003072:	b7f5                	j	8000305e <argraw+0x30>
    return p->trapframe->a3;
    80003074:	6d3c                	ld	a5,88(a0)
    80003076:	67c8                	ld	a0,136(a5)
    80003078:	b7dd                	j	8000305e <argraw+0x30>
    return p->trapframe->a4;
    8000307a:	6d3c                	ld	a5,88(a0)
    8000307c:	6bc8                	ld	a0,144(a5)
    8000307e:	b7c5                	j	8000305e <argraw+0x30>
    return p->trapframe->a5;
    80003080:	6d3c                	ld	a5,88(a0)
    80003082:	6fc8                	ld	a0,152(a5)
    80003084:	bfe9                	j	8000305e <argraw+0x30>
  panic("argraw");
    80003086:	00005517          	auipc	a0,0x5
    8000308a:	33a50513          	addi	a0,a0,826 # 800083c0 <etext+0x3c0>
    8000308e:	ffffd097          	auipc	ra,0xffffd
    80003092:	4d2080e7          	jalr	1234(ra) # 80000560 <panic>

0000000080003096 <fetchaddr>:
{
    80003096:	1101                	addi	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	e426                	sd	s1,8(sp)
    8000309e:	e04a                	sd	s2,0(sp)
    800030a0:	1000                	addi	s0,sp,32
    800030a2:	84aa                	mv	s1,a0
    800030a4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	9c2080e7          	jalr	-1598(ra) # 80001a68 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030ae:	653c                	ld	a5,72(a0)
    800030b0:	02f4f863          	bgeu	s1,a5,800030e0 <fetchaddr+0x4a>
    800030b4:	00848713          	addi	a4,s1,8
    800030b8:	02e7e663          	bltu	a5,a4,800030e4 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030bc:	46a1                	li	a3,8
    800030be:	8626                	mv	a2,s1
    800030c0:	85ca                	mv	a1,s2
    800030c2:	6928                	ld	a0,80(a0)
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	6d8080e7          	jalr	1752(ra) # 8000179c <copyin>
    800030cc:	00a03533          	snez	a0,a0
    800030d0:	40a0053b          	negw	a0,a0
}
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6902                	ld	s2,0(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret
    return -1;
    800030e0:	557d                	li	a0,-1
    800030e2:	bfcd                	j	800030d4 <fetchaddr+0x3e>
    800030e4:	557d                	li	a0,-1
    800030e6:	b7fd                	j	800030d4 <fetchaddr+0x3e>

00000000800030e8 <fetchstr>:
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
    800030f6:	892a                	mv	s2,a0
    800030f8:	84ae                	mv	s1,a1
    800030fa:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	96c080e7          	jalr	-1684(ra) # 80001a68 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003104:	86ce                	mv	a3,s3
    80003106:	864a                	mv	a2,s2
    80003108:	85a6                	mv	a1,s1
    8000310a:	6928                	ld	a0,80(a0)
    8000310c:	ffffe097          	auipc	ra,0xffffe
    80003110:	71e080e7          	jalr	1822(ra) # 8000182a <copyinstr>
    80003114:	00054e63          	bltz	a0,80003130 <fetchstr+0x48>
  return strlen(buf);
    80003118:	8526                	mv	a0,s1
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	da8080e7          	jalr	-600(ra) # 80000ec2 <strlen>
}
    80003122:	70a2                	ld	ra,40(sp)
    80003124:	7402                	ld	s0,32(sp)
    80003126:	64e2                	ld	s1,24(sp)
    80003128:	6942                	ld	s2,16(sp)
    8000312a:	69a2                	ld	s3,8(sp)
    8000312c:	6145                	addi	sp,sp,48
    8000312e:	8082                	ret
    return -1;
    80003130:	557d                	li	a0,-1
    80003132:	bfc5                	j	80003122 <fetchstr+0x3a>

0000000080003134 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003134:	1101                	addi	sp,sp,-32
    80003136:	ec06                	sd	ra,24(sp)
    80003138:	e822                	sd	s0,16(sp)
    8000313a:	e426                	sd	s1,8(sp)
    8000313c:	1000                	addi	s0,sp,32
    8000313e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003140:	00000097          	auipc	ra,0x0
    80003144:	eee080e7          	jalr	-274(ra) # 8000302e <argraw>
    80003148:	c088                	sw	a0,0(s1)
}
    8000314a:	60e2                	ld	ra,24(sp)
    8000314c:	6442                	ld	s0,16(sp)
    8000314e:	64a2                	ld	s1,8(sp)
    80003150:	6105                	addi	sp,sp,32
    80003152:	8082                	ret

0000000080003154 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	e426                	sd	s1,8(sp)
    8000315c:	1000                	addi	s0,sp,32
    8000315e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003160:	00000097          	auipc	ra,0x0
    80003164:	ece080e7          	jalr	-306(ra) # 8000302e <argraw>
    80003168:	e088                	sd	a0,0(s1)
}
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	64a2                	ld	s1,8(sp)
    80003170:	6105                	addi	sp,sp,32
    80003172:	8082                	ret

0000000080003174 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003174:	1101                	addi	sp,sp,-32
    80003176:	ec06                	sd	ra,24(sp)
    80003178:	e822                	sd	s0,16(sp)
    8000317a:	e426                	sd	s1,8(sp)
    8000317c:	e04a                	sd	s2,0(sp)
    8000317e:	1000                	addi	s0,sp,32
    80003180:	84ae                	mv	s1,a1
    80003182:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003184:	00000097          	auipc	ra,0x0
    80003188:	eaa080e7          	jalr	-342(ra) # 8000302e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000318c:	864a                	mv	a2,s2
    8000318e:	85a6                	mv	a1,s1
    80003190:	00000097          	auipc	ra,0x0
    80003194:	f58080e7          	jalr	-168(ra) # 800030e8 <fetchstr>
}
    80003198:	60e2                	ld	ra,24(sp)
    8000319a:	6442                	ld	s0,16(sp)
    8000319c:	64a2                	ld	s1,8(sp)
    8000319e:	6902                	ld	s2,0(sp)
    800031a0:	6105                	addi	sp,sp,32
    800031a2:	8082                	ret

00000000800031a4 <syscall>:
    [SYS_sigreturn] sys_sigreturn,
    [SYS_settickets] sys_settickets,
};

void syscall(void)
{
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	e426                	sd	s1,8(sp)
    800031ac:	e04a                	sd	s2,0(sp)
    800031ae:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800031b0:	fffff097          	auipc	ra,0xfffff
    800031b4:	8b8080e7          	jalr	-1864(ra) # 80001a68 <myproc>
    800031b8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800031ba:	05853903          	ld	s2,88(a0)
    800031be:	0a893783          	ld	a5,168(s2)
    800031c2:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031c6:	37fd                	addiw	a5,a5,-1
    800031c8:	4765                	li	a4,25
    800031ca:	02f76763          	bltu	a4,a5,800031f8 <syscall+0x54>
    800031ce:	00369713          	slli	a4,a3,0x3
    800031d2:	00005797          	auipc	a5,0x5
    800031d6:	5b678793          	addi	a5,a5,1462 # 80008788 <syscalls>
    800031da:	97ba                	add	a5,a5,a4
    800031dc:	6398                	ld	a4,0(a5)
    800031de:	cf09                	beqz	a4,800031f8 <syscall+0x54>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->syscall_count[num]++;
    800031e0:	068a                	slli	a3,a3,0x2
    800031e2:	00d504b3          	add	s1,a0,a3
    800031e6:	1744a783          	lw	a5,372(s1)
    800031ea:	2785                	addiw	a5,a5,1
    800031ec:	16f4aa23          	sw	a5,372(s1)
    p->trapframe->a0 = syscalls[num]();
    800031f0:	9702                	jalr	a4
    800031f2:	06a93823          	sd	a0,112(s2)
    800031f6:	a839                	j	80003214 <syscall+0x70>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    800031f8:	15848613          	addi	a2,s1,344
    800031fc:	588c                	lw	a1,48(s1)
    800031fe:	00005517          	auipc	a0,0x5
    80003202:	1ca50513          	addi	a0,a0,458 # 800083c8 <etext+0x3c8>
    80003206:	ffffd097          	auipc	ra,0xffffd
    8000320a:	3a4080e7          	jalr	932(ra) # 800005aa <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000320e:	6cbc                	ld	a5,88(s1)
    80003210:	577d                	li	a4,-1
    80003212:	fbb8                	sd	a4,112(a5)
  }
}
    80003214:	60e2                	ld	ra,24(sp)
    80003216:	6442                	ld	s0,16(sp)
    80003218:	64a2                	ld	s1,8(sp)
    8000321a:	6902                	ld	s2,0(sp)
    8000321c:	6105                	addi	sp,sp,32
    8000321e:	8082                	ret

0000000080003220 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003220:	1101                	addi	sp,sp,-32
    80003222:	ec06                	sd	ra,24(sp)
    80003224:	e822                	sd	s0,16(sp)
    80003226:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003228:	fec40593          	addi	a1,s0,-20
    8000322c:	4501                	li	a0,0
    8000322e:	00000097          	auipc	ra,0x0
    80003232:	f06080e7          	jalr	-250(ra) # 80003134 <argint>
  exit(n);
    80003236:	fec42503          	lw	a0,-20(s0)
    8000323a:	fffff097          	auipc	ra,0xfffff
    8000323e:	382080e7          	jalr	898(ra) # 800025bc <exit>
  return 0; // not reached
}
    80003242:	4501                	li	a0,0
    80003244:	60e2                	ld	ra,24(sp)
    80003246:	6442                	ld	s0,16(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000324c:	1141                	addi	sp,sp,-16
    8000324e:	e406                	sd	ra,8(sp)
    80003250:	e022                	sd	s0,0(sp)
    80003252:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003254:	fffff097          	auipc	ra,0xfffff
    80003258:	814080e7          	jalr	-2028(ra) # 80001a68 <myproc>
}
    8000325c:	5908                	lw	a0,48(a0)
    8000325e:	60a2                	ld	ra,8(sp)
    80003260:	6402                	ld	s0,0(sp)
    80003262:	0141                	addi	sp,sp,16
    80003264:	8082                	ret

0000000080003266 <sys_fork>:

uint64
sys_fork(void)
{
    80003266:	1141                	addi	sp,sp,-16
    80003268:	e406                	sd	ra,8(sp)
    8000326a:	e022                	sd	s0,0(sp)
    8000326c:	0800                	addi	s0,sp,16
  return fork();
    8000326e:	fffff097          	auipc	ra,0xfffff
    80003272:	bec080e7          	jalr	-1044(ra) # 80001e5a <fork>
}
    80003276:	60a2                	ld	ra,8(sp)
    80003278:	6402                	ld	s0,0(sp)
    8000327a:	0141                	addi	sp,sp,16
    8000327c:	8082                	ret

000000008000327e <sys_wait>:

uint64
sys_wait(void)
{
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003286:	fe840593          	addi	a1,s0,-24
    8000328a:	4501                	li	a0,0
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	ec8080e7          	jalr	-312(ra) # 80003154 <argaddr>
  return wait(p);
    80003294:	fe843503          	ld	a0,-24(s0)
    80003298:	fffff097          	auipc	ra,0xfffff
    8000329c:	4d6080e7          	jalr	1238(ra) # 8000276e <wait>
}
    800032a0:	60e2                	ld	ra,24(sp)
    800032a2:	6442                	ld	s0,16(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032a8:	7179                	addi	sp,sp,-48
    800032aa:	f406                	sd	ra,40(sp)
    800032ac:	f022                	sd	s0,32(sp)
    800032ae:	ec26                	sd	s1,24(sp)
    800032b0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800032b2:	fdc40593          	addi	a1,s0,-36
    800032b6:	4501                	li	a0,0
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	e7c080e7          	jalr	-388(ra) # 80003134 <argint>
  addr = myproc()->sz;
    800032c0:	ffffe097          	auipc	ra,0xffffe
    800032c4:	7a8080e7          	jalr	1960(ra) # 80001a68 <myproc>
    800032c8:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800032ca:	fdc42503          	lw	a0,-36(s0)
    800032ce:	fffff097          	auipc	ra,0xfffff
    800032d2:	b30080e7          	jalr	-1232(ra) # 80001dfe <growproc>
    800032d6:	00054863          	bltz	a0,800032e6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800032da:	8526                	mv	a0,s1
    800032dc:	70a2                	ld	ra,40(sp)
    800032de:	7402                	ld	s0,32(sp)
    800032e0:	64e2                	ld	s1,24(sp)
    800032e2:	6145                	addi	sp,sp,48
    800032e4:	8082                	ret
    return -1;
    800032e6:	54fd                	li	s1,-1
    800032e8:	bfcd                	j	800032da <sys_sbrk+0x32>

00000000800032ea <sys_sleep>:

uint64
sys_sleep(void)
{
    800032ea:	7139                	addi	sp,sp,-64
    800032ec:	fc06                	sd	ra,56(sp)
    800032ee:	f822                	sd	s0,48(sp)
    800032f0:	f04a                	sd	s2,32(sp)
    800032f2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800032f4:	fcc40593          	addi	a1,s0,-52
    800032f8:	4501                	li	a0,0
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	e3a080e7          	jalr	-454(ra) # 80003134 <argint>
  acquire(&tickslock);
    80003302:	00017517          	auipc	a0,0x17
    80003306:	a8e50513          	addi	a0,a0,-1394 # 80019d90 <tickslock>
    8000330a:	ffffe097          	auipc	ra,0xffffe
    8000330e:	934080e7          	jalr	-1740(ra) # 80000c3e <acquire>
  ticks0 = ticks;
    80003312:	00005917          	auipc	s2,0x5
    80003316:	5de92903          	lw	s2,1502(s2) # 800088f0 <ticks>
  while (ticks - ticks0 < n)
    8000331a:	fcc42783          	lw	a5,-52(s0)
    8000331e:	c3b9                	beqz	a5,80003364 <sys_sleep+0x7a>
    80003320:	f426                	sd	s1,40(sp)
    80003322:	ec4e                	sd	s3,24(sp)
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003324:	00017997          	auipc	s3,0x17
    80003328:	a6c98993          	addi	s3,s3,-1428 # 80019d90 <tickslock>
    8000332c:	00005497          	auipc	s1,0x5
    80003330:	5c448493          	addi	s1,s1,1476 # 800088f0 <ticks>
    if (killed(myproc()))
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	734080e7          	jalr	1844(ra) # 80001a68 <myproc>
    8000333c:	fffff097          	auipc	ra,0xfffff
    80003340:	400080e7          	jalr	1024(ra) # 8000273c <killed>
    80003344:	ed15                	bnez	a0,80003380 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003346:	85ce                	mv	a1,s3
    80003348:	8526                	mv	a0,s1
    8000334a:	fffff097          	auipc	ra,0xfffff
    8000334e:	13e080e7          	jalr	318(ra) # 80002488 <sleep>
  while (ticks - ticks0 < n)
    80003352:	409c                	lw	a5,0(s1)
    80003354:	412787bb          	subw	a5,a5,s2
    80003358:	fcc42703          	lw	a4,-52(s0)
    8000335c:	fce7ece3          	bltu	a5,a4,80003334 <sys_sleep+0x4a>
    80003360:	74a2                	ld	s1,40(sp)
    80003362:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003364:	00017517          	auipc	a0,0x17
    80003368:	a2c50513          	addi	a0,a0,-1492 # 80019d90 <tickslock>
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	982080e7          	jalr	-1662(ra) # 80000cee <release>
  return 0;
    80003374:	4501                	li	a0,0
}
    80003376:	70e2                	ld	ra,56(sp)
    80003378:	7442                	ld	s0,48(sp)
    8000337a:	7902                	ld	s2,32(sp)
    8000337c:	6121                	addi	sp,sp,64
    8000337e:	8082                	ret
      release(&tickslock);
    80003380:	00017517          	auipc	a0,0x17
    80003384:	a1050513          	addi	a0,a0,-1520 # 80019d90 <tickslock>
    80003388:	ffffe097          	auipc	ra,0xffffe
    8000338c:	966080e7          	jalr	-1690(ra) # 80000cee <release>
      return -1;
    80003390:	557d                	li	a0,-1
    80003392:	74a2                	ld	s1,40(sp)
    80003394:	69e2                	ld	s3,24(sp)
    80003396:	b7c5                	j	80003376 <sys_sleep+0x8c>

0000000080003398 <sys_kill>:

uint64
sys_kill(void)
{
    80003398:	1101                	addi	sp,sp,-32
    8000339a:	ec06                	sd	ra,24(sp)
    8000339c:	e822                	sd	s0,16(sp)
    8000339e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033a0:	fec40593          	addi	a1,s0,-20
    800033a4:	4501                	li	a0,0
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	d8e080e7          	jalr	-626(ra) # 80003134 <argint>
  return kill(pid);
    800033ae:	fec42503          	lw	a0,-20(s0)
    800033b2:	fffff097          	auipc	ra,0xfffff
    800033b6:	2ec080e7          	jalr	748(ra) # 8000269e <kill>
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret

00000000800033c2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033cc:	00017517          	auipc	a0,0x17
    800033d0:	9c450513          	addi	a0,a0,-1596 # 80019d90 <tickslock>
    800033d4:	ffffe097          	auipc	ra,0xffffe
    800033d8:	86a080e7          	jalr	-1942(ra) # 80000c3e <acquire>
  xticks = ticks;
    800033dc:	00005497          	auipc	s1,0x5
    800033e0:	5144a483          	lw	s1,1300(s1) # 800088f0 <ticks>
  release(&tickslock);
    800033e4:	00017517          	auipc	a0,0x17
    800033e8:	9ac50513          	addi	a0,a0,-1620 # 80019d90 <tickslock>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	902080e7          	jalr	-1790(ra) # 80000cee <release>
  return xticks;
}
    800033f4:	02049513          	slli	a0,s1,0x20
    800033f8:	9101                	srli	a0,a0,0x20
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret

0000000080003404 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003404:	715d                	addi	sp,sp,-80
    80003406:	e486                	sd	ra,72(sp)
    80003408:	e0a2                	sd	s0,64(sp)
    8000340a:	fc26                	sd	s1,56(sp)
    8000340c:	f84a                	sd	s2,48(sp)
    8000340e:	f44e                	sd	s3,40(sp)
    80003410:	0880                	addi	s0,sp,80
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003412:	fc840593          	addi	a1,s0,-56
    80003416:	4501                	li	a0,0
    80003418:	00000097          	auipc	ra,0x0
    8000341c:	d3c080e7          	jalr	-708(ra) # 80003154 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003420:	fc040593          	addi	a1,s0,-64
    80003424:	4505                	li	a0,1
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	d2e080e7          	jalr	-722(ra) # 80003154 <argaddr>
  argaddr(2, &addr2);
    8000342e:	fb840593          	addi	a1,s0,-72
    80003432:	4509                	li	a0,2
    80003434:	00000097          	auipc	ra,0x0
    80003438:	d20080e7          	jalr	-736(ra) # 80003154 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000343c:	fb440993          	addi	s3,s0,-76
    80003440:	fb040613          	addi	a2,s0,-80
    80003444:	85ce                	mv	a1,s3
    80003446:	fc843503          	ld	a0,-56(s0)
    8000344a:	fffff097          	auipc	ra,0xfffff
    8000344e:	5c4080e7          	jalr	1476(ra) # 80002a0e <waitx>
    80003452:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	614080e7          	jalr	1556(ra) # 80001a68 <myproc>
    8000345c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000345e:	4691                	li	a3,4
    80003460:	864e                	mv	a2,s3
    80003462:	fc043583          	ld	a1,-64(s0)
    80003466:	6928                	ld	a0,80(a0)
    80003468:	ffffe097          	auipc	ra,0xffffe
    8000346c:	2a8080e7          	jalr	680(ra) # 80001710 <copyout>
    return -1;
    80003470:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003472:	00054f63          	bltz	a0,80003490 <sys_waitx+0x8c>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003476:	4691                	li	a3,4
    80003478:	fb040613          	addi	a2,s0,-80
    8000347c:	fb843583          	ld	a1,-72(s0)
    80003480:	68a8                	ld	a0,80(s1)
    80003482:	ffffe097          	auipc	ra,0xffffe
    80003486:	28e080e7          	jalr	654(ra) # 80001710 <copyout>
    8000348a:	00054b63          	bltz	a0,800034a0 <sys_waitx+0x9c>
    return -1;
  return ret;
    8000348e:	87ca                	mv	a5,s2
}
    80003490:	853e                	mv	a0,a5
    80003492:	60a6                	ld	ra,72(sp)
    80003494:	6406                	ld	s0,64(sp)
    80003496:	74e2                	ld	s1,56(sp)
    80003498:	7942                	ld	s2,48(sp)
    8000349a:	79a2                	ld	s3,40(sp)
    8000349c:	6161                	addi	sp,sp,80
    8000349e:	8082                	ret
    return -1;
    800034a0:	57fd                	li	a5,-1
    800034a2:	b7fd                	j	80003490 <sys_waitx+0x8c>

00000000800034a4 <sys_getSysCount>:

uint64 sys_getSysCount(void)
{
    800034a4:	1101                	addi	sp,sp,-32
    800034a6:	ec06                	sd	ra,24(sp)
    800034a8:	e822                	sd	s0,16(sp)
    800034aa:	1000                	addi	s0,sp,32
  int pid;
  int syscall_num;

  argint(0, &pid);
    800034ac:	fec40593          	addi	a1,s0,-20
    800034b0:	4501                	li	a0,0
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	c82080e7          	jalr	-894(ra) # 80003134 <argint>
  argint(1, &syscall_num);
    800034ba:	fe840593          	addi	a1,s0,-24
    800034be:	4505                	li	a0,1
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	c74080e7          	jalr	-908(ra) # 80003134 <argint>

  struct proc *p;
  // Find the process with the specified pid
  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p->pid == pid)
    800034c8:	fec42683          	lw	a3,-20(s0)
  for (p = proc; p < &proc[NPROC]; p++)
    800034cc:	0000e797          	auipc	a5,0xe
    800034d0:	ac478793          	addi	a5,a5,-1340 # 80010f90 <proc>
    800034d4:	00017617          	auipc	a2,0x17
    800034d8:	8bc60613          	addi	a2,a2,-1860 # 80019d90 <tickslock>
    if (p->pid == pid)
    800034dc:	5b98                	lw	a4,48(a5)
    800034de:	00d70863          	beq	a4,a3,800034ee <sys_getSysCount+0x4a>
  for (p = proc; p < &proc[NPROC]; p++)
    800034e2:	23878793          	addi	a5,a5,568
    800034e6:	fec79be3          	bne	a5,a2,800034dc <sys_getSysCount+0x38>
    {
      return p->syscall_count[syscall_num]; // Return the syscall count
    }
  }
  return -1; // Process not found
    800034ea:	557d                	li	a0,-1
    800034ec:	a801                	j	800034fc <sys_getSysCount+0x58>
      return p->syscall_count[syscall_num]; // Return the syscall count
    800034ee:	fe842703          	lw	a4,-24(s0)
    800034f2:	05c70713          	addi	a4,a4,92
    800034f6:	070a                	slli	a4,a4,0x2
    800034f8:	97ba                	add	a5,a5,a4
    800034fa:	43c8                	lw	a0,4(a5)
}
    800034fc:	60e2                	ld	ra,24(sp)
    800034fe:	6442                	ld	s0,16(sp)
    80003500:	6105                	addi	sp,sp,32
    80003502:	8082                	ret

0000000080003504 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80003504:	7179                	addi	sp,sp,-48
    80003506:	f406                	sd	ra,40(sp)
    80003508:	f022                	sd	s0,32(sp)
    8000350a:	ec26                	sd	s1,24(sp)
    8000350c:	1800                	addi	s0,sp,48
  // current process
  struct proc* p = myproc();
    8000350e:	ffffe097          	auipc	ra,0xffffe
    80003512:	55a080e7          	jalr	1370(ra) # 80001a68 <myproc>
    80003516:	84aa                	mv	s1,a0
  int period;
  argint(0, &period);
    80003518:	fdc40593          	addi	a1,s0,-36
    8000351c:	4501                	li	a0,0
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	c16080e7          	jalr	-1002(ra) # 80003134 <argint>
  argaddr(1, &p->handler_function);
    80003526:	20848593          	addi	a1,s1,520
    8000352a:	4505                	li	a0,1
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	c28080e7          	jalr	-984(ra) # 80003154 <argaddr>

  p->period = period;
    80003534:	fdc42783          	lw	a5,-36(s0)
    80003538:	20f4a023          	sw	a5,512(s1)
  p->left_ticks = period;
    8000353c:	20f4a823          	sw	a5,528(s1)
  p->in_handlefunc = 0;
    80003540:	20048a23          	sb	zero,532(s1)

  return 0;
}
    80003544:	4501                	li	a0,0
    80003546:	70a2                	ld	ra,40(sp)
    80003548:	7402                	ld	s0,32(sp)
    8000354a:	64e2                	ld	s1,24(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret

0000000080003550 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    80003550:	1101                	addi	sp,sp,-32
    80003552:	ec06                	sd	ra,24(sp)
    80003554:	e822                	sd	s0,16(sp)
    80003556:	1000                	addi	s0,sp,32
  struct proc* p = myproc();
    80003558:	ffffe097          	auipc	ra,0xffffe
    8000355c:	510080e7          	jalr	1296(ra) # 80001a68 <myproc>

  if(p->in_handlefunc && p->tf_stored){
    80003560:	21454783          	lbu	a5,532(a0)
    80003564:	cb8d                	beqz	a5,80003596 <sys_sigreturn+0x46>
    80003566:	e426                	sd	s1,8(sp)
    80003568:	84aa                	mv	s1,a0
    8000356a:	1f853583          	ld	a1,504(a0)
    8000356e:	c98d                	beqz	a1,800035a0 <sys_sigreturn+0x50>

    // restoring the original trapframe of the process, freeing the kalloced page.
    memmove(p->trapframe, p->tf_stored, PGSIZE);
    80003570:	6605                	lui	a2,0x1
    80003572:	6d28                	ld	a0,88(a0)
    80003574:	ffffe097          	auipc	ra,0xffffe
    80003578:	826080e7          	jalr	-2010(ra) # 80000d9a <memmove>
    kfree(p->tf_stored);
    8000357c:	1f84b503          	ld	a0,504(s1)
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	4cc080e7          	jalr	1228(ra) # 80000a4c <kfree>
    
    //printf("%p", p->trapframe->a0);
    p->left_ticks = p->period;
    80003588:	2004a783          	lw	a5,512(s1)
    8000358c:	20f4a823          	sw	a5,528(s1)
    p->in_handlefunc = 0;
    80003590:	20048a23          	sb	zero,532(s1)
    80003594:	64a2                	ld	s1,8(sp)
  }
  
  return 0;
}
    80003596:	4501                	li	a0,0
    80003598:	60e2                	ld	ra,24(sp)
    8000359a:	6442                	ld	s0,16(sp)
    8000359c:	6105                	addi	sp,sp,32
    8000359e:	8082                	ret
    800035a0:	64a2                	ld	s1,8(sp)
    800035a2:	bfd5                	j	80003596 <sys_sigreturn+0x46>

00000000800035a4 <sys_settickets>:


uint64 sys_settickets(void)
{
    800035a4:	1101                	addi	sp,sp,-32
    800035a6:	ec06                	sd	ra,24(sp)
    800035a8:	e822                	sd	s0,16(sp)
    800035aa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800035ac:	fec40593          	addi	a1,s0,-20
    800035b0:	4501                	li	a0,0
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	b82080e7          	jalr	-1150(ra) # 80003134 <argint>

  if (n < 1) // Ensure the number of tickets is valid
    800035ba:	fec42783          	lw	a5,-20(s0)
    return -1;
    800035be:	557d                	li	a0,-1
  if (n < 1) // Ensure the number of tickets is valid
    800035c0:	00f05b63          	blez	a5,800035d6 <sys_settickets+0x32>

  myproc()->tickets = n; // Set the number of tickets for the current process
    800035c4:	ffffe097          	auipc	ra,0xffffe
    800035c8:	4a4080e7          	jalr	1188(ra) # 80001a68 <myproc>
    800035cc:	fec42783          	lw	a5,-20(s0)
    800035d0:	20f52c23          	sw	a5,536(a0)
  return 0;
    800035d4:	4501                	li	a0,0
    800035d6:	60e2                	ld	ra,24(sp)
    800035d8:	6442                	ld	s0,16(sp)
    800035da:	6105                	addi	sp,sp,32
    800035dc:	8082                	ret

00000000800035de <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035de:	7179                	addi	sp,sp,-48
    800035e0:	f406                	sd	ra,40(sp)
    800035e2:	f022                	sd	s0,32(sp)
    800035e4:	ec26                	sd	s1,24(sp)
    800035e6:	e84a                	sd	s2,16(sp)
    800035e8:	e44e                	sd	s3,8(sp)
    800035ea:	e052                	sd	s4,0(sp)
    800035ec:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800035ee:	00005597          	auipc	a1,0x5
    800035f2:	dfa58593          	addi	a1,a1,-518 # 800083e8 <etext+0x3e8>
    800035f6:	00016517          	auipc	a0,0x16
    800035fa:	7b250513          	addi	a0,a0,1970 # 80019da8 <bcache>
    800035fe:	ffffd097          	auipc	ra,0xffffd
    80003602:	5ac080e7          	jalr	1452(ra) # 80000baa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003606:	0001e797          	auipc	a5,0x1e
    8000360a:	7a278793          	addi	a5,a5,1954 # 80021da8 <bcache+0x8000>
    8000360e:	0001f717          	auipc	a4,0x1f
    80003612:	a0270713          	addi	a4,a4,-1534 # 80022010 <bcache+0x8268>
    80003616:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000361a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000361e:	00016497          	auipc	s1,0x16
    80003622:	7a248493          	addi	s1,s1,1954 # 80019dc0 <bcache+0x18>
    b->next = bcache.head.next;
    80003626:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003628:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000362a:	00005a17          	auipc	s4,0x5
    8000362e:	dc6a0a13          	addi	s4,s4,-570 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80003632:	2b893783          	ld	a5,696(s2)
    80003636:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003638:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000363c:	85d2                	mv	a1,s4
    8000363e:	01048513          	addi	a0,s1,16
    80003642:	00001097          	auipc	ra,0x1
    80003646:	4e4080e7          	jalr	1252(ra) # 80004b26 <initsleeplock>
    bcache.head.next->prev = b;
    8000364a:	2b893783          	ld	a5,696(s2)
    8000364e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003650:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003654:	45848493          	addi	s1,s1,1112
    80003658:	fd349de3          	bne	s1,s3,80003632 <binit+0x54>
  }
}
    8000365c:	70a2                	ld	ra,40(sp)
    8000365e:	7402                	ld	s0,32(sp)
    80003660:	64e2                	ld	s1,24(sp)
    80003662:	6942                	ld	s2,16(sp)
    80003664:	69a2                	ld	s3,8(sp)
    80003666:	6a02                	ld	s4,0(sp)
    80003668:	6145                	addi	sp,sp,48
    8000366a:	8082                	ret

000000008000366c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000366c:	7179                	addi	sp,sp,-48
    8000366e:	f406                	sd	ra,40(sp)
    80003670:	f022                	sd	s0,32(sp)
    80003672:	ec26                	sd	s1,24(sp)
    80003674:	e84a                	sd	s2,16(sp)
    80003676:	e44e                	sd	s3,8(sp)
    80003678:	1800                	addi	s0,sp,48
    8000367a:	892a                	mv	s2,a0
    8000367c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000367e:	00016517          	auipc	a0,0x16
    80003682:	72a50513          	addi	a0,a0,1834 # 80019da8 <bcache>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	5b8080e7          	jalr	1464(ra) # 80000c3e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000368e:	0001f497          	auipc	s1,0x1f
    80003692:	9d24b483          	ld	s1,-1582(s1) # 80022060 <bcache+0x82b8>
    80003696:	0001f797          	auipc	a5,0x1f
    8000369a:	97a78793          	addi	a5,a5,-1670 # 80022010 <bcache+0x8268>
    8000369e:	02f48f63          	beq	s1,a5,800036dc <bread+0x70>
    800036a2:	873e                	mv	a4,a5
    800036a4:	a021                	j	800036ac <bread+0x40>
    800036a6:	68a4                	ld	s1,80(s1)
    800036a8:	02e48a63          	beq	s1,a4,800036dc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036ac:	449c                	lw	a5,8(s1)
    800036ae:	ff279ce3          	bne	a5,s2,800036a6 <bread+0x3a>
    800036b2:	44dc                	lw	a5,12(s1)
    800036b4:	ff3799e3          	bne	a5,s3,800036a6 <bread+0x3a>
      b->refcnt++;
    800036b8:	40bc                	lw	a5,64(s1)
    800036ba:	2785                	addiw	a5,a5,1
    800036bc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036be:	00016517          	auipc	a0,0x16
    800036c2:	6ea50513          	addi	a0,a0,1770 # 80019da8 <bcache>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	628080e7          	jalr	1576(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    800036ce:	01048513          	addi	a0,s1,16
    800036d2:	00001097          	auipc	ra,0x1
    800036d6:	48e080e7          	jalr	1166(ra) # 80004b60 <acquiresleep>
      return b;
    800036da:	a8b9                	j	80003738 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036dc:	0001f497          	auipc	s1,0x1f
    800036e0:	97c4b483          	ld	s1,-1668(s1) # 80022058 <bcache+0x82b0>
    800036e4:	0001f797          	auipc	a5,0x1f
    800036e8:	92c78793          	addi	a5,a5,-1748 # 80022010 <bcache+0x8268>
    800036ec:	00f48863          	beq	s1,a5,800036fc <bread+0x90>
    800036f0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036f2:	40bc                	lw	a5,64(s1)
    800036f4:	cf81                	beqz	a5,8000370c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036f6:	64a4                	ld	s1,72(s1)
    800036f8:	fee49de3          	bne	s1,a4,800036f2 <bread+0x86>
  panic("bget: no buffers");
    800036fc:	00005517          	auipc	a0,0x5
    80003700:	cfc50513          	addi	a0,a0,-772 # 800083f8 <etext+0x3f8>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e5c080e7          	jalr	-420(ra) # 80000560 <panic>
      b->dev = dev;
    8000370c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003710:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003714:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003718:	4785                	li	a5,1
    8000371a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000371c:	00016517          	auipc	a0,0x16
    80003720:	68c50513          	addi	a0,a0,1676 # 80019da8 <bcache>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	5ca080e7          	jalr	1482(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    8000372c:	01048513          	addi	a0,s1,16
    80003730:	00001097          	auipc	ra,0x1
    80003734:	430080e7          	jalr	1072(ra) # 80004b60 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003738:	409c                	lw	a5,0(s1)
    8000373a:	cb89                	beqz	a5,8000374c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000373c:	8526                	mv	a0,s1
    8000373e:	70a2                	ld	ra,40(sp)
    80003740:	7402                	ld	s0,32(sp)
    80003742:	64e2                	ld	s1,24(sp)
    80003744:	6942                	ld	s2,16(sp)
    80003746:	69a2                	ld	s3,8(sp)
    80003748:	6145                	addi	sp,sp,48
    8000374a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000374c:	4581                	li	a1,0
    8000374e:	8526                	mv	a0,s1
    80003750:	00003097          	auipc	ra,0x3
    80003754:	108080e7          	jalr	264(ra) # 80006858 <virtio_disk_rw>
    b->valid = 1;
    80003758:	4785                	li	a5,1
    8000375a:	c09c                	sw	a5,0(s1)
  return b;
    8000375c:	b7c5                	j	8000373c <bread+0xd0>

000000008000375e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000375e:	1101                	addi	sp,sp,-32
    80003760:	ec06                	sd	ra,24(sp)
    80003762:	e822                	sd	s0,16(sp)
    80003764:	e426                	sd	s1,8(sp)
    80003766:	1000                	addi	s0,sp,32
    80003768:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000376a:	0541                	addi	a0,a0,16
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	48e080e7          	jalr	1166(ra) # 80004bfa <holdingsleep>
    80003774:	cd01                	beqz	a0,8000378c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003776:	4585                	li	a1,1
    80003778:	8526                	mv	a0,s1
    8000377a:	00003097          	auipc	ra,0x3
    8000377e:	0de080e7          	jalr	222(ra) # 80006858 <virtio_disk_rw>
}
    80003782:	60e2                	ld	ra,24(sp)
    80003784:	6442                	ld	s0,16(sp)
    80003786:	64a2                	ld	s1,8(sp)
    80003788:	6105                	addi	sp,sp,32
    8000378a:	8082                	ret
    panic("bwrite");
    8000378c:	00005517          	auipc	a0,0x5
    80003790:	c8450513          	addi	a0,a0,-892 # 80008410 <etext+0x410>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	dcc080e7          	jalr	-564(ra) # 80000560 <panic>

000000008000379c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000379c:	1101                	addi	sp,sp,-32
    8000379e:	ec06                	sd	ra,24(sp)
    800037a0:	e822                	sd	s0,16(sp)
    800037a2:	e426                	sd	s1,8(sp)
    800037a4:	e04a                	sd	s2,0(sp)
    800037a6:	1000                	addi	s0,sp,32
    800037a8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037aa:	01050913          	addi	s2,a0,16
    800037ae:	854a                	mv	a0,s2
    800037b0:	00001097          	auipc	ra,0x1
    800037b4:	44a080e7          	jalr	1098(ra) # 80004bfa <holdingsleep>
    800037b8:	c535                	beqz	a0,80003824 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    800037ba:	854a                	mv	a0,s2
    800037bc:	00001097          	auipc	ra,0x1
    800037c0:	3fa080e7          	jalr	1018(ra) # 80004bb6 <releasesleep>

  acquire(&bcache.lock);
    800037c4:	00016517          	auipc	a0,0x16
    800037c8:	5e450513          	addi	a0,a0,1508 # 80019da8 <bcache>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	472080e7          	jalr	1138(ra) # 80000c3e <acquire>
  b->refcnt--;
    800037d4:	40bc                	lw	a5,64(s1)
    800037d6:	37fd                	addiw	a5,a5,-1
    800037d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800037da:	e79d                	bnez	a5,80003808 <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037dc:	68b8                	ld	a4,80(s1)
    800037de:	64bc                	ld	a5,72(s1)
    800037e0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800037e2:	68b8                	ld	a4,80(s1)
    800037e4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800037e6:	0001e797          	auipc	a5,0x1e
    800037ea:	5c278793          	addi	a5,a5,1474 # 80021da8 <bcache+0x8000>
    800037ee:	2b87b703          	ld	a4,696(a5)
    800037f2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800037f4:	0001f717          	auipc	a4,0x1f
    800037f8:	81c70713          	addi	a4,a4,-2020 # 80022010 <bcache+0x8268>
    800037fc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800037fe:	2b87b703          	ld	a4,696(a5)
    80003802:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003804:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003808:	00016517          	auipc	a0,0x16
    8000380c:	5a050513          	addi	a0,a0,1440 # 80019da8 <bcache>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	4de080e7          	jalr	1246(ra) # 80000cee <release>
}
    80003818:	60e2                	ld	ra,24(sp)
    8000381a:	6442                	ld	s0,16(sp)
    8000381c:	64a2                	ld	s1,8(sp)
    8000381e:	6902                	ld	s2,0(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret
    panic("brelse");
    80003824:	00005517          	auipc	a0,0x5
    80003828:	bf450513          	addi	a0,a0,-1036 # 80008418 <etext+0x418>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	d34080e7          	jalr	-716(ra) # 80000560 <panic>

0000000080003834 <bpin>:

void
bpin(struct buf *b) {
    80003834:	1101                	addi	sp,sp,-32
    80003836:	ec06                	sd	ra,24(sp)
    80003838:	e822                	sd	s0,16(sp)
    8000383a:	e426                	sd	s1,8(sp)
    8000383c:	1000                	addi	s0,sp,32
    8000383e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003840:	00016517          	auipc	a0,0x16
    80003844:	56850513          	addi	a0,a0,1384 # 80019da8 <bcache>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	3f6080e7          	jalr	1014(ra) # 80000c3e <acquire>
  b->refcnt++;
    80003850:	40bc                	lw	a5,64(s1)
    80003852:	2785                	addiw	a5,a5,1
    80003854:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003856:	00016517          	auipc	a0,0x16
    8000385a:	55250513          	addi	a0,a0,1362 # 80019da8 <bcache>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	490080e7          	jalr	1168(ra) # 80000cee <release>
}
    80003866:	60e2                	ld	ra,24(sp)
    80003868:	6442                	ld	s0,16(sp)
    8000386a:	64a2                	ld	s1,8(sp)
    8000386c:	6105                	addi	sp,sp,32
    8000386e:	8082                	ret

0000000080003870 <bunpin>:

void
bunpin(struct buf *b) {
    80003870:	1101                	addi	sp,sp,-32
    80003872:	ec06                	sd	ra,24(sp)
    80003874:	e822                	sd	s0,16(sp)
    80003876:	e426                	sd	s1,8(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000387c:	00016517          	auipc	a0,0x16
    80003880:	52c50513          	addi	a0,a0,1324 # 80019da8 <bcache>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	3ba080e7          	jalr	954(ra) # 80000c3e <acquire>
  b->refcnt--;
    8000388c:	40bc                	lw	a5,64(s1)
    8000388e:	37fd                	addiw	a5,a5,-1
    80003890:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003892:	00016517          	auipc	a0,0x16
    80003896:	51650513          	addi	a0,a0,1302 # 80019da8 <bcache>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	454080e7          	jalr	1108(ra) # 80000cee <release>
}
    800038a2:	60e2                	ld	ra,24(sp)
    800038a4:	6442                	ld	s0,16(sp)
    800038a6:	64a2                	ld	s1,8(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	e04a                	sd	s2,0(sp)
    800038b6:	1000                	addi	s0,sp,32
    800038b8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038ba:	00d5d79b          	srliw	a5,a1,0xd
    800038be:	0001f597          	auipc	a1,0x1f
    800038c2:	bc65a583          	lw	a1,-1082(a1) # 80022484 <sb+0x1c>
    800038c6:	9dbd                	addw	a1,a1,a5
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	da4080e7          	jalr	-604(ra) # 8000366c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800038d0:	0074f713          	andi	a4,s1,7
    800038d4:	4785                	li	a5,1
    800038d6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800038da:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800038dc:	90d9                	srli	s1,s1,0x36
    800038de:	00950733          	add	a4,a0,s1
    800038e2:	05874703          	lbu	a4,88(a4)
    800038e6:	00e7f6b3          	and	a3,a5,a4
    800038ea:	c69d                	beqz	a3,80003918 <bfree+0x6c>
    800038ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038ee:	94aa                	add	s1,s1,a0
    800038f0:	fff7c793          	not	a5,a5
    800038f4:	8f7d                	and	a4,a4,a5
    800038f6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800038fa:	00001097          	auipc	ra,0x1
    800038fe:	148080e7          	jalr	328(ra) # 80004a42 <log_write>
  brelse(bp);
    80003902:	854a                	mv	a0,s2
    80003904:	00000097          	auipc	ra,0x0
    80003908:	e98080e7          	jalr	-360(ra) # 8000379c <brelse>
}
    8000390c:	60e2                	ld	ra,24(sp)
    8000390e:	6442                	ld	s0,16(sp)
    80003910:	64a2                	ld	s1,8(sp)
    80003912:	6902                	ld	s2,0(sp)
    80003914:	6105                	addi	sp,sp,32
    80003916:	8082                	ret
    panic("freeing free block");
    80003918:	00005517          	auipc	a0,0x5
    8000391c:	b0850513          	addi	a0,a0,-1272 # 80008420 <etext+0x420>
    80003920:	ffffd097          	auipc	ra,0xffffd
    80003924:	c40080e7          	jalr	-960(ra) # 80000560 <panic>

0000000080003928 <balloc>:
{
    80003928:	715d                	addi	sp,sp,-80
    8000392a:	e486                	sd	ra,72(sp)
    8000392c:	e0a2                	sd	s0,64(sp)
    8000392e:	fc26                	sd	s1,56(sp)
    80003930:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003932:	0001f797          	auipc	a5,0x1f
    80003936:	b3a7a783          	lw	a5,-1222(a5) # 8002246c <sb+0x4>
    8000393a:	10078863          	beqz	a5,80003a4a <balloc+0x122>
    8000393e:	f84a                	sd	s2,48(sp)
    80003940:	f44e                	sd	s3,40(sp)
    80003942:	f052                	sd	s4,32(sp)
    80003944:	ec56                	sd	s5,24(sp)
    80003946:	e85a                	sd	s6,16(sp)
    80003948:	e45e                	sd	s7,8(sp)
    8000394a:	e062                	sd	s8,0(sp)
    8000394c:	8baa                	mv	s7,a0
    8000394e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003950:	0001fb17          	auipc	s6,0x1f
    80003954:	b18b0b13          	addi	s6,s6,-1256 # 80022468 <sb>
      m = 1 << (bi % 8);
    80003958:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000395a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000395c:	6c09                	lui	s8,0x2
    8000395e:	a049                	j	800039e0 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003960:	97ca                	add	a5,a5,s2
    80003962:	8e55                	or	a2,a2,a3
    80003964:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003968:	854a                	mv	a0,s2
    8000396a:	00001097          	auipc	ra,0x1
    8000396e:	0d8080e7          	jalr	216(ra) # 80004a42 <log_write>
        brelse(bp);
    80003972:	854a                	mv	a0,s2
    80003974:	00000097          	auipc	ra,0x0
    80003978:	e28080e7          	jalr	-472(ra) # 8000379c <brelse>
  bp = bread(dev, bno);
    8000397c:	85a6                	mv	a1,s1
    8000397e:	855e                	mv	a0,s7
    80003980:	00000097          	auipc	ra,0x0
    80003984:	cec080e7          	jalr	-788(ra) # 8000366c <bread>
    80003988:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000398a:	40000613          	li	a2,1024
    8000398e:	4581                	li	a1,0
    80003990:	05850513          	addi	a0,a0,88
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	3a2080e7          	jalr	930(ra) # 80000d36 <memset>
  log_write(bp);
    8000399c:	854a                	mv	a0,s2
    8000399e:	00001097          	auipc	ra,0x1
    800039a2:	0a4080e7          	jalr	164(ra) # 80004a42 <log_write>
  brelse(bp);
    800039a6:	854a                	mv	a0,s2
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	df4080e7          	jalr	-524(ra) # 8000379c <brelse>
}
    800039b0:	7942                	ld	s2,48(sp)
    800039b2:	79a2                	ld	s3,40(sp)
    800039b4:	7a02                	ld	s4,32(sp)
    800039b6:	6ae2                	ld	s5,24(sp)
    800039b8:	6b42                	ld	s6,16(sp)
    800039ba:	6ba2                	ld	s7,8(sp)
    800039bc:	6c02                	ld	s8,0(sp)
}
    800039be:	8526                	mv	a0,s1
    800039c0:	60a6                	ld	ra,72(sp)
    800039c2:	6406                	ld	s0,64(sp)
    800039c4:	74e2                	ld	s1,56(sp)
    800039c6:	6161                	addi	sp,sp,80
    800039c8:	8082                	ret
    brelse(bp);
    800039ca:	854a                	mv	a0,s2
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	dd0080e7          	jalr	-560(ra) # 8000379c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800039d4:	015c0abb          	addw	s5,s8,s5
    800039d8:	004b2783          	lw	a5,4(s6)
    800039dc:	06faf063          	bgeu	s5,a5,80003a3c <balloc+0x114>
    bp = bread(dev, BBLOCK(b, sb));
    800039e0:	41fad79b          	sraiw	a5,s5,0x1f
    800039e4:	0137d79b          	srliw	a5,a5,0x13
    800039e8:	015787bb          	addw	a5,a5,s5
    800039ec:	40d7d79b          	sraiw	a5,a5,0xd
    800039f0:	01cb2583          	lw	a1,28(s6)
    800039f4:	9dbd                	addw	a1,a1,a5
    800039f6:	855e                	mv	a0,s7
    800039f8:	00000097          	auipc	ra,0x0
    800039fc:	c74080e7          	jalr	-908(ra) # 8000366c <bread>
    80003a00:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a02:	004b2503          	lw	a0,4(s6)
    80003a06:	84d6                	mv	s1,s5
    80003a08:	4701                	li	a4,0
    80003a0a:	fca4f0e3          	bgeu	s1,a0,800039ca <balloc+0xa2>
      m = 1 << (bi % 8);
    80003a0e:	00777693          	andi	a3,a4,7
    80003a12:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a16:	41f7579b          	sraiw	a5,a4,0x1f
    80003a1a:	01d7d79b          	srliw	a5,a5,0x1d
    80003a1e:	9fb9                	addw	a5,a5,a4
    80003a20:	4037d79b          	sraiw	a5,a5,0x3
    80003a24:	00f90633          	add	a2,s2,a5
    80003a28:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003a2c:	00c6f5b3          	and	a1,a3,a2
    80003a30:	d985                	beqz	a1,80003960 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a32:	2705                	addiw	a4,a4,1
    80003a34:	2485                	addiw	s1,s1,1
    80003a36:	fd471ae3          	bne	a4,s4,80003a0a <balloc+0xe2>
    80003a3a:	bf41                	j	800039ca <balloc+0xa2>
    80003a3c:	7942                	ld	s2,48(sp)
    80003a3e:	79a2                	ld	s3,40(sp)
    80003a40:	7a02                	ld	s4,32(sp)
    80003a42:	6ae2                	ld	s5,24(sp)
    80003a44:	6b42                	ld	s6,16(sp)
    80003a46:	6ba2                	ld	s7,8(sp)
    80003a48:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003a4a:	00005517          	auipc	a0,0x5
    80003a4e:	9ee50513          	addi	a0,a0,-1554 # 80008438 <etext+0x438>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	b58080e7          	jalr	-1192(ra) # 800005aa <printf>
  return 0;
    80003a5a:	4481                	li	s1,0
    80003a5c:	b78d                	j	800039be <balloc+0x96>

0000000080003a5e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a5e:	7179                	addi	sp,sp,-48
    80003a60:	f406                	sd	ra,40(sp)
    80003a62:	f022                	sd	s0,32(sp)
    80003a64:	ec26                	sd	s1,24(sp)
    80003a66:	e84a                	sd	s2,16(sp)
    80003a68:	e44e                	sd	s3,8(sp)
    80003a6a:	1800                	addi	s0,sp,48
    80003a6c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a6e:	47ad                	li	a5,11
    80003a70:	02b7e563          	bltu	a5,a1,80003a9a <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    80003a74:	02059793          	slli	a5,a1,0x20
    80003a78:	01e7d593          	srli	a1,a5,0x1e
    80003a7c:	00b504b3          	add	s1,a0,a1
    80003a80:	0504a903          	lw	s2,80(s1)
    80003a84:	06091b63          	bnez	s2,80003afa <bmap+0x9c>
      addr = balloc(ip->dev);
    80003a88:	4108                	lw	a0,0(a0)
    80003a8a:	00000097          	auipc	ra,0x0
    80003a8e:	e9e080e7          	jalr	-354(ra) # 80003928 <balloc>
    80003a92:	892a                	mv	s2,a0
      if(addr == 0)
    80003a94:	c13d                	beqz	a0,80003afa <bmap+0x9c>
        return 0;
      ip->addrs[bn] = addr;
    80003a96:	c8a8                	sw	a0,80(s1)
    80003a98:	a08d                	j	80003afa <bmap+0x9c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003a9a:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80003a9e:	0ff00793          	li	a5,255
    80003aa2:	0897e363          	bltu	a5,s1,80003b28 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003aa6:	08052903          	lw	s2,128(a0)
    80003aaa:	00091d63          	bnez	s2,80003ac4 <bmap+0x66>
      addr = balloc(ip->dev);
    80003aae:	4108                	lw	a0,0(a0)
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	e78080e7          	jalr	-392(ra) # 80003928 <balloc>
    80003ab8:	892a                	mv	s2,a0
      if(addr == 0)
    80003aba:	c121                	beqz	a0,80003afa <bmap+0x9c>
    80003abc:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003abe:	08a9a023          	sw	a0,128(s3)
    80003ac2:	a011                	j	80003ac6 <bmap+0x68>
    80003ac4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003ac6:	85ca                	mv	a1,s2
    80003ac8:	0009a503          	lw	a0,0(s3)
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	ba0080e7          	jalr	-1120(ra) # 8000366c <bread>
    80003ad4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003ad6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003ada:	02049713          	slli	a4,s1,0x20
    80003ade:	01e75593          	srli	a1,a4,0x1e
    80003ae2:	00b784b3          	add	s1,a5,a1
    80003ae6:	0004a903          	lw	s2,0(s1)
    80003aea:	02090063          	beqz	s2,80003b0a <bmap+0xac>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003aee:	8552                	mv	a0,s4
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	cac080e7          	jalr	-852(ra) # 8000379c <brelse>
    return addr;
    80003af8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003afa:	854a                	mv	a0,s2
    80003afc:	70a2                	ld	ra,40(sp)
    80003afe:	7402                	ld	s0,32(sp)
    80003b00:	64e2                	ld	s1,24(sp)
    80003b02:	6942                	ld	s2,16(sp)
    80003b04:	69a2                	ld	s3,8(sp)
    80003b06:	6145                	addi	sp,sp,48
    80003b08:	8082                	ret
      addr = balloc(ip->dev);
    80003b0a:	0009a503          	lw	a0,0(s3)
    80003b0e:	00000097          	auipc	ra,0x0
    80003b12:	e1a080e7          	jalr	-486(ra) # 80003928 <balloc>
    80003b16:	892a                	mv	s2,a0
      if(addr){
    80003b18:	d979                	beqz	a0,80003aee <bmap+0x90>
        a[bn] = addr;
    80003b1a:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003b1c:	8552                	mv	a0,s4
    80003b1e:	00001097          	auipc	ra,0x1
    80003b22:	f24080e7          	jalr	-220(ra) # 80004a42 <log_write>
    80003b26:	b7e1                	j	80003aee <bmap+0x90>
    80003b28:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003b2a:	00005517          	auipc	a0,0x5
    80003b2e:	92650513          	addi	a0,a0,-1754 # 80008450 <etext+0x450>
    80003b32:	ffffd097          	auipc	ra,0xffffd
    80003b36:	a2e080e7          	jalr	-1490(ra) # 80000560 <panic>

0000000080003b3a <iget>:
{
    80003b3a:	7179                	addi	sp,sp,-48
    80003b3c:	f406                	sd	ra,40(sp)
    80003b3e:	f022                	sd	s0,32(sp)
    80003b40:	ec26                	sd	s1,24(sp)
    80003b42:	e84a                	sd	s2,16(sp)
    80003b44:	e44e                	sd	s3,8(sp)
    80003b46:	e052                	sd	s4,0(sp)
    80003b48:	1800                	addi	s0,sp,48
    80003b4a:	89aa                	mv	s3,a0
    80003b4c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b4e:	0001f517          	auipc	a0,0x1f
    80003b52:	93a50513          	addi	a0,a0,-1734 # 80022488 <itable>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	0e8080e7          	jalr	232(ra) # 80000c3e <acquire>
  empty = 0;
    80003b5e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b60:	0001f497          	auipc	s1,0x1f
    80003b64:	94048493          	addi	s1,s1,-1728 # 800224a0 <itable+0x18>
    80003b68:	00020697          	auipc	a3,0x20
    80003b6c:	3c868693          	addi	a3,a3,968 # 80023f30 <log>
    80003b70:	a039                	j	80003b7e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b72:	02090b63          	beqz	s2,80003ba8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b76:	08848493          	addi	s1,s1,136
    80003b7a:	02d48a63          	beq	s1,a3,80003bae <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b7e:	449c                	lw	a5,8(s1)
    80003b80:	fef059e3          	blez	a5,80003b72 <iget+0x38>
    80003b84:	4098                	lw	a4,0(s1)
    80003b86:	ff3716e3          	bne	a4,s3,80003b72 <iget+0x38>
    80003b8a:	40d8                	lw	a4,4(s1)
    80003b8c:	ff4713e3          	bne	a4,s4,80003b72 <iget+0x38>
      ip->ref++;
    80003b90:	2785                	addiw	a5,a5,1
    80003b92:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003b94:	0001f517          	auipc	a0,0x1f
    80003b98:	8f450513          	addi	a0,a0,-1804 # 80022488 <itable>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	152080e7          	jalr	338(ra) # 80000cee <release>
      return ip;
    80003ba4:	8926                	mv	s2,s1
    80003ba6:	a03d                	j	80003bd4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ba8:	f7f9                	bnez	a5,80003b76 <iget+0x3c>
      empty = ip;
    80003baa:	8926                	mv	s2,s1
    80003bac:	b7e9                	j	80003b76 <iget+0x3c>
  if(empty == 0)
    80003bae:	02090c63          	beqz	s2,80003be6 <iget+0xac>
  ip->dev = dev;
    80003bb2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bb6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bba:	4785                	li	a5,1
    80003bbc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bc0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003bc4:	0001f517          	auipc	a0,0x1f
    80003bc8:	8c450513          	addi	a0,a0,-1852 # 80022488 <itable>
    80003bcc:	ffffd097          	auipc	ra,0xffffd
    80003bd0:	122080e7          	jalr	290(ra) # 80000cee <release>
}
    80003bd4:	854a                	mv	a0,s2
    80003bd6:	70a2                	ld	ra,40(sp)
    80003bd8:	7402                	ld	s0,32(sp)
    80003bda:	64e2                	ld	s1,24(sp)
    80003bdc:	6942                	ld	s2,16(sp)
    80003bde:	69a2                	ld	s3,8(sp)
    80003be0:	6a02                	ld	s4,0(sp)
    80003be2:	6145                	addi	sp,sp,48
    80003be4:	8082                	ret
    panic("iget: no inodes");
    80003be6:	00005517          	auipc	a0,0x5
    80003bea:	88250513          	addi	a0,a0,-1918 # 80008468 <etext+0x468>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	972080e7          	jalr	-1678(ra) # 80000560 <panic>

0000000080003bf6 <fsinit>:
fsinit(int dev) {
    80003bf6:	7179                	addi	sp,sp,-48
    80003bf8:	f406                	sd	ra,40(sp)
    80003bfa:	f022                	sd	s0,32(sp)
    80003bfc:	ec26                	sd	s1,24(sp)
    80003bfe:	e84a                	sd	s2,16(sp)
    80003c00:	e44e                	sd	s3,8(sp)
    80003c02:	1800                	addi	s0,sp,48
    80003c04:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c06:	4585                	li	a1,1
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	a64080e7          	jalr	-1436(ra) # 8000366c <bread>
    80003c10:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c12:	0001f997          	auipc	s3,0x1f
    80003c16:	85698993          	addi	s3,s3,-1962 # 80022468 <sb>
    80003c1a:	02000613          	li	a2,32
    80003c1e:	05850593          	addi	a1,a0,88
    80003c22:	854e                	mv	a0,s3
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	176080e7          	jalr	374(ra) # 80000d9a <memmove>
  brelse(bp);
    80003c2c:	8526                	mv	a0,s1
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	b6e080e7          	jalr	-1170(ra) # 8000379c <brelse>
  if(sb.magic != FSMAGIC)
    80003c36:	0009a703          	lw	a4,0(s3)
    80003c3a:	102037b7          	lui	a5,0x10203
    80003c3e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c42:	02f71263          	bne	a4,a5,80003c66 <fsinit+0x70>
  initlog(dev, &sb);
    80003c46:	0001f597          	auipc	a1,0x1f
    80003c4a:	82258593          	addi	a1,a1,-2014 # 80022468 <sb>
    80003c4e:	854a                	mv	a0,s2
    80003c50:	00001097          	auipc	ra,0x1
    80003c54:	b7c080e7          	jalr	-1156(ra) # 800047cc <initlog>
}
    80003c58:	70a2                	ld	ra,40(sp)
    80003c5a:	7402                	ld	s0,32(sp)
    80003c5c:	64e2                	ld	s1,24(sp)
    80003c5e:	6942                	ld	s2,16(sp)
    80003c60:	69a2                	ld	s3,8(sp)
    80003c62:	6145                	addi	sp,sp,48
    80003c64:	8082                	ret
    panic("invalid file system");
    80003c66:	00005517          	auipc	a0,0x5
    80003c6a:	81250513          	addi	a0,a0,-2030 # 80008478 <etext+0x478>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	8f2080e7          	jalr	-1806(ra) # 80000560 <panic>

0000000080003c76 <iinit>:
{
    80003c76:	7179                	addi	sp,sp,-48
    80003c78:	f406                	sd	ra,40(sp)
    80003c7a:	f022                	sd	s0,32(sp)
    80003c7c:	ec26                	sd	s1,24(sp)
    80003c7e:	e84a                	sd	s2,16(sp)
    80003c80:	e44e                	sd	s3,8(sp)
    80003c82:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c84:	00005597          	auipc	a1,0x5
    80003c88:	80c58593          	addi	a1,a1,-2036 # 80008490 <etext+0x490>
    80003c8c:	0001e517          	auipc	a0,0x1e
    80003c90:	7fc50513          	addi	a0,a0,2044 # 80022488 <itable>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	f16080e7          	jalr	-234(ra) # 80000baa <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c9c:	0001f497          	auipc	s1,0x1f
    80003ca0:	81448493          	addi	s1,s1,-2028 # 800224b0 <itable+0x28>
    80003ca4:	00020997          	auipc	s3,0x20
    80003ca8:	29c98993          	addi	s3,s3,668 # 80023f40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cac:	00004917          	auipc	s2,0x4
    80003cb0:	7ec90913          	addi	s2,s2,2028 # 80008498 <etext+0x498>
    80003cb4:	85ca                	mv	a1,s2
    80003cb6:	8526                	mv	a0,s1
    80003cb8:	00001097          	auipc	ra,0x1
    80003cbc:	e6e080e7          	jalr	-402(ra) # 80004b26 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003cc0:	08848493          	addi	s1,s1,136
    80003cc4:	ff3498e3          	bne	s1,s3,80003cb4 <iinit+0x3e>
}
    80003cc8:	70a2                	ld	ra,40(sp)
    80003cca:	7402                	ld	s0,32(sp)
    80003ccc:	64e2                	ld	s1,24(sp)
    80003cce:	6942                	ld	s2,16(sp)
    80003cd0:	69a2                	ld	s3,8(sp)
    80003cd2:	6145                	addi	sp,sp,48
    80003cd4:	8082                	ret

0000000080003cd6 <ialloc>:
{
    80003cd6:	7139                	addi	sp,sp,-64
    80003cd8:	fc06                	sd	ra,56(sp)
    80003cda:	f822                	sd	s0,48(sp)
    80003cdc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cde:	0001e717          	auipc	a4,0x1e
    80003ce2:	79672703          	lw	a4,1942(a4) # 80022474 <sb+0xc>
    80003ce6:	4785                	li	a5,1
    80003ce8:	06e7f463          	bgeu	a5,a4,80003d50 <ialloc+0x7a>
    80003cec:	f426                	sd	s1,40(sp)
    80003cee:	f04a                	sd	s2,32(sp)
    80003cf0:	ec4e                	sd	s3,24(sp)
    80003cf2:	e852                	sd	s4,16(sp)
    80003cf4:	e456                	sd	s5,8(sp)
    80003cf6:	e05a                	sd	s6,0(sp)
    80003cf8:	8aaa                	mv	s5,a0
    80003cfa:	8b2e                	mv	s6,a1
    80003cfc:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003cfe:	0001ea17          	auipc	s4,0x1e
    80003d02:	76aa0a13          	addi	s4,s4,1898 # 80022468 <sb>
    80003d06:	00495593          	srli	a1,s2,0x4
    80003d0a:	018a2783          	lw	a5,24(s4)
    80003d0e:	9dbd                	addw	a1,a1,a5
    80003d10:	8556                	mv	a0,s5
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	95a080e7          	jalr	-1702(ra) # 8000366c <bread>
    80003d1a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d1c:	05850993          	addi	s3,a0,88
    80003d20:	00f97793          	andi	a5,s2,15
    80003d24:	079a                	slli	a5,a5,0x6
    80003d26:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d28:	00099783          	lh	a5,0(s3)
    80003d2c:	cf9d                	beqz	a5,80003d6a <ialloc+0x94>
    brelse(bp);
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	a6e080e7          	jalr	-1426(ra) # 8000379c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d36:	0905                	addi	s2,s2,1
    80003d38:	00ca2703          	lw	a4,12(s4)
    80003d3c:	0009079b          	sext.w	a5,s2
    80003d40:	fce7e3e3          	bltu	a5,a4,80003d06 <ialloc+0x30>
    80003d44:	74a2                	ld	s1,40(sp)
    80003d46:	7902                	ld	s2,32(sp)
    80003d48:	69e2                	ld	s3,24(sp)
    80003d4a:	6a42                	ld	s4,16(sp)
    80003d4c:	6aa2                	ld	s5,8(sp)
    80003d4e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003d50:	00004517          	auipc	a0,0x4
    80003d54:	75050513          	addi	a0,a0,1872 # 800084a0 <etext+0x4a0>
    80003d58:	ffffd097          	auipc	ra,0xffffd
    80003d5c:	852080e7          	jalr	-1966(ra) # 800005aa <printf>
  return 0;
    80003d60:	4501                	li	a0,0
}
    80003d62:	70e2                	ld	ra,56(sp)
    80003d64:	7442                	ld	s0,48(sp)
    80003d66:	6121                	addi	sp,sp,64
    80003d68:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003d6a:	04000613          	li	a2,64
    80003d6e:	4581                	li	a1,0
    80003d70:	854e                	mv	a0,s3
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	fc4080e7          	jalr	-60(ra) # 80000d36 <memset>
      dip->type = type;
    80003d7a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d7e:	8526                	mv	a0,s1
    80003d80:	00001097          	auipc	ra,0x1
    80003d84:	cc2080e7          	jalr	-830(ra) # 80004a42 <log_write>
      brelse(bp);
    80003d88:	8526                	mv	a0,s1
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	a12080e7          	jalr	-1518(ra) # 8000379c <brelse>
      return iget(dev, inum);
    80003d92:	0009059b          	sext.w	a1,s2
    80003d96:	8556                	mv	a0,s5
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	da2080e7          	jalr	-606(ra) # 80003b3a <iget>
    80003da0:	74a2                	ld	s1,40(sp)
    80003da2:	7902                	ld	s2,32(sp)
    80003da4:	69e2                	ld	s3,24(sp)
    80003da6:	6a42                	ld	s4,16(sp)
    80003da8:	6aa2                	ld	s5,8(sp)
    80003daa:	6b02                	ld	s6,0(sp)
    80003dac:	bf5d                	j	80003d62 <ialloc+0x8c>

0000000080003dae <iupdate>:
{
    80003dae:	1101                	addi	sp,sp,-32
    80003db0:	ec06                	sd	ra,24(sp)
    80003db2:	e822                	sd	s0,16(sp)
    80003db4:	e426                	sd	s1,8(sp)
    80003db6:	e04a                	sd	s2,0(sp)
    80003db8:	1000                	addi	s0,sp,32
    80003dba:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dbc:	415c                	lw	a5,4(a0)
    80003dbe:	0047d79b          	srliw	a5,a5,0x4
    80003dc2:	0001e597          	auipc	a1,0x1e
    80003dc6:	6be5a583          	lw	a1,1726(a1) # 80022480 <sb+0x18>
    80003dca:	9dbd                	addw	a1,a1,a5
    80003dcc:	4108                	lw	a0,0(a0)
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	89e080e7          	jalr	-1890(ra) # 8000366c <bread>
    80003dd6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dd8:	05850793          	addi	a5,a0,88
    80003ddc:	40d8                	lw	a4,4(s1)
    80003dde:	8b3d                	andi	a4,a4,15
    80003de0:	071a                	slli	a4,a4,0x6
    80003de2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003de4:	04449703          	lh	a4,68(s1)
    80003de8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003dec:	04649703          	lh	a4,70(s1)
    80003df0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003df4:	04849703          	lh	a4,72(s1)
    80003df8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003dfc:	04a49703          	lh	a4,74(s1)
    80003e00:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003e04:	44f8                	lw	a4,76(s1)
    80003e06:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e08:	03400613          	li	a2,52
    80003e0c:	05048593          	addi	a1,s1,80
    80003e10:	00c78513          	addi	a0,a5,12
    80003e14:	ffffd097          	auipc	ra,0xffffd
    80003e18:	f86080e7          	jalr	-122(ra) # 80000d9a <memmove>
  log_write(bp);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00001097          	auipc	ra,0x1
    80003e22:	c24080e7          	jalr	-988(ra) # 80004a42 <log_write>
  brelse(bp);
    80003e26:	854a                	mv	a0,s2
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	974080e7          	jalr	-1676(ra) # 8000379c <brelse>
}
    80003e30:	60e2                	ld	ra,24(sp)
    80003e32:	6442                	ld	s0,16(sp)
    80003e34:	64a2                	ld	s1,8(sp)
    80003e36:	6902                	ld	s2,0(sp)
    80003e38:	6105                	addi	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <idup>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	addi	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e48:	0001e517          	auipc	a0,0x1e
    80003e4c:	64050513          	addi	a0,a0,1600 # 80022488 <itable>
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	dee080e7          	jalr	-530(ra) # 80000c3e <acquire>
  ip->ref++;
    80003e58:	449c                	lw	a5,8(s1)
    80003e5a:	2785                	addiw	a5,a5,1
    80003e5c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e5e:	0001e517          	auipc	a0,0x1e
    80003e62:	62a50513          	addi	a0,a0,1578 # 80022488 <itable>
    80003e66:	ffffd097          	auipc	ra,0xffffd
    80003e6a:	e88080e7          	jalr	-376(ra) # 80000cee <release>
}
    80003e6e:	8526                	mv	a0,s1
    80003e70:	60e2                	ld	ra,24(sp)
    80003e72:	6442                	ld	s0,16(sp)
    80003e74:	64a2                	ld	s1,8(sp)
    80003e76:	6105                	addi	sp,sp,32
    80003e78:	8082                	ret

0000000080003e7a <ilock>:
{
    80003e7a:	1101                	addi	sp,sp,-32
    80003e7c:	ec06                	sd	ra,24(sp)
    80003e7e:	e822                	sd	s0,16(sp)
    80003e80:	e426                	sd	s1,8(sp)
    80003e82:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e84:	c10d                	beqz	a0,80003ea6 <ilock+0x2c>
    80003e86:	84aa                	mv	s1,a0
    80003e88:	451c                	lw	a5,8(a0)
    80003e8a:	00f05e63          	blez	a5,80003ea6 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003e8e:	0541                	addi	a0,a0,16
    80003e90:	00001097          	auipc	ra,0x1
    80003e94:	cd0080e7          	jalr	-816(ra) # 80004b60 <acquiresleep>
  if(ip->valid == 0){
    80003e98:	40bc                	lw	a5,64(s1)
    80003e9a:	cf99                	beqz	a5,80003eb8 <ilock+0x3e>
}
    80003e9c:	60e2                	ld	ra,24(sp)
    80003e9e:	6442                	ld	s0,16(sp)
    80003ea0:	64a2                	ld	s1,8(sp)
    80003ea2:	6105                	addi	sp,sp,32
    80003ea4:	8082                	ret
    80003ea6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003ea8:	00004517          	auipc	a0,0x4
    80003eac:	61050513          	addi	a0,a0,1552 # 800084b8 <etext+0x4b8>
    80003eb0:	ffffc097          	auipc	ra,0xffffc
    80003eb4:	6b0080e7          	jalr	1712(ra) # 80000560 <panic>
    80003eb8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003eba:	40dc                	lw	a5,4(s1)
    80003ebc:	0047d79b          	srliw	a5,a5,0x4
    80003ec0:	0001e597          	auipc	a1,0x1e
    80003ec4:	5c05a583          	lw	a1,1472(a1) # 80022480 <sb+0x18>
    80003ec8:	9dbd                	addw	a1,a1,a5
    80003eca:	4088                	lw	a0,0(s1)
    80003ecc:	fffff097          	auipc	ra,0xfffff
    80003ed0:	7a0080e7          	jalr	1952(ra) # 8000366c <bread>
    80003ed4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ed6:	05850593          	addi	a1,a0,88
    80003eda:	40dc                	lw	a5,4(s1)
    80003edc:	8bbd                	andi	a5,a5,15
    80003ede:	079a                	slli	a5,a5,0x6
    80003ee0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ee2:	00059783          	lh	a5,0(a1)
    80003ee6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003eea:	00259783          	lh	a5,2(a1)
    80003eee:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ef2:	00459783          	lh	a5,4(a1)
    80003ef6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003efa:	00659783          	lh	a5,6(a1)
    80003efe:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f02:	459c                	lw	a5,8(a1)
    80003f04:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f06:	03400613          	li	a2,52
    80003f0a:	05b1                	addi	a1,a1,12
    80003f0c:	05048513          	addi	a0,s1,80
    80003f10:	ffffd097          	auipc	ra,0xffffd
    80003f14:	e8a080e7          	jalr	-374(ra) # 80000d9a <memmove>
    brelse(bp);
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	882080e7          	jalr	-1918(ra) # 8000379c <brelse>
    ip->valid = 1;
    80003f22:	4785                	li	a5,1
    80003f24:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f26:	04449783          	lh	a5,68(s1)
    80003f2a:	c399                	beqz	a5,80003f30 <ilock+0xb6>
    80003f2c:	6902                	ld	s2,0(sp)
    80003f2e:	b7bd                	j	80003e9c <ilock+0x22>
      panic("ilock: no type");
    80003f30:	00004517          	auipc	a0,0x4
    80003f34:	59050513          	addi	a0,a0,1424 # 800084c0 <etext+0x4c0>
    80003f38:	ffffc097          	auipc	ra,0xffffc
    80003f3c:	628080e7          	jalr	1576(ra) # 80000560 <panic>

0000000080003f40 <iunlock>:
{
    80003f40:	1101                	addi	sp,sp,-32
    80003f42:	ec06                	sd	ra,24(sp)
    80003f44:	e822                	sd	s0,16(sp)
    80003f46:	e426                	sd	s1,8(sp)
    80003f48:	e04a                	sd	s2,0(sp)
    80003f4a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f4c:	c905                	beqz	a0,80003f7c <iunlock+0x3c>
    80003f4e:	84aa                	mv	s1,a0
    80003f50:	01050913          	addi	s2,a0,16
    80003f54:	854a                	mv	a0,s2
    80003f56:	00001097          	auipc	ra,0x1
    80003f5a:	ca4080e7          	jalr	-860(ra) # 80004bfa <holdingsleep>
    80003f5e:	cd19                	beqz	a0,80003f7c <iunlock+0x3c>
    80003f60:	449c                	lw	a5,8(s1)
    80003f62:	00f05d63          	blez	a5,80003f7c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f66:	854a                	mv	a0,s2
    80003f68:	00001097          	auipc	ra,0x1
    80003f6c:	c4e080e7          	jalr	-946(ra) # 80004bb6 <releasesleep>
}
    80003f70:	60e2                	ld	ra,24(sp)
    80003f72:	6442                	ld	s0,16(sp)
    80003f74:	64a2                	ld	s1,8(sp)
    80003f76:	6902                	ld	s2,0(sp)
    80003f78:	6105                	addi	sp,sp,32
    80003f7a:	8082                	ret
    panic("iunlock");
    80003f7c:	00004517          	auipc	a0,0x4
    80003f80:	55450513          	addi	a0,a0,1364 # 800084d0 <etext+0x4d0>
    80003f84:	ffffc097          	auipc	ra,0xffffc
    80003f88:	5dc080e7          	jalr	1500(ra) # 80000560 <panic>

0000000080003f8c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f8c:	7179                	addi	sp,sp,-48
    80003f8e:	f406                	sd	ra,40(sp)
    80003f90:	f022                	sd	s0,32(sp)
    80003f92:	ec26                	sd	s1,24(sp)
    80003f94:	e84a                	sd	s2,16(sp)
    80003f96:	e44e                	sd	s3,8(sp)
    80003f98:	1800                	addi	s0,sp,48
    80003f9a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f9c:	05050493          	addi	s1,a0,80
    80003fa0:	08050913          	addi	s2,a0,128
    80003fa4:	a021                	j	80003fac <itrunc+0x20>
    80003fa6:	0491                	addi	s1,s1,4
    80003fa8:	01248d63          	beq	s1,s2,80003fc2 <itrunc+0x36>
    if(ip->addrs[i]){
    80003fac:	408c                	lw	a1,0(s1)
    80003fae:	dde5                	beqz	a1,80003fa6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003fb0:	0009a503          	lw	a0,0(s3)
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	8f8080e7          	jalr	-1800(ra) # 800038ac <bfree>
      ip->addrs[i] = 0;
    80003fbc:	0004a023          	sw	zero,0(s1)
    80003fc0:	b7dd                	j	80003fa6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fc2:	0809a583          	lw	a1,128(s3)
    80003fc6:	ed99                	bnez	a1,80003fe4 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fc8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003fcc:	854e                	mv	a0,s3
    80003fce:	00000097          	auipc	ra,0x0
    80003fd2:	de0080e7          	jalr	-544(ra) # 80003dae <iupdate>
}
    80003fd6:	70a2                	ld	ra,40(sp)
    80003fd8:	7402                	ld	s0,32(sp)
    80003fda:	64e2                	ld	s1,24(sp)
    80003fdc:	6942                	ld	s2,16(sp)
    80003fde:	69a2                	ld	s3,8(sp)
    80003fe0:	6145                	addi	sp,sp,48
    80003fe2:	8082                	ret
    80003fe4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fe6:	0009a503          	lw	a0,0(s3)
    80003fea:	fffff097          	auipc	ra,0xfffff
    80003fee:	682080e7          	jalr	1666(ra) # 8000366c <bread>
    80003ff2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ff4:	05850493          	addi	s1,a0,88
    80003ff8:	45850913          	addi	s2,a0,1112
    80003ffc:	a021                	j	80004004 <itrunc+0x78>
    80003ffe:	0491                	addi	s1,s1,4
    80004000:	01248b63          	beq	s1,s2,80004016 <itrunc+0x8a>
      if(a[j])
    80004004:	408c                	lw	a1,0(s1)
    80004006:	dde5                	beqz	a1,80003ffe <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80004008:	0009a503          	lw	a0,0(s3)
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	8a0080e7          	jalr	-1888(ra) # 800038ac <bfree>
    80004014:	b7ed                	j	80003ffe <itrunc+0x72>
    brelse(bp);
    80004016:	8552                	mv	a0,s4
    80004018:	fffff097          	auipc	ra,0xfffff
    8000401c:	784080e7          	jalr	1924(ra) # 8000379c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004020:	0809a583          	lw	a1,128(s3)
    80004024:	0009a503          	lw	a0,0(s3)
    80004028:	00000097          	auipc	ra,0x0
    8000402c:	884080e7          	jalr	-1916(ra) # 800038ac <bfree>
    ip->addrs[NDIRECT] = 0;
    80004030:	0809a023          	sw	zero,128(s3)
    80004034:	6a02                	ld	s4,0(sp)
    80004036:	bf49                	j	80003fc8 <itrunc+0x3c>

0000000080004038 <iput>:
{
    80004038:	1101                	addi	sp,sp,-32
    8000403a:	ec06                	sd	ra,24(sp)
    8000403c:	e822                	sd	s0,16(sp)
    8000403e:	e426                	sd	s1,8(sp)
    80004040:	1000                	addi	s0,sp,32
    80004042:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004044:	0001e517          	auipc	a0,0x1e
    80004048:	44450513          	addi	a0,a0,1092 # 80022488 <itable>
    8000404c:	ffffd097          	auipc	ra,0xffffd
    80004050:	bf2080e7          	jalr	-1038(ra) # 80000c3e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004054:	4498                	lw	a4,8(s1)
    80004056:	4785                	li	a5,1
    80004058:	02f70263          	beq	a4,a5,8000407c <iput+0x44>
  ip->ref--;
    8000405c:	449c                	lw	a5,8(s1)
    8000405e:	37fd                	addiw	a5,a5,-1
    80004060:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004062:	0001e517          	auipc	a0,0x1e
    80004066:	42650513          	addi	a0,a0,1062 # 80022488 <itable>
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	c84080e7          	jalr	-892(ra) # 80000cee <release>
}
    80004072:	60e2                	ld	ra,24(sp)
    80004074:	6442                	ld	s0,16(sp)
    80004076:	64a2                	ld	s1,8(sp)
    80004078:	6105                	addi	sp,sp,32
    8000407a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000407c:	40bc                	lw	a5,64(s1)
    8000407e:	dff9                	beqz	a5,8000405c <iput+0x24>
    80004080:	04a49783          	lh	a5,74(s1)
    80004084:	ffe1                	bnez	a5,8000405c <iput+0x24>
    80004086:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80004088:	01048913          	addi	s2,s1,16
    8000408c:	854a                	mv	a0,s2
    8000408e:	00001097          	auipc	ra,0x1
    80004092:	ad2080e7          	jalr	-1326(ra) # 80004b60 <acquiresleep>
    release(&itable.lock);
    80004096:	0001e517          	auipc	a0,0x1e
    8000409a:	3f250513          	addi	a0,a0,1010 # 80022488 <itable>
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	c50080e7          	jalr	-944(ra) # 80000cee <release>
    itrunc(ip);
    800040a6:	8526                	mv	a0,s1
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	ee4080e7          	jalr	-284(ra) # 80003f8c <itrunc>
    ip->type = 0;
    800040b0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040b4:	8526                	mv	a0,s1
    800040b6:	00000097          	auipc	ra,0x0
    800040ba:	cf8080e7          	jalr	-776(ra) # 80003dae <iupdate>
    ip->valid = 0;
    800040be:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040c2:	854a                	mv	a0,s2
    800040c4:	00001097          	auipc	ra,0x1
    800040c8:	af2080e7          	jalr	-1294(ra) # 80004bb6 <releasesleep>
    acquire(&itable.lock);
    800040cc:	0001e517          	auipc	a0,0x1e
    800040d0:	3bc50513          	addi	a0,a0,956 # 80022488 <itable>
    800040d4:	ffffd097          	auipc	ra,0xffffd
    800040d8:	b6a080e7          	jalr	-1174(ra) # 80000c3e <acquire>
    800040dc:	6902                	ld	s2,0(sp)
    800040de:	bfbd                	j	8000405c <iput+0x24>

00000000800040e0 <iunlockput>:
{
    800040e0:	1101                	addi	sp,sp,-32
    800040e2:	ec06                	sd	ra,24(sp)
    800040e4:	e822                	sd	s0,16(sp)
    800040e6:	e426                	sd	s1,8(sp)
    800040e8:	1000                	addi	s0,sp,32
    800040ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	e54080e7          	jalr	-428(ra) # 80003f40 <iunlock>
  iput(ip);
    800040f4:	8526                	mv	a0,s1
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	f42080e7          	jalr	-190(ra) # 80004038 <iput>
}
    800040fe:	60e2                	ld	ra,24(sp)
    80004100:	6442                	ld	s0,16(sp)
    80004102:	64a2                	ld	s1,8(sp)
    80004104:	6105                	addi	sp,sp,32
    80004106:	8082                	ret

0000000080004108 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004108:	1141                	addi	sp,sp,-16
    8000410a:	e406                	sd	ra,8(sp)
    8000410c:	e022                	sd	s0,0(sp)
    8000410e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004110:	411c                	lw	a5,0(a0)
    80004112:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004114:	415c                	lw	a5,4(a0)
    80004116:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004118:	04451783          	lh	a5,68(a0)
    8000411c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004120:	04a51783          	lh	a5,74(a0)
    80004124:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004128:	04c56783          	lwu	a5,76(a0)
    8000412c:	e99c                	sd	a5,16(a1)
}
    8000412e:	60a2                	ld	ra,8(sp)
    80004130:	6402                	ld	s0,0(sp)
    80004132:	0141                	addi	sp,sp,16
    80004134:	8082                	ret

0000000080004136 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004136:	457c                	lw	a5,76(a0)
    80004138:	10d7e063          	bltu	a5,a3,80004238 <readi+0x102>
{
    8000413c:	7159                	addi	sp,sp,-112
    8000413e:	f486                	sd	ra,104(sp)
    80004140:	f0a2                	sd	s0,96(sp)
    80004142:	eca6                	sd	s1,88(sp)
    80004144:	e0d2                	sd	s4,64(sp)
    80004146:	fc56                	sd	s5,56(sp)
    80004148:	f85a                	sd	s6,48(sp)
    8000414a:	f45e                	sd	s7,40(sp)
    8000414c:	1880                	addi	s0,sp,112
    8000414e:	8b2a                	mv	s6,a0
    80004150:	8bae                	mv	s7,a1
    80004152:	8a32                	mv	s4,a2
    80004154:	84b6                	mv	s1,a3
    80004156:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004158:	9f35                	addw	a4,a4,a3
    return 0;
    8000415a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000415c:	0cd76563          	bltu	a4,a3,80004226 <readi+0xf0>
    80004160:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004162:	00e7f463          	bgeu	a5,a4,8000416a <readi+0x34>
    n = ip->size - off;
    80004166:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000416a:	0a0a8563          	beqz	s5,80004214 <readi+0xde>
    8000416e:	e8ca                	sd	s2,80(sp)
    80004170:	f062                	sd	s8,32(sp)
    80004172:	ec66                	sd	s9,24(sp)
    80004174:	e86a                	sd	s10,16(sp)
    80004176:	e46e                	sd	s11,8(sp)
    80004178:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000417a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000417e:	5c7d                	li	s8,-1
    80004180:	a82d                	j	800041ba <readi+0x84>
    80004182:	020d1d93          	slli	s11,s10,0x20
    80004186:	020ddd93          	srli	s11,s11,0x20
    8000418a:	05890613          	addi	a2,s2,88
    8000418e:	86ee                	mv	a3,s11
    80004190:	963e                	add	a2,a2,a5
    80004192:	85d2                	mv	a1,s4
    80004194:	855e                	mv	a0,s7
    80004196:	ffffe097          	auipc	ra,0xffffe
    8000419a:	71c080e7          	jalr	1820(ra) # 800028b2 <either_copyout>
    8000419e:	05850963          	beq	a0,s8,800041f0 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041a2:	854a                	mv	a0,s2
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	5f8080e7          	jalr	1528(ra) # 8000379c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041ac:	013d09bb          	addw	s3,s10,s3
    800041b0:	009d04bb          	addw	s1,s10,s1
    800041b4:	9a6e                	add	s4,s4,s11
    800041b6:	0559f963          	bgeu	s3,s5,80004208 <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    800041ba:	00a4d59b          	srliw	a1,s1,0xa
    800041be:	855a                	mv	a0,s6
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	89e080e7          	jalr	-1890(ra) # 80003a5e <bmap>
    800041c8:	85aa                	mv	a1,a0
    if(addr == 0)
    800041ca:	c539                	beqz	a0,80004218 <readi+0xe2>
    bp = bread(ip->dev, addr);
    800041cc:	000b2503          	lw	a0,0(s6)
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	49c080e7          	jalr	1180(ra) # 8000366c <bread>
    800041d8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041da:	3ff4f793          	andi	a5,s1,1023
    800041de:	40fc873b          	subw	a4,s9,a5
    800041e2:	413a86bb          	subw	a3,s5,s3
    800041e6:	8d3a                	mv	s10,a4
    800041e8:	f8e6fde3          	bgeu	a3,a4,80004182 <readi+0x4c>
    800041ec:	8d36                	mv	s10,a3
    800041ee:	bf51                	j	80004182 <readi+0x4c>
      brelse(bp);
    800041f0:	854a                	mv	a0,s2
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	5aa080e7          	jalr	1450(ra) # 8000379c <brelse>
      tot = -1;
    800041fa:	59fd                	li	s3,-1
      break;
    800041fc:	6946                	ld	s2,80(sp)
    800041fe:	7c02                	ld	s8,32(sp)
    80004200:	6ce2                	ld	s9,24(sp)
    80004202:	6d42                	ld	s10,16(sp)
    80004204:	6da2                	ld	s11,8(sp)
    80004206:	a831                	j	80004222 <readi+0xec>
    80004208:	6946                	ld	s2,80(sp)
    8000420a:	7c02                	ld	s8,32(sp)
    8000420c:	6ce2                	ld	s9,24(sp)
    8000420e:	6d42                	ld	s10,16(sp)
    80004210:	6da2                	ld	s11,8(sp)
    80004212:	a801                	j	80004222 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004214:	89d6                	mv	s3,s5
    80004216:	a031                	j	80004222 <readi+0xec>
    80004218:	6946                	ld	s2,80(sp)
    8000421a:	7c02                	ld	s8,32(sp)
    8000421c:	6ce2                	ld	s9,24(sp)
    8000421e:	6d42                	ld	s10,16(sp)
    80004220:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004222:	854e                	mv	a0,s3
    80004224:	69a6                	ld	s3,72(sp)
}
    80004226:	70a6                	ld	ra,104(sp)
    80004228:	7406                	ld	s0,96(sp)
    8000422a:	64e6                	ld	s1,88(sp)
    8000422c:	6a06                	ld	s4,64(sp)
    8000422e:	7ae2                	ld	s5,56(sp)
    80004230:	7b42                	ld	s6,48(sp)
    80004232:	7ba2                	ld	s7,40(sp)
    80004234:	6165                	addi	sp,sp,112
    80004236:	8082                	ret
    return 0;
    80004238:	4501                	li	a0,0
}
    8000423a:	8082                	ret

000000008000423c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000423c:	457c                	lw	a5,76(a0)
    8000423e:	10d7e963          	bltu	a5,a3,80004350 <writei+0x114>
{
    80004242:	7159                	addi	sp,sp,-112
    80004244:	f486                	sd	ra,104(sp)
    80004246:	f0a2                	sd	s0,96(sp)
    80004248:	e8ca                	sd	s2,80(sp)
    8000424a:	e0d2                	sd	s4,64(sp)
    8000424c:	fc56                	sd	s5,56(sp)
    8000424e:	f85a                	sd	s6,48(sp)
    80004250:	f45e                	sd	s7,40(sp)
    80004252:	1880                	addi	s0,sp,112
    80004254:	8aaa                	mv	s5,a0
    80004256:	8bae                	mv	s7,a1
    80004258:	8a32                	mv	s4,a2
    8000425a:	8936                	mv	s2,a3
    8000425c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000425e:	00e687bb          	addw	a5,a3,a4
    80004262:	0ed7e963          	bltu	a5,a3,80004354 <writei+0x118>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004266:	00043737          	lui	a4,0x43
    8000426a:	0ef76763          	bltu	a4,a5,80004358 <writei+0x11c>
    8000426e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004270:	0c0b0863          	beqz	s6,80004340 <writei+0x104>
    80004274:	eca6                	sd	s1,88(sp)
    80004276:	f062                	sd	s8,32(sp)
    80004278:	ec66                	sd	s9,24(sp)
    8000427a:	e86a                	sd	s10,16(sp)
    8000427c:	e46e                	sd	s11,8(sp)
    8000427e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004280:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004284:	5c7d                	li	s8,-1
    80004286:	a091                	j	800042ca <writei+0x8e>
    80004288:	020d1d93          	slli	s11,s10,0x20
    8000428c:	020ddd93          	srli	s11,s11,0x20
    80004290:	05848513          	addi	a0,s1,88
    80004294:	86ee                	mv	a3,s11
    80004296:	8652                	mv	a2,s4
    80004298:	85de                	mv	a1,s7
    8000429a:	953e                	add	a0,a0,a5
    8000429c:	ffffe097          	auipc	ra,0xffffe
    800042a0:	66c080e7          	jalr	1644(ra) # 80002908 <either_copyin>
    800042a4:	05850e63          	beq	a0,s8,80004300 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042a8:	8526                	mv	a0,s1
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	798080e7          	jalr	1944(ra) # 80004a42 <log_write>
    brelse(bp);
    800042b2:	8526                	mv	a0,s1
    800042b4:	fffff097          	auipc	ra,0xfffff
    800042b8:	4e8080e7          	jalr	1256(ra) # 8000379c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042bc:	013d09bb          	addw	s3,s10,s3
    800042c0:	012d093b          	addw	s2,s10,s2
    800042c4:	9a6e                	add	s4,s4,s11
    800042c6:	0569f263          	bgeu	s3,s6,8000430a <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800042ca:	00a9559b          	srliw	a1,s2,0xa
    800042ce:	8556                	mv	a0,s5
    800042d0:	fffff097          	auipc	ra,0xfffff
    800042d4:	78e080e7          	jalr	1934(ra) # 80003a5e <bmap>
    800042d8:	85aa                	mv	a1,a0
    if(addr == 0)
    800042da:	c905                	beqz	a0,8000430a <writei+0xce>
    bp = bread(ip->dev, addr);
    800042dc:	000aa503          	lw	a0,0(s5)
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	38c080e7          	jalr	908(ra) # 8000366c <bread>
    800042e8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042ea:	3ff97793          	andi	a5,s2,1023
    800042ee:	40fc873b          	subw	a4,s9,a5
    800042f2:	413b06bb          	subw	a3,s6,s3
    800042f6:	8d3a                	mv	s10,a4
    800042f8:	f8e6f8e3          	bgeu	a3,a4,80004288 <writei+0x4c>
    800042fc:	8d36                	mv	s10,a3
    800042fe:	b769                	j	80004288 <writei+0x4c>
      brelse(bp);
    80004300:	8526                	mv	a0,s1
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	49a080e7          	jalr	1178(ra) # 8000379c <brelse>
  }

  if(off > ip->size)
    8000430a:	04caa783          	lw	a5,76(s5)
    8000430e:	0327fb63          	bgeu	a5,s2,80004344 <writei+0x108>
    ip->size = off;
    80004312:	052aa623          	sw	s2,76(s5)
    80004316:	64e6                	ld	s1,88(sp)
    80004318:	7c02                	ld	s8,32(sp)
    8000431a:	6ce2                	ld	s9,24(sp)
    8000431c:	6d42                	ld	s10,16(sp)
    8000431e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004320:	8556                	mv	a0,s5
    80004322:	00000097          	auipc	ra,0x0
    80004326:	a8c080e7          	jalr	-1396(ra) # 80003dae <iupdate>

  return tot;
    8000432a:	854e                	mv	a0,s3
    8000432c:	69a6                	ld	s3,72(sp)
}
    8000432e:	70a6                	ld	ra,104(sp)
    80004330:	7406                	ld	s0,96(sp)
    80004332:	6946                	ld	s2,80(sp)
    80004334:	6a06                	ld	s4,64(sp)
    80004336:	7ae2                	ld	s5,56(sp)
    80004338:	7b42                	ld	s6,48(sp)
    8000433a:	7ba2                	ld	s7,40(sp)
    8000433c:	6165                	addi	sp,sp,112
    8000433e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004340:	89da                	mv	s3,s6
    80004342:	bff9                	j	80004320 <writei+0xe4>
    80004344:	64e6                	ld	s1,88(sp)
    80004346:	7c02                	ld	s8,32(sp)
    80004348:	6ce2                	ld	s9,24(sp)
    8000434a:	6d42                	ld	s10,16(sp)
    8000434c:	6da2                	ld	s11,8(sp)
    8000434e:	bfc9                	j	80004320 <writei+0xe4>
    return -1;
    80004350:	557d                	li	a0,-1
}
    80004352:	8082                	ret
    return -1;
    80004354:	557d                	li	a0,-1
    80004356:	bfe1                	j	8000432e <writei+0xf2>
    return -1;
    80004358:	557d                	li	a0,-1
    8000435a:	bfd1                	j	8000432e <writei+0xf2>

000000008000435c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000435c:	1141                	addi	sp,sp,-16
    8000435e:	e406                	sd	ra,8(sp)
    80004360:	e022                	sd	s0,0(sp)
    80004362:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004364:	4639                	li	a2,14
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	aac080e7          	jalr	-1364(ra) # 80000e12 <strncmp>
}
    8000436e:	60a2                	ld	ra,8(sp)
    80004370:	6402                	ld	s0,0(sp)
    80004372:	0141                	addi	sp,sp,16
    80004374:	8082                	ret

0000000080004376 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004376:	711d                	addi	sp,sp,-96
    80004378:	ec86                	sd	ra,88(sp)
    8000437a:	e8a2                	sd	s0,80(sp)
    8000437c:	e4a6                	sd	s1,72(sp)
    8000437e:	e0ca                	sd	s2,64(sp)
    80004380:	fc4e                	sd	s3,56(sp)
    80004382:	f852                	sd	s4,48(sp)
    80004384:	f456                	sd	s5,40(sp)
    80004386:	f05a                	sd	s6,32(sp)
    80004388:	ec5e                	sd	s7,24(sp)
    8000438a:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000438c:	04451703          	lh	a4,68(a0)
    80004390:	4785                	li	a5,1
    80004392:	00f71f63          	bne	a4,a5,800043b0 <dirlookup+0x3a>
    80004396:	892a                	mv	s2,a0
    80004398:	8aae                	mv	s5,a1
    8000439a:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000439c:	457c                	lw	a5,76(a0)
    8000439e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a0:	fa040a13          	addi	s4,s0,-96
    800043a4:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800043a6:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043aa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ac:	e79d                	bnez	a5,800043da <dirlookup+0x64>
    800043ae:	a88d                	j	80004420 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    800043b0:	00004517          	auipc	a0,0x4
    800043b4:	12850513          	addi	a0,a0,296 # 800084d8 <etext+0x4d8>
    800043b8:	ffffc097          	auipc	ra,0xffffc
    800043bc:	1a8080e7          	jalr	424(ra) # 80000560 <panic>
      panic("dirlookup read");
    800043c0:	00004517          	auipc	a0,0x4
    800043c4:	13050513          	addi	a0,a0,304 # 800084f0 <etext+0x4f0>
    800043c8:	ffffc097          	auipc	ra,0xffffc
    800043cc:	198080e7          	jalr	408(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043d0:	24c1                	addiw	s1,s1,16
    800043d2:	04c92783          	lw	a5,76(s2)
    800043d6:	04f4f463          	bgeu	s1,a5,8000441e <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043da:	874e                	mv	a4,s3
    800043dc:	86a6                	mv	a3,s1
    800043de:	8652                	mv	a2,s4
    800043e0:	4581                	li	a1,0
    800043e2:	854a                	mv	a0,s2
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	d52080e7          	jalr	-686(ra) # 80004136 <readi>
    800043ec:	fd351ae3          	bne	a0,s3,800043c0 <dirlookup+0x4a>
    if(de.inum == 0)
    800043f0:	fa045783          	lhu	a5,-96(s0)
    800043f4:	dff1                	beqz	a5,800043d0 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    800043f6:	85da                	mv	a1,s6
    800043f8:	8556                	mv	a0,s5
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	f62080e7          	jalr	-158(ra) # 8000435c <namecmp>
    80004402:	f579                	bnez	a0,800043d0 <dirlookup+0x5a>
      if(poff)
    80004404:	000b8463          	beqz	s7,8000440c <dirlookup+0x96>
        *poff = off;
    80004408:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000440c:	fa045583          	lhu	a1,-96(s0)
    80004410:	00092503          	lw	a0,0(s2)
    80004414:	fffff097          	auipc	ra,0xfffff
    80004418:	726080e7          	jalr	1830(ra) # 80003b3a <iget>
    8000441c:	a011                	j	80004420 <dirlookup+0xaa>
  return 0;
    8000441e:	4501                	li	a0,0
}
    80004420:	60e6                	ld	ra,88(sp)
    80004422:	6446                	ld	s0,80(sp)
    80004424:	64a6                	ld	s1,72(sp)
    80004426:	6906                	ld	s2,64(sp)
    80004428:	79e2                	ld	s3,56(sp)
    8000442a:	7a42                	ld	s4,48(sp)
    8000442c:	7aa2                	ld	s5,40(sp)
    8000442e:	7b02                	ld	s6,32(sp)
    80004430:	6be2                	ld	s7,24(sp)
    80004432:	6125                	addi	sp,sp,96
    80004434:	8082                	ret

0000000080004436 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004436:	711d                	addi	sp,sp,-96
    80004438:	ec86                	sd	ra,88(sp)
    8000443a:	e8a2                	sd	s0,80(sp)
    8000443c:	e4a6                	sd	s1,72(sp)
    8000443e:	e0ca                	sd	s2,64(sp)
    80004440:	fc4e                	sd	s3,56(sp)
    80004442:	f852                	sd	s4,48(sp)
    80004444:	f456                	sd	s5,40(sp)
    80004446:	f05a                	sd	s6,32(sp)
    80004448:	ec5e                	sd	s7,24(sp)
    8000444a:	e862                	sd	s8,16(sp)
    8000444c:	e466                	sd	s9,8(sp)
    8000444e:	e06a                	sd	s10,0(sp)
    80004450:	1080                	addi	s0,sp,96
    80004452:	84aa                	mv	s1,a0
    80004454:	8b2e                	mv	s6,a1
    80004456:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004458:	00054703          	lbu	a4,0(a0)
    8000445c:	02f00793          	li	a5,47
    80004460:	02f70363          	beq	a4,a5,80004486 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	604080e7          	jalr	1540(ra) # 80001a68 <myproc>
    8000446c:	15053503          	ld	a0,336(a0)
    80004470:	00000097          	auipc	ra,0x0
    80004474:	9cc080e7          	jalr	-1588(ra) # 80003e3c <idup>
    80004478:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000447a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000447e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80004480:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004482:	4b85                	li	s7,1
    80004484:	a87d                	j	80004542 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004486:	4585                	li	a1,1
    80004488:	852e                	mv	a0,a1
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	6b0080e7          	jalr	1712(ra) # 80003b3a <iget>
    80004492:	8a2a                	mv	s4,a0
    80004494:	b7dd                	j	8000447a <namex+0x44>
      iunlockput(ip);
    80004496:	8552                	mv	a0,s4
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	c48080e7          	jalr	-952(ra) # 800040e0 <iunlockput>
      return 0;
    800044a0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800044a2:	8552                	mv	a0,s4
    800044a4:	60e6                	ld	ra,88(sp)
    800044a6:	6446                	ld	s0,80(sp)
    800044a8:	64a6                	ld	s1,72(sp)
    800044aa:	6906                	ld	s2,64(sp)
    800044ac:	79e2                	ld	s3,56(sp)
    800044ae:	7a42                	ld	s4,48(sp)
    800044b0:	7aa2                	ld	s5,40(sp)
    800044b2:	7b02                	ld	s6,32(sp)
    800044b4:	6be2                	ld	s7,24(sp)
    800044b6:	6c42                	ld	s8,16(sp)
    800044b8:	6ca2                	ld	s9,8(sp)
    800044ba:	6d02                	ld	s10,0(sp)
    800044bc:	6125                	addi	sp,sp,96
    800044be:	8082                	ret
      iunlock(ip);
    800044c0:	8552                	mv	a0,s4
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	a7e080e7          	jalr	-1410(ra) # 80003f40 <iunlock>
      return ip;
    800044ca:	bfe1                	j	800044a2 <namex+0x6c>
      iunlockput(ip);
    800044cc:	8552                	mv	a0,s4
    800044ce:	00000097          	auipc	ra,0x0
    800044d2:	c12080e7          	jalr	-1006(ra) # 800040e0 <iunlockput>
      return 0;
    800044d6:	8a4e                	mv	s4,s3
    800044d8:	b7e9                	j	800044a2 <namex+0x6c>
  len = path - s;
    800044da:	40998633          	sub	a2,s3,s1
    800044de:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800044e2:	09ac5863          	bge	s8,s10,80004572 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800044e6:	8666                	mv	a2,s9
    800044e8:	85a6                	mv	a1,s1
    800044ea:	8556                	mv	a0,s5
    800044ec:	ffffd097          	auipc	ra,0xffffd
    800044f0:	8ae080e7          	jalr	-1874(ra) # 80000d9a <memmove>
    800044f4:	84ce                	mv	s1,s3
  while(*path == '/')
    800044f6:	0004c783          	lbu	a5,0(s1)
    800044fa:	01279763          	bne	a5,s2,80004508 <namex+0xd2>
    path++;
    800044fe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004500:	0004c783          	lbu	a5,0(s1)
    80004504:	ff278de3          	beq	a5,s2,800044fe <namex+0xc8>
    ilock(ip);
    80004508:	8552                	mv	a0,s4
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	970080e7          	jalr	-1680(ra) # 80003e7a <ilock>
    if(ip->type != T_DIR){
    80004512:	044a1783          	lh	a5,68(s4)
    80004516:	f97790e3          	bne	a5,s7,80004496 <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000451a:	000b0563          	beqz	s6,80004524 <namex+0xee>
    8000451e:	0004c783          	lbu	a5,0(s1)
    80004522:	dfd9                	beqz	a5,800044c0 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004524:	4601                	li	a2,0
    80004526:	85d6                	mv	a1,s5
    80004528:	8552                	mv	a0,s4
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	e4c080e7          	jalr	-436(ra) # 80004376 <dirlookup>
    80004532:	89aa                	mv	s3,a0
    80004534:	dd41                	beqz	a0,800044cc <namex+0x96>
    iunlockput(ip);
    80004536:	8552                	mv	a0,s4
    80004538:	00000097          	auipc	ra,0x0
    8000453c:	ba8080e7          	jalr	-1112(ra) # 800040e0 <iunlockput>
    ip = next;
    80004540:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004542:	0004c783          	lbu	a5,0(s1)
    80004546:	01279763          	bne	a5,s2,80004554 <namex+0x11e>
    path++;
    8000454a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000454c:	0004c783          	lbu	a5,0(s1)
    80004550:	ff278de3          	beq	a5,s2,8000454a <namex+0x114>
  if(*path == 0)
    80004554:	cb9d                	beqz	a5,8000458a <namex+0x154>
  while(*path != '/' && *path != 0)
    80004556:	0004c783          	lbu	a5,0(s1)
    8000455a:	89a6                	mv	s3,s1
  len = path - s;
    8000455c:	4d01                	li	s10,0
    8000455e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004560:	01278963          	beq	a5,s2,80004572 <namex+0x13c>
    80004564:	dbbd                	beqz	a5,800044da <namex+0xa4>
    path++;
    80004566:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004568:	0009c783          	lbu	a5,0(s3)
    8000456c:	ff279ce3          	bne	a5,s2,80004564 <namex+0x12e>
    80004570:	b7ad                	j	800044da <namex+0xa4>
    memmove(name, s, len);
    80004572:	2601                	sext.w	a2,a2
    80004574:	85a6                	mv	a1,s1
    80004576:	8556                	mv	a0,s5
    80004578:	ffffd097          	auipc	ra,0xffffd
    8000457c:	822080e7          	jalr	-2014(ra) # 80000d9a <memmove>
    name[len] = 0;
    80004580:	9d56                	add	s10,s10,s5
    80004582:	000d0023          	sb	zero,0(s10)
    80004586:	84ce                	mv	s1,s3
    80004588:	b7bd                	j	800044f6 <namex+0xc0>
  if(nameiparent){
    8000458a:	f00b0ce3          	beqz	s6,800044a2 <namex+0x6c>
    iput(ip);
    8000458e:	8552                	mv	a0,s4
    80004590:	00000097          	auipc	ra,0x0
    80004594:	aa8080e7          	jalr	-1368(ra) # 80004038 <iput>
    return 0;
    80004598:	4a01                	li	s4,0
    8000459a:	b721                	j	800044a2 <namex+0x6c>

000000008000459c <dirlink>:
{
    8000459c:	715d                	addi	sp,sp,-80
    8000459e:	e486                	sd	ra,72(sp)
    800045a0:	e0a2                	sd	s0,64(sp)
    800045a2:	f84a                	sd	s2,48(sp)
    800045a4:	ec56                	sd	s5,24(sp)
    800045a6:	e85a                	sd	s6,16(sp)
    800045a8:	0880                	addi	s0,sp,80
    800045aa:	892a                	mv	s2,a0
    800045ac:	8aae                	mv	s5,a1
    800045ae:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045b0:	4601                	li	a2,0
    800045b2:	00000097          	auipc	ra,0x0
    800045b6:	dc4080e7          	jalr	-572(ra) # 80004376 <dirlookup>
    800045ba:	e129                	bnez	a0,800045fc <dirlink+0x60>
    800045bc:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045be:	04c92483          	lw	s1,76(s2)
    800045c2:	cca9                	beqz	s1,8000461c <dirlink+0x80>
    800045c4:	f44e                	sd	s3,40(sp)
    800045c6:	f052                	sd	s4,32(sp)
    800045c8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045ca:	fb040a13          	addi	s4,s0,-80
    800045ce:	49c1                	li	s3,16
    800045d0:	874e                	mv	a4,s3
    800045d2:	86a6                	mv	a3,s1
    800045d4:	8652                	mv	a2,s4
    800045d6:	4581                	li	a1,0
    800045d8:	854a                	mv	a0,s2
    800045da:	00000097          	auipc	ra,0x0
    800045de:	b5c080e7          	jalr	-1188(ra) # 80004136 <readi>
    800045e2:	03351363          	bne	a0,s3,80004608 <dirlink+0x6c>
    if(de.inum == 0)
    800045e6:	fb045783          	lhu	a5,-80(s0)
    800045ea:	c79d                	beqz	a5,80004618 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045ec:	24c1                	addiw	s1,s1,16
    800045ee:	04c92783          	lw	a5,76(s2)
    800045f2:	fcf4efe3          	bltu	s1,a5,800045d0 <dirlink+0x34>
    800045f6:	79a2                	ld	s3,40(sp)
    800045f8:	7a02                	ld	s4,32(sp)
    800045fa:	a00d                	j	8000461c <dirlink+0x80>
    iput(ip);
    800045fc:	00000097          	auipc	ra,0x0
    80004600:	a3c080e7          	jalr	-1476(ra) # 80004038 <iput>
    return -1;
    80004604:	557d                	li	a0,-1
    80004606:	a0a9                	j	80004650 <dirlink+0xb4>
      panic("dirlink read");
    80004608:	00004517          	auipc	a0,0x4
    8000460c:	ef850513          	addi	a0,a0,-264 # 80008500 <etext+0x500>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	f50080e7          	jalr	-176(ra) # 80000560 <panic>
    80004618:	79a2                	ld	s3,40(sp)
    8000461a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000461c:	4639                	li	a2,14
    8000461e:	85d6                	mv	a1,s5
    80004620:	fb240513          	addi	a0,s0,-78
    80004624:	ffffd097          	auipc	ra,0xffffd
    80004628:	828080e7          	jalr	-2008(ra) # 80000e4c <strncpy>
  de.inum = inum;
    8000462c:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004630:	4741                	li	a4,16
    80004632:	86a6                	mv	a3,s1
    80004634:	fb040613          	addi	a2,s0,-80
    80004638:	4581                	li	a1,0
    8000463a:	854a                	mv	a0,s2
    8000463c:	00000097          	auipc	ra,0x0
    80004640:	c00080e7          	jalr	-1024(ra) # 8000423c <writei>
    80004644:	1541                	addi	a0,a0,-16
    80004646:	00a03533          	snez	a0,a0
    8000464a:	40a0053b          	negw	a0,a0
    8000464e:	74e2                	ld	s1,56(sp)
}
    80004650:	60a6                	ld	ra,72(sp)
    80004652:	6406                	ld	s0,64(sp)
    80004654:	7942                	ld	s2,48(sp)
    80004656:	6ae2                	ld	s5,24(sp)
    80004658:	6b42                	ld	s6,16(sp)
    8000465a:	6161                	addi	sp,sp,80
    8000465c:	8082                	ret

000000008000465e <namei>:

struct inode*
namei(char *path)
{
    8000465e:	1101                	addi	sp,sp,-32
    80004660:	ec06                	sd	ra,24(sp)
    80004662:	e822                	sd	s0,16(sp)
    80004664:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004666:	fe040613          	addi	a2,s0,-32
    8000466a:	4581                	li	a1,0
    8000466c:	00000097          	auipc	ra,0x0
    80004670:	dca080e7          	jalr	-566(ra) # 80004436 <namex>
}
    80004674:	60e2                	ld	ra,24(sp)
    80004676:	6442                	ld	s0,16(sp)
    80004678:	6105                	addi	sp,sp,32
    8000467a:	8082                	ret

000000008000467c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000467c:	1141                	addi	sp,sp,-16
    8000467e:	e406                	sd	ra,8(sp)
    80004680:	e022                	sd	s0,0(sp)
    80004682:	0800                	addi	s0,sp,16
    80004684:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004686:	4585                	li	a1,1
    80004688:	00000097          	auipc	ra,0x0
    8000468c:	dae080e7          	jalr	-594(ra) # 80004436 <namex>
}
    80004690:	60a2                	ld	ra,8(sp)
    80004692:	6402                	ld	s0,0(sp)
    80004694:	0141                	addi	sp,sp,16
    80004696:	8082                	ret

0000000080004698 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004698:	1101                	addi	sp,sp,-32
    8000469a:	ec06                	sd	ra,24(sp)
    8000469c:	e822                	sd	s0,16(sp)
    8000469e:	e426                	sd	s1,8(sp)
    800046a0:	e04a                	sd	s2,0(sp)
    800046a2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046a4:	00020917          	auipc	s2,0x20
    800046a8:	88c90913          	addi	s2,s2,-1908 # 80023f30 <log>
    800046ac:	01892583          	lw	a1,24(s2)
    800046b0:	02892503          	lw	a0,40(s2)
    800046b4:	fffff097          	auipc	ra,0xfffff
    800046b8:	fb8080e7          	jalr	-72(ra) # 8000366c <bread>
    800046bc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046be:	02c92603          	lw	a2,44(s2)
    800046c2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046c4:	00c05f63          	blez	a2,800046e2 <write_head+0x4a>
    800046c8:	00020717          	auipc	a4,0x20
    800046cc:	89870713          	addi	a4,a4,-1896 # 80023f60 <log+0x30>
    800046d0:	87aa                	mv	a5,a0
    800046d2:	060a                	slli	a2,a2,0x2
    800046d4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800046d6:	4314                	lw	a3,0(a4)
    800046d8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800046da:	0711                	addi	a4,a4,4
    800046dc:	0791                	addi	a5,a5,4
    800046de:	fec79ce3          	bne	a5,a2,800046d6 <write_head+0x3e>
  }
  bwrite(buf);
    800046e2:	8526                	mv	a0,s1
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	07a080e7          	jalr	122(ra) # 8000375e <bwrite>
  brelse(buf);
    800046ec:	8526                	mv	a0,s1
    800046ee:	fffff097          	auipc	ra,0xfffff
    800046f2:	0ae080e7          	jalr	174(ra) # 8000379c <brelse>
}
    800046f6:	60e2                	ld	ra,24(sp)
    800046f8:	6442                	ld	s0,16(sp)
    800046fa:	64a2                	ld	s1,8(sp)
    800046fc:	6902                	ld	s2,0(sp)
    800046fe:	6105                	addi	sp,sp,32
    80004700:	8082                	ret

0000000080004702 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004702:	00020797          	auipc	a5,0x20
    80004706:	85a7a783          	lw	a5,-1958(a5) # 80023f5c <log+0x2c>
    8000470a:	0cf05063          	blez	a5,800047ca <install_trans+0xc8>
{
    8000470e:	715d                	addi	sp,sp,-80
    80004710:	e486                	sd	ra,72(sp)
    80004712:	e0a2                	sd	s0,64(sp)
    80004714:	fc26                	sd	s1,56(sp)
    80004716:	f84a                	sd	s2,48(sp)
    80004718:	f44e                	sd	s3,40(sp)
    8000471a:	f052                	sd	s4,32(sp)
    8000471c:	ec56                	sd	s5,24(sp)
    8000471e:	e85a                	sd	s6,16(sp)
    80004720:	e45e                	sd	s7,8(sp)
    80004722:	0880                	addi	s0,sp,80
    80004724:	8b2a                	mv	s6,a0
    80004726:	00020a97          	auipc	s5,0x20
    8000472a:	83aa8a93          	addi	s5,s5,-1990 # 80023f60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000472e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004730:	00020997          	auipc	s3,0x20
    80004734:	80098993          	addi	s3,s3,-2048 # 80023f30 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004738:	40000b93          	li	s7,1024
    8000473c:	a00d                	j	8000475e <install_trans+0x5c>
    brelse(lbuf);
    8000473e:	854a                	mv	a0,s2
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	05c080e7          	jalr	92(ra) # 8000379c <brelse>
    brelse(dbuf);
    80004748:	8526                	mv	a0,s1
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	052080e7          	jalr	82(ra) # 8000379c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004752:	2a05                	addiw	s4,s4,1
    80004754:	0a91                	addi	s5,s5,4
    80004756:	02c9a783          	lw	a5,44(s3)
    8000475a:	04fa5d63          	bge	s4,a5,800047b4 <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000475e:	0189a583          	lw	a1,24(s3)
    80004762:	014585bb          	addw	a1,a1,s4
    80004766:	2585                	addiw	a1,a1,1
    80004768:	0289a503          	lw	a0,40(s3)
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	f00080e7          	jalr	-256(ra) # 8000366c <bread>
    80004774:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004776:	000aa583          	lw	a1,0(s5)
    8000477a:	0289a503          	lw	a0,40(s3)
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	eee080e7          	jalr	-274(ra) # 8000366c <bread>
    80004786:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004788:	865e                	mv	a2,s7
    8000478a:	05890593          	addi	a1,s2,88
    8000478e:	05850513          	addi	a0,a0,88
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	608080e7          	jalr	1544(ra) # 80000d9a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000479a:	8526                	mv	a0,s1
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	fc2080e7          	jalr	-62(ra) # 8000375e <bwrite>
    if(recovering == 0)
    800047a4:	f80b1de3          	bnez	s6,8000473e <install_trans+0x3c>
      bunpin(dbuf);
    800047a8:	8526                	mv	a0,s1
    800047aa:	fffff097          	auipc	ra,0xfffff
    800047ae:	0c6080e7          	jalr	198(ra) # 80003870 <bunpin>
    800047b2:	b771                	j	8000473e <install_trans+0x3c>
}
    800047b4:	60a6                	ld	ra,72(sp)
    800047b6:	6406                	ld	s0,64(sp)
    800047b8:	74e2                	ld	s1,56(sp)
    800047ba:	7942                	ld	s2,48(sp)
    800047bc:	79a2                	ld	s3,40(sp)
    800047be:	7a02                	ld	s4,32(sp)
    800047c0:	6ae2                	ld	s5,24(sp)
    800047c2:	6b42                	ld	s6,16(sp)
    800047c4:	6ba2                	ld	s7,8(sp)
    800047c6:	6161                	addi	sp,sp,80
    800047c8:	8082                	ret
    800047ca:	8082                	ret

00000000800047cc <initlog>:
{
    800047cc:	7179                	addi	sp,sp,-48
    800047ce:	f406                	sd	ra,40(sp)
    800047d0:	f022                	sd	s0,32(sp)
    800047d2:	ec26                	sd	s1,24(sp)
    800047d4:	e84a                	sd	s2,16(sp)
    800047d6:	e44e                	sd	s3,8(sp)
    800047d8:	1800                	addi	s0,sp,48
    800047da:	892a                	mv	s2,a0
    800047dc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047de:	0001f497          	auipc	s1,0x1f
    800047e2:	75248493          	addi	s1,s1,1874 # 80023f30 <log>
    800047e6:	00004597          	auipc	a1,0x4
    800047ea:	d2a58593          	addi	a1,a1,-726 # 80008510 <etext+0x510>
    800047ee:	8526                	mv	a0,s1
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	3ba080e7          	jalr	954(ra) # 80000baa <initlock>
  log.start = sb->logstart;
    800047f8:	0149a583          	lw	a1,20(s3)
    800047fc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800047fe:	0109a783          	lw	a5,16(s3)
    80004802:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004804:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004808:	854a                	mv	a0,s2
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	e62080e7          	jalr	-414(ra) # 8000366c <bread>
  log.lh.n = lh->n;
    80004812:	4d30                	lw	a2,88(a0)
    80004814:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004816:	00c05f63          	blez	a2,80004834 <initlog+0x68>
    8000481a:	87aa                	mv	a5,a0
    8000481c:	0001f717          	auipc	a4,0x1f
    80004820:	74470713          	addi	a4,a4,1860 # 80023f60 <log+0x30>
    80004824:	060a                	slli	a2,a2,0x2
    80004826:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004828:	4ff4                	lw	a3,92(a5)
    8000482a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000482c:	0791                	addi	a5,a5,4
    8000482e:	0711                	addi	a4,a4,4
    80004830:	fec79ce3          	bne	a5,a2,80004828 <initlog+0x5c>
  brelse(buf);
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	f68080e7          	jalr	-152(ra) # 8000379c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000483c:	4505                	li	a0,1
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	ec4080e7          	jalr	-316(ra) # 80004702 <install_trans>
  log.lh.n = 0;
    80004846:	0001f797          	auipc	a5,0x1f
    8000484a:	7007ab23          	sw	zero,1814(a5) # 80023f5c <log+0x2c>
  write_head(); // clear the log
    8000484e:	00000097          	auipc	ra,0x0
    80004852:	e4a080e7          	jalr	-438(ra) # 80004698 <write_head>
}
    80004856:	70a2                	ld	ra,40(sp)
    80004858:	7402                	ld	s0,32(sp)
    8000485a:	64e2                	ld	s1,24(sp)
    8000485c:	6942                	ld	s2,16(sp)
    8000485e:	69a2                	ld	s3,8(sp)
    80004860:	6145                	addi	sp,sp,48
    80004862:	8082                	ret

0000000080004864 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004864:	1101                	addi	sp,sp,-32
    80004866:	ec06                	sd	ra,24(sp)
    80004868:	e822                	sd	s0,16(sp)
    8000486a:	e426                	sd	s1,8(sp)
    8000486c:	e04a                	sd	s2,0(sp)
    8000486e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004870:	0001f517          	auipc	a0,0x1f
    80004874:	6c050513          	addi	a0,a0,1728 # 80023f30 <log>
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	3c6080e7          	jalr	966(ra) # 80000c3e <acquire>
  while(1){
    if(log.committing){
    80004880:	0001f497          	auipc	s1,0x1f
    80004884:	6b048493          	addi	s1,s1,1712 # 80023f30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004888:	4979                	li	s2,30
    8000488a:	a039                	j	80004898 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000488c:	85a6                	mv	a1,s1
    8000488e:	8526                	mv	a0,s1
    80004890:	ffffe097          	auipc	ra,0xffffe
    80004894:	bf8080e7          	jalr	-1032(ra) # 80002488 <sleep>
    if(log.committing){
    80004898:	50dc                	lw	a5,36(s1)
    8000489a:	fbed                	bnez	a5,8000488c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000489c:	5098                	lw	a4,32(s1)
    8000489e:	2705                	addiw	a4,a4,1
    800048a0:	0027179b          	slliw	a5,a4,0x2
    800048a4:	9fb9                	addw	a5,a5,a4
    800048a6:	0017979b          	slliw	a5,a5,0x1
    800048aa:	54d4                	lw	a3,44(s1)
    800048ac:	9fb5                	addw	a5,a5,a3
    800048ae:	00f95963          	bge	s2,a5,800048c0 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048b2:	85a6                	mv	a1,s1
    800048b4:	8526                	mv	a0,s1
    800048b6:	ffffe097          	auipc	ra,0xffffe
    800048ba:	bd2080e7          	jalr	-1070(ra) # 80002488 <sleep>
    800048be:	bfe9                	j	80004898 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048c0:	0001f517          	auipc	a0,0x1f
    800048c4:	67050513          	addi	a0,a0,1648 # 80023f30 <log>
    800048c8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800048ca:	ffffc097          	auipc	ra,0xffffc
    800048ce:	424080e7          	jalr	1060(ra) # 80000cee <release>
      break;
    }
  }
}
    800048d2:	60e2                	ld	ra,24(sp)
    800048d4:	6442                	ld	s0,16(sp)
    800048d6:	64a2                	ld	s1,8(sp)
    800048d8:	6902                	ld	s2,0(sp)
    800048da:	6105                	addi	sp,sp,32
    800048dc:	8082                	ret

00000000800048de <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048de:	7139                	addi	sp,sp,-64
    800048e0:	fc06                	sd	ra,56(sp)
    800048e2:	f822                	sd	s0,48(sp)
    800048e4:	f426                	sd	s1,40(sp)
    800048e6:	f04a                	sd	s2,32(sp)
    800048e8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048ea:	0001f497          	auipc	s1,0x1f
    800048ee:	64648493          	addi	s1,s1,1606 # 80023f30 <log>
    800048f2:	8526                	mv	a0,s1
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	34a080e7          	jalr	842(ra) # 80000c3e <acquire>
  log.outstanding -= 1;
    800048fc:	509c                	lw	a5,32(s1)
    800048fe:	37fd                	addiw	a5,a5,-1
    80004900:	893e                	mv	s2,a5
    80004902:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004904:	50dc                	lw	a5,36(s1)
    80004906:	e7b9                	bnez	a5,80004954 <end_op+0x76>
    panic("log.committing");
  if(log.outstanding == 0){
    80004908:	06091263          	bnez	s2,8000496c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000490c:	0001f497          	auipc	s1,0x1f
    80004910:	62448493          	addi	s1,s1,1572 # 80023f30 <log>
    80004914:	4785                	li	a5,1
    80004916:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004918:	8526                	mv	a0,s1
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	3d4080e7          	jalr	980(ra) # 80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004922:	54dc                	lw	a5,44(s1)
    80004924:	06f04863          	bgtz	a5,80004994 <end_op+0xb6>
    acquire(&log.lock);
    80004928:	0001f497          	auipc	s1,0x1f
    8000492c:	60848493          	addi	s1,s1,1544 # 80023f30 <log>
    80004930:	8526                	mv	a0,s1
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	30c080e7          	jalr	780(ra) # 80000c3e <acquire>
    log.committing = 0;
    8000493a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000493e:	8526                	mv	a0,s1
    80004940:	ffffe097          	auipc	ra,0xffffe
    80004944:	bac080e7          	jalr	-1108(ra) # 800024ec <wakeup>
    release(&log.lock);
    80004948:	8526                	mv	a0,s1
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	3a4080e7          	jalr	932(ra) # 80000cee <release>
}
    80004952:	a81d                	j	80004988 <end_op+0xaa>
    80004954:	ec4e                	sd	s3,24(sp)
    80004956:	e852                	sd	s4,16(sp)
    80004958:	e456                	sd	s5,8(sp)
    8000495a:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    8000495c:	00004517          	auipc	a0,0x4
    80004960:	bbc50513          	addi	a0,a0,-1092 # 80008518 <etext+0x518>
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	bfc080e7          	jalr	-1028(ra) # 80000560 <panic>
    wakeup(&log);
    8000496c:	0001f497          	auipc	s1,0x1f
    80004970:	5c448493          	addi	s1,s1,1476 # 80023f30 <log>
    80004974:	8526                	mv	a0,s1
    80004976:	ffffe097          	auipc	ra,0xffffe
    8000497a:	b76080e7          	jalr	-1162(ra) # 800024ec <wakeup>
  release(&log.lock);
    8000497e:	8526                	mv	a0,s1
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	36e080e7          	jalr	878(ra) # 80000cee <release>
}
    80004988:	70e2                	ld	ra,56(sp)
    8000498a:	7442                	ld	s0,48(sp)
    8000498c:	74a2                	ld	s1,40(sp)
    8000498e:	7902                	ld	s2,32(sp)
    80004990:	6121                	addi	sp,sp,64
    80004992:	8082                	ret
    80004994:	ec4e                	sd	s3,24(sp)
    80004996:	e852                	sd	s4,16(sp)
    80004998:	e456                	sd	s5,8(sp)
    8000499a:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000499c:	0001fa97          	auipc	s5,0x1f
    800049a0:	5c4a8a93          	addi	s5,s5,1476 # 80023f60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049a4:	0001fa17          	auipc	s4,0x1f
    800049a8:	58ca0a13          	addi	s4,s4,1420 # 80023f30 <log>
    memmove(to->data, from->data, BSIZE);
    800049ac:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049b0:	018a2583          	lw	a1,24(s4)
    800049b4:	012585bb          	addw	a1,a1,s2
    800049b8:	2585                	addiw	a1,a1,1
    800049ba:	028a2503          	lw	a0,40(s4)
    800049be:	fffff097          	auipc	ra,0xfffff
    800049c2:	cae080e7          	jalr	-850(ra) # 8000366c <bread>
    800049c6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049c8:	000aa583          	lw	a1,0(s5)
    800049cc:	028a2503          	lw	a0,40(s4)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	c9c080e7          	jalr	-868(ra) # 8000366c <bread>
    800049d8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049da:	865a                	mv	a2,s6
    800049dc:	05850593          	addi	a1,a0,88
    800049e0:	05848513          	addi	a0,s1,88
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	3b6080e7          	jalr	950(ra) # 80000d9a <memmove>
    bwrite(to);  // write the log
    800049ec:	8526                	mv	a0,s1
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	d70080e7          	jalr	-656(ra) # 8000375e <bwrite>
    brelse(from);
    800049f6:	854e                	mv	a0,s3
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	da4080e7          	jalr	-604(ra) # 8000379c <brelse>
    brelse(to);
    80004a00:	8526                	mv	a0,s1
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	d9a080e7          	jalr	-614(ra) # 8000379c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a0a:	2905                	addiw	s2,s2,1
    80004a0c:	0a91                	addi	s5,s5,4
    80004a0e:	02ca2783          	lw	a5,44(s4)
    80004a12:	f8f94fe3          	blt	s2,a5,800049b0 <end_op+0xd2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a16:	00000097          	auipc	ra,0x0
    80004a1a:	c82080e7          	jalr	-894(ra) # 80004698 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a1e:	4501                	li	a0,0
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	ce2080e7          	jalr	-798(ra) # 80004702 <install_trans>
    log.lh.n = 0;
    80004a28:	0001f797          	auipc	a5,0x1f
    80004a2c:	5207aa23          	sw	zero,1332(a5) # 80023f5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a30:	00000097          	auipc	ra,0x0
    80004a34:	c68080e7          	jalr	-920(ra) # 80004698 <write_head>
    80004a38:	69e2                	ld	s3,24(sp)
    80004a3a:	6a42                	ld	s4,16(sp)
    80004a3c:	6aa2                	ld	s5,8(sp)
    80004a3e:	6b02                	ld	s6,0(sp)
    80004a40:	b5e5                	j	80004928 <end_op+0x4a>

0000000080004a42 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	e04a                	sd	s2,0(sp)
    80004a4c:	1000                	addi	s0,sp,32
    80004a4e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a50:	0001f917          	auipc	s2,0x1f
    80004a54:	4e090913          	addi	s2,s2,1248 # 80023f30 <log>
    80004a58:	854a                	mv	a0,s2
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	1e4080e7          	jalr	484(ra) # 80000c3e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a62:	02c92603          	lw	a2,44(s2)
    80004a66:	47f5                	li	a5,29
    80004a68:	06c7c563          	blt	a5,a2,80004ad2 <log_write+0x90>
    80004a6c:	0001f797          	auipc	a5,0x1f
    80004a70:	4e07a783          	lw	a5,1248(a5) # 80023f4c <log+0x1c>
    80004a74:	37fd                	addiw	a5,a5,-1
    80004a76:	04f65e63          	bge	a2,a5,80004ad2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a7a:	0001f797          	auipc	a5,0x1f
    80004a7e:	4d67a783          	lw	a5,1238(a5) # 80023f50 <log+0x20>
    80004a82:	06f05063          	blez	a5,80004ae2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a86:	4781                	li	a5,0
    80004a88:	06c05563          	blez	a2,80004af2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a8c:	44cc                	lw	a1,12(s1)
    80004a8e:	0001f717          	auipc	a4,0x1f
    80004a92:	4d270713          	addi	a4,a4,1234 # 80023f60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a96:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a98:	4314                	lw	a3,0(a4)
    80004a9a:	04b68c63          	beq	a3,a1,80004af2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a9e:	2785                	addiw	a5,a5,1
    80004aa0:	0711                	addi	a4,a4,4
    80004aa2:	fef61be3          	bne	a2,a5,80004a98 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004aa6:	0621                	addi	a2,a2,8
    80004aa8:	060a                	slli	a2,a2,0x2
    80004aaa:	0001f797          	auipc	a5,0x1f
    80004aae:	48678793          	addi	a5,a5,1158 # 80023f30 <log>
    80004ab2:	97b2                	add	a5,a5,a2
    80004ab4:	44d8                	lw	a4,12(s1)
    80004ab6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ab8:	8526                	mv	a0,s1
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	d7a080e7          	jalr	-646(ra) # 80003834 <bpin>
    log.lh.n++;
    80004ac2:	0001f717          	auipc	a4,0x1f
    80004ac6:	46e70713          	addi	a4,a4,1134 # 80023f30 <log>
    80004aca:	575c                	lw	a5,44(a4)
    80004acc:	2785                	addiw	a5,a5,1
    80004ace:	d75c                	sw	a5,44(a4)
    80004ad0:	a82d                	j	80004b0a <log_write+0xc8>
    panic("too big a transaction");
    80004ad2:	00004517          	auipc	a0,0x4
    80004ad6:	a5650513          	addi	a0,a0,-1450 # 80008528 <etext+0x528>
    80004ada:	ffffc097          	auipc	ra,0xffffc
    80004ade:	a86080e7          	jalr	-1402(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004ae2:	00004517          	auipc	a0,0x4
    80004ae6:	a5e50513          	addi	a0,a0,-1442 # 80008540 <etext+0x540>
    80004aea:	ffffc097          	auipc	ra,0xffffc
    80004aee:	a76080e7          	jalr	-1418(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004af2:	00878693          	addi	a3,a5,8
    80004af6:	068a                	slli	a3,a3,0x2
    80004af8:	0001f717          	auipc	a4,0x1f
    80004afc:	43870713          	addi	a4,a4,1080 # 80023f30 <log>
    80004b00:	9736                	add	a4,a4,a3
    80004b02:	44d4                	lw	a3,12(s1)
    80004b04:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b06:	faf609e3          	beq	a2,a5,80004ab8 <log_write+0x76>
  }
  release(&log.lock);
    80004b0a:	0001f517          	auipc	a0,0x1f
    80004b0e:	42650513          	addi	a0,a0,1062 # 80023f30 <log>
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	1dc080e7          	jalr	476(ra) # 80000cee <release>
}
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6902                	ld	s2,0(sp)
    80004b22:	6105                	addi	sp,sp,32
    80004b24:	8082                	ret

0000000080004b26 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b26:	1101                	addi	sp,sp,-32
    80004b28:	ec06                	sd	ra,24(sp)
    80004b2a:	e822                	sd	s0,16(sp)
    80004b2c:	e426                	sd	s1,8(sp)
    80004b2e:	e04a                	sd	s2,0(sp)
    80004b30:	1000                	addi	s0,sp,32
    80004b32:	84aa                	mv	s1,a0
    80004b34:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b36:	00004597          	auipc	a1,0x4
    80004b3a:	a2a58593          	addi	a1,a1,-1494 # 80008560 <etext+0x560>
    80004b3e:	0521                	addi	a0,a0,8
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	06a080e7          	jalr	106(ra) # 80000baa <initlock>
  lk->name = name;
    80004b48:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b4c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b50:	0204a423          	sw	zero,40(s1)
}
    80004b54:	60e2                	ld	ra,24(sp)
    80004b56:	6442                	ld	s0,16(sp)
    80004b58:	64a2                	ld	s1,8(sp)
    80004b5a:	6902                	ld	s2,0(sp)
    80004b5c:	6105                	addi	sp,sp,32
    80004b5e:	8082                	ret

0000000080004b60 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b60:	1101                	addi	sp,sp,-32
    80004b62:	ec06                	sd	ra,24(sp)
    80004b64:	e822                	sd	s0,16(sp)
    80004b66:	e426                	sd	s1,8(sp)
    80004b68:	e04a                	sd	s2,0(sp)
    80004b6a:	1000                	addi	s0,sp,32
    80004b6c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b6e:	00850913          	addi	s2,a0,8
    80004b72:	854a                	mv	a0,s2
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	0ca080e7          	jalr	202(ra) # 80000c3e <acquire>
  while (lk->locked) {
    80004b7c:	409c                	lw	a5,0(s1)
    80004b7e:	cb89                	beqz	a5,80004b90 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b80:	85ca                	mv	a1,s2
    80004b82:	8526                	mv	a0,s1
    80004b84:	ffffe097          	auipc	ra,0xffffe
    80004b88:	904080e7          	jalr	-1788(ra) # 80002488 <sleep>
  while (lk->locked) {
    80004b8c:	409c                	lw	a5,0(s1)
    80004b8e:	fbed                	bnez	a5,80004b80 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b90:	4785                	li	a5,1
    80004b92:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b94:	ffffd097          	auipc	ra,0xffffd
    80004b98:	ed4080e7          	jalr	-300(ra) # 80001a68 <myproc>
    80004b9c:	591c                	lw	a5,48(a0)
    80004b9e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ba0:	854a                	mv	a0,s2
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	14c080e7          	jalr	332(ra) # 80000cee <release>
}
    80004baa:	60e2                	ld	ra,24(sp)
    80004bac:	6442                	ld	s0,16(sp)
    80004bae:	64a2                	ld	s1,8(sp)
    80004bb0:	6902                	ld	s2,0(sp)
    80004bb2:	6105                	addi	sp,sp,32
    80004bb4:	8082                	ret

0000000080004bb6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bb6:	1101                	addi	sp,sp,-32
    80004bb8:	ec06                	sd	ra,24(sp)
    80004bba:	e822                	sd	s0,16(sp)
    80004bbc:	e426                	sd	s1,8(sp)
    80004bbe:	e04a                	sd	s2,0(sp)
    80004bc0:	1000                	addi	s0,sp,32
    80004bc2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bc4:	00850913          	addi	s2,a0,8
    80004bc8:	854a                	mv	a0,s2
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	074080e7          	jalr	116(ra) # 80000c3e <acquire>
  lk->locked = 0;
    80004bd2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bd6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004bda:	8526                	mv	a0,s1
    80004bdc:	ffffe097          	auipc	ra,0xffffe
    80004be0:	910080e7          	jalr	-1776(ra) # 800024ec <wakeup>
  release(&lk->lk);
    80004be4:	854a                	mv	a0,s2
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	108080e7          	jalr	264(ra) # 80000cee <release>
}
    80004bee:	60e2                	ld	ra,24(sp)
    80004bf0:	6442                	ld	s0,16(sp)
    80004bf2:	64a2                	ld	s1,8(sp)
    80004bf4:	6902                	ld	s2,0(sp)
    80004bf6:	6105                	addi	sp,sp,32
    80004bf8:	8082                	ret

0000000080004bfa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bfa:	7179                	addi	sp,sp,-48
    80004bfc:	f406                	sd	ra,40(sp)
    80004bfe:	f022                	sd	s0,32(sp)
    80004c00:	ec26                	sd	s1,24(sp)
    80004c02:	e84a                	sd	s2,16(sp)
    80004c04:	1800                	addi	s0,sp,48
    80004c06:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c08:	00850913          	addi	s2,a0,8
    80004c0c:	854a                	mv	a0,s2
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	030080e7          	jalr	48(ra) # 80000c3e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c16:	409c                	lw	a5,0(s1)
    80004c18:	ef91                	bnez	a5,80004c34 <holdingsleep+0x3a>
    80004c1a:	4481                	li	s1,0
  release(&lk->lk);
    80004c1c:	854a                	mv	a0,s2
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	0d0080e7          	jalr	208(ra) # 80000cee <release>
  return r;
}
    80004c26:	8526                	mv	a0,s1
    80004c28:	70a2                	ld	ra,40(sp)
    80004c2a:	7402                	ld	s0,32(sp)
    80004c2c:	64e2                	ld	s1,24(sp)
    80004c2e:	6942                	ld	s2,16(sp)
    80004c30:	6145                	addi	sp,sp,48
    80004c32:	8082                	ret
    80004c34:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c36:	0284a983          	lw	s3,40(s1)
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	e2e080e7          	jalr	-466(ra) # 80001a68 <myproc>
    80004c42:	5904                	lw	s1,48(a0)
    80004c44:	413484b3          	sub	s1,s1,s3
    80004c48:	0014b493          	seqz	s1,s1
    80004c4c:	69a2                	ld	s3,8(sp)
    80004c4e:	b7f9                	j	80004c1c <holdingsleep+0x22>

0000000080004c50 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c50:	1141                	addi	sp,sp,-16
    80004c52:	e406                	sd	ra,8(sp)
    80004c54:	e022                	sd	s0,0(sp)
    80004c56:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c58:	00004597          	auipc	a1,0x4
    80004c5c:	91858593          	addi	a1,a1,-1768 # 80008570 <etext+0x570>
    80004c60:	0001f517          	auipc	a0,0x1f
    80004c64:	41850513          	addi	a0,a0,1048 # 80024078 <ftable>
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	f42080e7          	jalr	-190(ra) # 80000baa <initlock>
}
    80004c70:	60a2                	ld	ra,8(sp)
    80004c72:	6402                	ld	s0,0(sp)
    80004c74:	0141                	addi	sp,sp,16
    80004c76:	8082                	ret

0000000080004c78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c78:	1101                	addi	sp,sp,-32
    80004c7a:	ec06                	sd	ra,24(sp)
    80004c7c:	e822                	sd	s0,16(sp)
    80004c7e:	e426                	sd	s1,8(sp)
    80004c80:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c82:	0001f517          	auipc	a0,0x1f
    80004c86:	3f650513          	addi	a0,a0,1014 # 80024078 <ftable>
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	fb4080e7          	jalr	-76(ra) # 80000c3e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c92:	0001f497          	auipc	s1,0x1f
    80004c96:	3fe48493          	addi	s1,s1,1022 # 80024090 <ftable+0x18>
    80004c9a:	00020717          	auipc	a4,0x20
    80004c9e:	39670713          	addi	a4,a4,918 # 80025030 <disk>
    if(f->ref == 0){
    80004ca2:	40dc                	lw	a5,4(s1)
    80004ca4:	cf99                	beqz	a5,80004cc2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ca6:	02848493          	addi	s1,s1,40
    80004caa:	fee49ce3          	bne	s1,a4,80004ca2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cae:	0001f517          	auipc	a0,0x1f
    80004cb2:	3ca50513          	addi	a0,a0,970 # 80024078 <ftable>
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	038080e7          	jalr	56(ra) # 80000cee <release>
  return 0;
    80004cbe:	4481                	li	s1,0
    80004cc0:	a819                	j	80004cd6 <filealloc+0x5e>
      f->ref = 1;
    80004cc2:	4785                	li	a5,1
    80004cc4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cc6:	0001f517          	auipc	a0,0x1f
    80004cca:	3b250513          	addi	a0,a0,946 # 80024078 <ftable>
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	020080e7          	jalr	32(ra) # 80000cee <release>
}
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	60e2                	ld	ra,24(sp)
    80004cda:	6442                	ld	s0,16(sp)
    80004cdc:	64a2                	ld	s1,8(sp)
    80004cde:	6105                	addi	sp,sp,32
    80004ce0:	8082                	ret

0000000080004ce2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ce2:	1101                	addi	sp,sp,-32
    80004ce4:	ec06                	sd	ra,24(sp)
    80004ce6:	e822                	sd	s0,16(sp)
    80004ce8:	e426                	sd	s1,8(sp)
    80004cea:	1000                	addi	s0,sp,32
    80004cec:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004cee:	0001f517          	auipc	a0,0x1f
    80004cf2:	38a50513          	addi	a0,a0,906 # 80024078 <ftable>
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	f48080e7          	jalr	-184(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004cfe:	40dc                	lw	a5,4(s1)
    80004d00:	02f05263          	blez	a5,80004d24 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d04:	2785                	addiw	a5,a5,1
    80004d06:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d08:	0001f517          	auipc	a0,0x1f
    80004d0c:	37050513          	addi	a0,a0,880 # 80024078 <ftable>
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	fde080e7          	jalr	-34(ra) # 80000cee <release>
  return f;
}
    80004d18:	8526                	mv	a0,s1
    80004d1a:	60e2                	ld	ra,24(sp)
    80004d1c:	6442                	ld	s0,16(sp)
    80004d1e:	64a2                	ld	s1,8(sp)
    80004d20:	6105                	addi	sp,sp,32
    80004d22:	8082                	ret
    panic("filedup");
    80004d24:	00004517          	auipc	a0,0x4
    80004d28:	85450513          	addi	a0,a0,-1964 # 80008578 <etext+0x578>
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080004d34 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d34:	7139                	addi	sp,sp,-64
    80004d36:	fc06                	sd	ra,56(sp)
    80004d38:	f822                	sd	s0,48(sp)
    80004d3a:	f426                	sd	s1,40(sp)
    80004d3c:	0080                	addi	s0,sp,64
    80004d3e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d40:	0001f517          	auipc	a0,0x1f
    80004d44:	33850513          	addi	a0,a0,824 # 80024078 <ftable>
    80004d48:	ffffc097          	auipc	ra,0xffffc
    80004d4c:	ef6080e7          	jalr	-266(ra) # 80000c3e <acquire>
  if(f->ref < 1)
    80004d50:	40dc                	lw	a5,4(s1)
    80004d52:	04f05a63          	blez	a5,80004da6 <fileclose+0x72>
    panic("fileclose");
  if(--f->ref > 0){
    80004d56:	37fd                	addiw	a5,a5,-1
    80004d58:	c0dc                	sw	a5,4(s1)
    80004d5a:	06f04263          	bgtz	a5,80004dbe <fileclose+0x8a>
    80004d5e:	f04a                	sd	s2,32(sp)
    80004d60:	ec4e                	sd	s3,24(sp)
    80004d62:	e852                	sd	s4,16(sp)
    80004d64:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d66:	0004a903          	lw	s2,0(s1)
    80004d6a:	0094ca83          	lbu	s5,9(s1)
    80004d6e:	0104ba03          	ld	s4,16(s1)
    80004d72:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d76:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d7a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d7e:	0001f517          	auipc	a0,0x1f
    80004d82:	2fa50513          	addi	a0,a0,762 # 80024078 <ftable>
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	f68080e7          	jalr	-152(ra) # 80000cee <release>

  if(ff.type == FD_PIPE){
    80004d8e:	4785                	li	a5,1
    80004d90:	04f90463          	beq	s2,a5,80004dd8 <fileclose+0xa4>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d94:	3979                	addiw	s2,s2,-2
    80004d96:	4785                	li	a5,1
    80004d98:	0527fb63          	bgeu	a5,s2,80004dee <fileclose+0xba>
    80004d9c:	7902                	ld	s2,32(sp)
    80004d9e:	69e2                	ld	s3,24(sp)
    80004da0:	6a42                	ld	s4,16(sp)
    80004da2:	6aa2                	ld	s5,8(sp)
    80004da4:	a02d                	j	80004dce <fileclose+0x9a>
    80004da6:	f04a                	sd	s2,32(sp)
    80004da8:	ec4e                	sd	s3,24(sp)
    80004daa:	e852                	sd	s4,16(sp)
    80004dac:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004dae:	00003517          	auipc	a0,0x3
    80004db2:	7d250513          	addi	a0,a0,2002 # 80008580 <etext+0x580>
    80004db6:	ffffb097          	auipc	ra,0xffffb
    80004dba:	7aa080e7          	jalr	1962(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004dbe:	0001f517          	auipc	a0,0x1f
    80004dc2:	2ba50513          	addi	a0,a0,698 # 80024078 <ftable>
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	f28080e7          	jalr	-216(ra) # 80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004dce:	70e2                	ld	ra,56(sp)
    80004dd0:	7442                	ld	s0,48(sp)
    80004dd2:	74a2                	ld	s1,40(sp)
    80004dd4:	6121                	addi	sp,sp,64
    80004dd6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004dd8:	85d6                	mv	a1,s5
    80004dda:	8552                	mv	a0,s4
    80004ddc:	00000097          	auipc	ra,0x0
    80004de0:	3ac080e7          	jalr	940(ra) # 80005188 <pipeclose>
    80004de4:	7902                	ld	s2,32(sp)
    80004de6:	69e2                	ld	s3,24(sp)
    80004de8:	6a42                	ld	s4,16(sp)
    80004dea:	6aa2                	ld	s5,8(sp)
    80004dec:	b7cd                	j	80004dce <fileclose+0x9a>
    begin_op();
    80004dee:	00000097          	auipc	ra,0x0
    80004df2:	a76080e7          	jalr	-1418(ra) # 80004864 <begin_op>
    iput(ff.ip);
    80004df6:	854e                	mv	a0,s3
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	240080e7          	jalr	576(ra) # 80004038 <iput>
    end_op();
    80004e00:	00000097          	auipc	ra,0x0
    80004e04:	ade080e7          	jalr	-1314(ra) # 800048de <end_op>
    80004e08:	7902                	ld	s2,32(sp)
    80004e0a:	69e2                	ld	s3,24(sp)
    80004e0c:	6a42                	ld	s4,16(sp)
    80004e0e:	6aa2                	ld	s5,8(sp)
    80004e10:	bf7d                	j	80004dce <fileclose+0x9a>

0000000080004e12 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e12:	715d                	addi	sp,sp,-80
    80004e14:	e486                	sd	ra,72(sp)
    80004e16:	e0a2                	sd	s0,64(sp)
    80004e18:	fc26                	sd	s1,56(sp)
    80004e1a:	f44e                	sd	s3,40(sp)
    80004e1c:	0880                	addi	s0,sp,80
    80004e1e:	84aa                	mv	s1,a0
    80004e20:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	c46080e7          	jalr	-954(ra) # 80001a68 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e2a:	409c                	lw	a5,0(s1)
    80004e2c:	37f9                	addiw	a5,a5,-2
    80004e2e:	4705                	li	a4,1
    80004e30:	04f76a63          	bltu	a4,a5,80004e84 <filestat+0x72>
    80004e34:	f84a                	sd	s2,48(sp)
    80004e36:	f052                	sd	s4,32(sp)
    80004e38:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e3a:	6c88                	ld	a0,24(s1)
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	03e080e7          	jalr	62(ra) # 80003e7a <ilock>
    stati(f->ip, &st);
    80004e44:	fb840a13          	addi	s4,s0,-72
    80004e48:	85d2                	mv	a1,s4
    80004e4a:	6c88                	ld	a0,24(s1)
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	2bc080e7          	jalr	700(ra) # 80004108 <stati>
    iunlock(f->ip);
    80004e54:	6c88                	ld	a0,24(s1)
    80004e56:	fffff097          	auipc	ra,0xfffff
    80004e5a:	0ea080e7          	jalr	234(ra) # 80003f40 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e5e:	46e1                	li	a3,24
    80004e60:	8652                	mv	a2,s4
    80004e62:	85ce                	mv	a1,s3
    80004e64:	05093503          	ld	a0,80(s2)
    80004e68:	ffffd097          	auipc	ra,0xffffd
    80004e6c:	8a8080e7          	jalr	-1880(ra) # 80001710 <copyout>
    80004e70:	41f5551b          	sraiw	a0,a0,0x1f
    80004e74:	7942                	ld	s2,48(sp)
    80004e76:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004e78:	60a6                	ld	ra,72(sp)
    80004e7a:	6406                	ld	s0,64(sp)
    80004e7c:	74e2                	ld	s1,56(sp)
    80004e7e:	79a2                	ld	s3,40(sp)
    80004e80:	6161                	addi	sp,sp,80
    80004e82:	8082                	ret
  return -1;
    80004e84:	557d                	li	a0,-1
    80004e86:	bfcd                	j	80004e78 <filestat+0x66>

0000000080004e88 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e88:	7179                	addi	sp,sp,-48
    80004e8a:	f406                	sd	ra,40(sp)
    80004e8c:	f022                	sd	s0,32(sp)
    80004e8e:	e84a                	sd	s2,16(sp)
    80004e90:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e92:	00854783          	lbu	a5,8(a0)
    80004e96:	cbc5                	beqz	a5,80004f46 <fileread+0xbe>
    80004e98:	ec26                	sd	s1,24(sp)
    80004e9a:	e44e                	sd	s3,8(sp)
    80004e9c:	84aa                	mv	s1,a0
    80004e9e:	89ae                	mv	s3,a1
    80004ea0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ea2:	411c                	lw	a5,0(a0)
    80004ea4:	4705                	li	a4,1
    80004ea6:	04e78963          	beq	a5,a4,80004ef8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004eaa:	470d                	li	a4,3
    80004eac:	04e78f63          	beq	a5,a4,80004f0a <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004eb0:	4709                	li	a4,2
    80004eb2:	08e79263          	bne	a5,a4,80004f36 <fileread+0xae>
    ilock(f->ip);
    80004eb6:	6d08                	ld	a0,24(a0)
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	fc2080e7          	jalr	-62(ra) # 80003e7a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ec0:	874a                	mv	a4,s2
    80004ec2:	5094                	lw	a3,32(s1)
    80004ec4:	864e                	mv	a2,s3
    80004ec6:	4585                	li	a1,1
    80004ec8:	6c88                	ld	a0,24(s1)
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	26c080e7          	jalr	620(ra) # 80004136 <readi>
    80004ed2:	892a                	mv	s2,a0
    80004ed4:	00a05563          	blez	a0,80004ede <fileread+0x56>
      f->off += r;
    80004ed8:	509c                	lw	a5,32(s1)
    80004eda:	9fa9                	addw	a5,a5,a0
    80004edc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ede:	6c88                	ld	a0,24(s1)
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	060080e7          	jalr	96(ra) # 80003f40 <iunlock>
    80004ee8:	64e2                	ld	s1,24(sp)
    80004eea:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004eec:	854a                	mv	a0,s2
    80004eee:	70a2                	ld	ra,40(sp)
    80004ef0:	7402                	ld	s0,32(sp)
    80004ef2:	6942                	ld	s2,16(sp)
    80004ef4:	6145                	addi	sp,sp,48
    80004ef6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ef8:	6908                	ld	a0,16(a0)
    80004efa:	00000097          	auipc	ra,0x0
    80004efe:	41a080e7          	jalr	1050(ra) # 80005314 <piperead>
    80004f02:	892a                	mv	s2,a0
    80004f04:	64e2                	ld	s1,24(sp)
    80004f06:	69a2                	ld	s3,8(sp)
    80004f08:	b7d5                	j	80004eec <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f0a:	02451783          	lh	a5,36(a0)
    80004f0e:	03079693          	slli	a3,a5,0x30
    80004f12:	92c1                	srli	a3,a3,0x30
    80004f14:	4725                	li	a4,9
    80004f16:	02d76a63          	bltu	a4,a3,80004f4a <fileread+0xc2>
    80004f1a:	0792                	slli	a5,a5,0x4
    80004f1c:	0001f717          	auipc	a4,0x1f
    80004f20:	0bc70713          	addi	a4,a4,188 # 80023fd8 <devsw>
    80004f24:	97ba                	add	a5,a5,a4
    80004f26:	639c                	ld	a5,0(a5)
    80004f28:	c78d                	beqz	a5,80004f52 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004f2a:	4505                	li	a0,1
    80004f2c:	9782                	jalr	a5
    80004f2e:	892a                	mv	s2,a0
    80004f30:	64e2                	ld	s1,24(sp)
    80004f32:	69a2                	ld	s3,8(sp)
    80004f34:	bf65                	j	80004eec <fileread+0x64>
    panic("fileread");
    80004f36:	00003517          	auipc	a0,0x3
    80004f3a:	65a50513          	addi	a0,a0,1626 # 80008590 <etext+0x590>
    80004f3e:	ffffb097          	auipc	ra,0xffffb
    80004f42:	622080e7          	jalr	1570(ra) # 80000560 <panic>
    return -1;
    80004f46:	597d                	li	s2,-1
    80004f48:	b755                	j	80004eec <fileread+0x64>
      return -1;
    80004f4a:	597d                	li	s2,-1
    80004f4c:	64e2                	ld	s1,24(sp)
    80004f4e:	69a2                	ld	s3,8(sp)
    80004f50:	bf71                	j	80004eec <fileread+0x64>
    80004f52:	597d                	li	s2,-1
    80004f54:	64e2                	ld	s1,24(sp)
    80004f56:	69a2                	ld	s3,8(sp)
    80004f58:	bf51                	j	80004eec <fileread+0x64>

0000000080004f5a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004f5a:	00954783          	lbu	a5,9(a0)
    80004f5e:	12078c63          	beqz	a5,80005096 <filewrite+0x13c>
{
    80004f62:	711d                	addi	sp,sp,-96
    80004f64:	ec86                	sd	ra,88(sp)
    80004f66:	e8a2                	sd	s0,80(sp)
    80004f68:	e0ca                	sd	s2,64(sp)
    80004f6a:	f456                	sd	s5,40(sp)
    80004f6c:	f05a                	sd	s6,32(sp)
    80004f6e:	1080                	addi	s0,sp,96
    80004f70:	892a                	mv	s2,a0
    80004f72:	8b2e                	mv	s6,a1
    80004f74:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f76:	411c                	lw	a5,0(a0)
    80004f78:	4705                	li	a4,1
    80004f7a:	02e78963          	beq	a5,a4,80004fac <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f7e:	470d                	li	a4,3
    80004f80:	02e78c63          	beq	a5,a4,80004fb8 <filewrite+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f84:	4709                	li	a4,2
    80004f86:	0ee79a63          	bne	a5,a4,8000507a <filewrite+0x120>
    80004f8a:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f8c:	0cc05563          	blez	a2,80005056 <filewrite+0xfc>
    80004f90:	e4a6                	sd	s1,72(sp)
    80004f92:	fc4e                	sd	s3,56(sp)
    80004f94:	ec5e                	sd	s7,24(sp)
    80004f96:	e862                	sd	s8,16(sp)
    80004f98:	e466                	sd	s9,8(sp)
    int i = 0;
    80004f9a:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004f9c:	6b85                	lui	s7,0x1
    80004f9e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004fa2:	6c85                	lui	s9,0x1
    80004fa4:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fa8:	4c05                	li	s8,1
    80004faa:	a849                	j	8000503c <filewrite+0xe2>
    ret = pipewrite(f->pipe, addr, n);
    80004fac:	6908                	ld	a0,16(a0)
    80004fae:	00000097          	auipc	ra,0x0
    80004fb2:	24a080e7          	jalr	586(ra) # 800051f8 <pipewrite>
    80004fb6:	a85d                	j	8000506c <filewrite+0x112>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004fb8:	02451783          	lh	a5,36(a0)
    80004fbc:	03079693          	slli	a3,a5,0x30
    80004fc0:	92c1                	srli	a3,a3,0x30
    80004fc2:	4725                	li	a4,9
    80004fc4:	0cd76b63          	bltu	a4,a3,8000509a <filewrite+0x140>
    80004fc8:	0792                	slli	a5,a5,0x4
    80004fca:	0001f717          	auipc	a4,0x1f
    80004fce:	00e70713          	addi	a4,a4,14 # 80023fd8 <devsw>
    80004fd2:	97ba                	add	a5,a5,a4
    80004fd4:	679c                	ld	a5,8(a5)
    80004fd6:	c7e1                	beqz	a5,8000509e <filewrite+0x144>
    ret = devsw[f->major].write(1, addr, n);
    80004fd8:	4505                	li	a0,1
    80004fda:	9782                	jalr	a5
    80004fdc:	a841                	j	8000506c <filewrite+0x112>
      if(n1 > max)
    80004fde:	2981                	sext.w	s3,s3
      begin_op();
    80004fe0:	00000097          	auipc	ra,0x0
    80004fe4:	884080e7          	jalr	-1916(ra) # 80004864 <begin_op>
      ilock(f->ip);
    80004fe8:	01893503          	ld	a0,24(s2)
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	e8e080e7          	jalr	-370(ra) # 80003e7a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ff4:	874e                	mv	a4,s3
    80004ff6:	02092683          	lw	a3,32(s2)
    80004ffa:	016a0633          	add	a2,s4,s6
    80004ffe:	85e2                	mv	a1,s8
    80005000:	01893503          	ld	a0,24(s2)
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	238080e7          	jalr	568(ra) # 8000423c <writei>
    8000500c:	84aa                	mv	s1,a0
    8000500e:	00a05763          	blez	a0,8000501c <filewrite+0xc2>
        f->off += r;
    80005012:	02092783          	lw	a5,32(s2)
    80005016:	9fa9                	addw	a5,a5,a0
    80005018:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000501c:	01893503          	ld	a0,24(s2)
    80005020:	fffff097          	auipc	ra,0xfffff
    80005024:	f20080e7          	jalr	-224(ra) # 80003f40 <iunlock>
      end_op();
    80005028:	00000097          	auipc	ra,0x0
    8000502c:	8b6080e7          	jalr	-1866(ra) # 800048de <end_op>

      if(r != n1){
    80005030:	02999563          	bne	s3,s1,8000505a <filewrite+0x100>
        // error from writei
        break;
      }
      i += r;
    80005034:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80005038:	015a5963          	bge	s4,s5,8000504a <filewrite+0xf0>
      int n1 = n - i;
    8000503c:	414a87bb          	subw	a5,s5,s4
    80005040:	89be                	mv	s3,a5
      if(n1 > max)
    80005042:	f8fbdee3          	bge	s7,a5,80004fde <filewrite+0x84>
    80005046:	89e6                	mv	s3,s9
    80005048:	bf59                	j	80004fde <filewrite+0x84>
    8000504a:	64a6                	ld	s1,72(sp)
    8000504c:	79e2                	ld	s3,56(sp)
    8000504e:	6be2                	ld	s7,24(sp)
    80005050:	6c42                	ld	s8,16(sp)
    80005052:	6ca2                	ld	s9,8(sp)
    80005054:	a801                	j	80005064 <filewrite+0x10a>
    int i = 0;
    80005056:	4a01                	li	s4,0
    80005058:	a031                	j	80005064 <filewrite+0x10a>
    8000505a:	64a6                	ld	s1,72(sp)
    8000505c:	79e2                	ld	s3,56(sp)
    8000505e:	6be2                	ld	s7,24(sp)
    80005060:	6c42                	ld	s8,16(sp)
    80005062:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80005064:	034a9f63          	bne	s5,s4,800050a2 <filewrite+0x148>
    80005068:	8556                	mv	a0,s5
    8000506a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000506c:	60e6                	ld	ra,88(sp)
    8000506e:	6446                	ld	s0,80(sp)
    80005070:	6906                	ld	s2,64(sp)
    80005072:	7aa2                	ld	s5,40(sp)
    80005074:	7b02                	ld	s6,32(sp)
    80005076:	6125                	addi	sp,sp,96
    80005078:	8082                	ret
    8000507a:	e4a6                	sd	s1,72(sp)
    8000507c:	fc4e                	sd	s3,56(sp)
    8000507e:	f852                	sd	s4,48(sp)
    80005080:	ec5e                	sd	s7,24(sp)
    80005082:	e862                	sd	s8,16(sp)
    80005084:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80005086:	00003517          	auipc	a0,0x3
    8000508a:	51a50513          	addi	a0,a0,1306 # 800085a0 <etext+0x5a0>
    8000508e:	ffffb097          	auipc	ra,0xffffb
    80005092:	4d2080e7          	jalr	1234(ra) # 80000560 <panic>
    return -1;
    80005096:	557d                	li	a0,-1
}
    80005098:	8082                	ret
      return -1;
    8000509a:	557d                	li	a0,-1
    8000509c:	bfc1                	j	8000506c <filewrite+0x112>
    8000509e:	557d                	li	a0,-1
    800050a0:	b7f1                	j	8000506c <filewrite+0x112>
    ret = (i == n ? n : -1);
    800050a2:	557d                	li	a0,-1
    800050a4:	7a42                	ld	s4,48(sp)
    800050a6:	b7d9                	j	8000506c <filewrite+0x112>

00000000800050a8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800050a8:	7179                	addi	sp,sp,-48
    800050aa:	f406                	sd	ra,40(sp)
    800050ac:	f022                	sd	s0,32(sp)
    800050ae:	ec26                	sd	s1,24(sp)
    800050b0:	e052                	sd	s4,0(sp)
    800050b2:	1800                	addi	s0,sp,48
    800050b4:	84aa                	mv	s1,a0
    800050b6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800050b8:	0005b023          	sd	zero,0(a1)
    800050bc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800050c0:	00000097          	auipc	ra,0x0
    800050c4:	bb8080e7          	jalr	-1096(ra) # 80004c78 <filealloc>
    800050c8:	e088                	sd	a0,0(s1)
    800050ca:	cd49                	beqz	a0,80005164 <pipealloc+0xbc>
    800050cc:	00000097          	auipc	ra,0x0
    800050d0:	bac080e7          	jalr	-1108(ra) # 80004c78 <filealloc>
    800050d4:	00aa3023          	sd	a0,0(s4)
    800050d8:	c141                	beqz	a0,80005158 <pipealloc+0xb0>
    800050da:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	a6e080e7          	jalr	-1426(ra) # 80000b4a <kalloc>
    800050e4:	892a                	mv	s2,a0
    800050e6:	c13d                	beqz	a0,8000514c <pipealloc+0xa4>
    800050e8:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800050ea:	4985                	li	s3,1
    800050ec:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050f0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050f4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050f8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050fc:	00003597          	auipc	a1,0x3
    80005100:	4b458593          	addi	a1,a1,1204 # 800085b0 <etext+0x5b0>
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	aa6080e7          	jalr	-1370(ra) # 80000baa <initlock>
  (*f0)->type = FD_PIPE;
    8000510c:	609c                	ld	a5,0(s1)
    8000510e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005112:	609c                	ld	a5,0(s1)
    80005114:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005118:	609c                	ld	a5,0(s1)
    8000511a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000511e:	609c                	ld	a5,0(s1)
    80005120:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005124:	000a3783          	ld	a5,0(s4)
    80005128:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000512c:	000a3783          	ld	a5,0(s4)
    80005130:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005134:	000a3783          	ld	a5,0(s4)
    80005138:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000513c:	000a3783          	ld	a5,0(s4)
    80005140:	0127b823          	sd	s2,16(a5)
  return 0;
    80005144:	4501                	li	a0,0
    80005146:	6942                	ld	s2,16(sp)
    80005148:	69a2                	ld	s3,8(sp)
    8000514a:	a03d                	j	80005178 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000514c:	6088                	ld	a0,0(s1)
    8000514e:	c119                	beqz	a0,80005154 <pipealloc+0xac>
    80005150:	6942                	ld	s2,16(sp)
    80005152:	a029                	j	8000515c <pipealloc+0xb4>
    80005154:	6942                	ld	s2,16(sp)
    80005156:	a039                	j	80005164 <pipealloc+0xbc>
    80005158:	6088                	ld	a0,0(s1)
    8000515a:	c50d                	beqz	a0,80005184 <pipealloc+0xdc>
    fileclose(*f0);
    8000515c:	00000097          	auipc	ra,0x0
    80005160:	bd8080e7          	jalr	-1064(ra) # 80004d34 <fileclose>
  if(*f1)
    80005164:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005168:	557d                	li	a0,-1
  if(*f1)
    8000516a:	c799                	beqz	a5,80005178 <pipealloc+0xd0>
    fileclose(*f1);
    8000516c:	853e                	mv	a0,a5
    8000516e:	00000097          	auipc	ra,0x0
    80005172:	bc6080e7          	jalr	-1082(ra) # 80004d34 <fileclose>
  return -1;
    80005176:	557d                	li	a0,-1
}
    80005178:	70a2                	ld	ra,40(sp)
    8000517a:	7402                	ld	s0,32(sp)
    8000517c:	64e2                	ld	s1,24(sp)
    8000517e:	6a02                	ld	s4,0(sp)
    80005180:	6145                	addi	sp,sp,48
    80005182:	8082                	ret
  return -1;
    80005184:	557d                	li	a0,-1
    80005186:	bfcd                	j	80005178 <pipealloc+0xd0>

0000000080005188 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005188:	1101                	addi	sp,sp,-32
    8000518a:	ec06                	sd	ra,24(sp)
    8000518c:	e822                	sd	s0,16(sp)
    8000518e:	e426                	sd	s1,8(sp)
    80005190:	e04a                	sd	s2,0(sp)
    80005192:	1000                	addi	s0,sp,32
    80005194:	84aa                	mv	s1,a0
    80005196:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	aa6080e7          	jalr	-1370(ra) # 80000c3e <acquire>
  if(writable){
    800051a0:	02090d63          	beqz	s2,800051da <pipeclose+0x52>
    pi->writeopen = 0;
    800051a4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800051a8:	21848513          	addi	a0,s1,536
    800051ac:	ffffd097          	auipc	ra,0xffffd
    800051b0:	340080e7          	jalr	832(ra) # 800024ec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800051b4:	2204b783          	ld	a5,544(s1)
    800051b8:	eb95                	bnez	a5,800051ec <pipeclose+0x64>
    release(&pi->lock);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	b32080e7          	jalr	-1230(ra) # 80000cee <release>
    kfree((char*)pi);
    800051c4:	8526                	mv	a0,s1
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	886080e7          	jalr	-1914(ra) # 80000a4c <kfree>
  } else
    release(&pi->lock);
}
    800051ce:	60e2                	ld	ra,24(sp)
    800051d0:	6442                	ld	s0,16(sp)
    800051d2:	64a2                	ld	s1,8(sp)
    800051d4:	6902                	ld	s2,0(sp)
    800051d6:	6105                	addi	sp,sp,32
    800051d8:	8082                	ret
    pi->readopen = 0;
    800051da:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800051de:	21c48513          	addi	a0,s1,540
    800051e2:	ffffd097          	auipc	ra,0xffffd
    800051e6:	30a080e7          	jalr	778(ra) # 800024ec <wakeup>
    800051ea:	b7e9                	j	800051b4 <pipeclose+0x2c>
    release(&pi->lock);
    800051ec:	8526                	mv	a0,s1
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	b00080e7          	jalr	-1280(ra) # 80000cee <release>
}
    800051f6:	bfe1                	j	800051ce <pipeclose+0x46>

00000000800051f8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051f8:	7159                	addi	sp,sp,-112
    800051fa:	f486                	sd	ra,104(sp)
    800051fc:	f0a2                	sd	s0,96(sp)
    800051fe:	eca6                	sd	s1,88(sp)
    80005200:	e8ca                	sd	s2,80(sp)
    80005202:	e4ce                	sd	s3,72(sp)
    80005204:	e0d2                	sd	s4,64(sp)
    80005206:	fc56                	sd	s5,56(sp)
    80005208:	1880                	addi	s0,sp,112
    8000520a:	84aa                	mv	s1,a0
    8000520c:	8aae                	mv	s5,a1
    8000520e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	858080e7          	jalr	-1960(ra) # 80001a68 <myproc>
    80005218:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000521a:	8526                	mv	a0,s1
    8000521c:	ffffc097          	auipc	ra,0xffffc
    80005220:	a22080e7          	jalr	-1502(ra) # 80000c3e <acquire>
  while(i < n){
    80005224:	0f405063          	blez	s4,80005304 <pipewrite+0x10c>
    80005228:	f85a                	sd	s6,48(sp)
    8000522a:	f45e                	sd	s7,40(sp)
    8000522c:	f062                	sd	s8,32(sp)
    8000522e:	ec66                	sd	s9,24(sp)
    80005230:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005232:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005234:	f9f40c13          	addi	s8,s0,-97
    80005238:	4b85                	li	s7,1
    8000523a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000523c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005240:	21c48c93          	addi	s9,s1,540
    80005244:	a099                	j	8000528a <pipewrite+0x92>
      release(&pi->lock);
    80005246:	8526                	mv	a0,s1
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	aa6080e7          	jalr	-1370(ra) # 80000cee <release>
      return -1;
    80005250:	597d                	li	s2,-1
    80005252:	7b42                	ld	s6,48(sp)
    80005254:	7ba2                	ld	s7,40(sp)
    80005256:	7c02                	ld	s8,32(sp)
    80005258:	6ce2                	ld	s9,24(sp)
    8000525a:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000525c:	854a                	mv	a0,s2
    8000525e:	70a6                	ld	ra,104(sp)
    80005260:	7406                	ld	s0,96(sp)
    80005262:	64e6                	ld	s1,88(sp)
    80005264:	6946                	ld	s2,80(sp)
    80005266:	69a6                	ld	s3,72(sp)
    80005268:	6a06                	ld	s4,64(sp)
    8000526a:	7ae2                	ld	s5,56(sp)
    8000526c:	6165                	addi	sp,sp,112
    8000526e:	8082                	ret
      wakeup(&pi->nread);
    80005270:	856a                	mv	a0,s10
    80005272:	ffffd097          	auipc	ra,0xffffd
    80005276:	27a080e7          	jalr	634(ra) # 800024ec <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000527a:	85a6                	mv	a1,s1
    8000527c:	8566                	mv	a0,s9
    8000527e:	ffffd097          	auipc	ra,0xffffd
    80005282:	20a080e7          	jalr	522(ra) # 80002488 <sleep>
  while(i < n){
    80005286:	05495e63          	bge	s2,s4,800052e2 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    8000528a:	2204a783          	lw	a5,544(s1)
    8000528e:	dfc5                	beqz	a5,80005246 <pipewrite+0x4e>
    80005290:	854e                	mv	a0,s3
    80005292:	ffffd097          	auipc	ra,0xffffd
    80005296:	4aa080e7          	jalr	1194(ra) # 8000273c <killed>
    8000529a:	f555                	bnez	a0,80005246 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000529c:	2184a783          	lw	a5,536(s1)
    800052a0:	21c4a703          	lw	a4,540(s1)
    800052a4:	2007879b          	addiw	a5,a5,512
    800052a8:	fcf704e3          	beq	a4,a5,80005270 <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052ac:	86de                	mv	a3,s7
    800052ae:	01590633          	add	a2,s2,s5
    800052b2:	85e2                	mv	a1,s8
    800052b4:	0509b503          	ld	a0,80(s3)
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	4e4080e7          	jalr	1252(ra) # 8000179c <copyin>
    800052c0:	05650463          	beq	a0,s6,80005308 <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800052c4:	21c4a783          	lw	a5,540(s1)
    800052c8:	0017871b          	addiw	a4,a5,1
    800052cc:	20e4ae23          	sw	a4,540(s1)
    800052d0:	1ff7f793          	andi	a5,a5,511
    800052d4:	97a6                	add	a5,a5,s1
    800052d6:	f9f44703          	lbu	a4,-97(s0)
    800052da:	00e78c23          	sb	a4,24(a5)
      i++;
    800052de:	2905                	addiw	s2,s2,1
    800052e0:	b75d                	j	80005286 <pipewrite+0x8e>
    800052e2:	7b42                	ld	s6,48(sp)
    800052e4:	7ba2                	ld	s7,40(sp)
    800052e6:	7c02                	ld	s8,32(sp)
    800052e8:	6ce2                	ld	s9,24(sp)
    800052ea:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800052ec:	21848513          	addi	a0,s1,536
    800052f0:	ffffd097          	auipc	ra,0xffffd
    800052f4:	1fc080e7          	jalr	508(ra) # 800024ec <wakeup>
  release(&pi->lock);
    800052f8:	8526                	mv	a0,s1
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	9f4080e7          	jalr	-1548(ra) # 80000cee <release>
  return i;
    80005302:	bfa9                	j	8000525c <pipewrite+0x64>
  int i = 0;
    80005304:	4901                	li	s2,0
    80005306:	b7dd                	j	800052ec <pipewrite+0xf4>
    80005308:	7b42                	ld	s6,48(sp)
    8000530a:	7ba2                	ld	s7,40(sp)
    8000530c:	7c02                	ld	s8,32(sp)
    8000530e:	6ce2                	ld	s9,24(sp)
    80005310:	6d42                	ld	s10,16(sp)
    80005312:	bfe9                	j	800052ec <pipewrite+0xf4>

0000000080005314 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005314:	711d                	addi	sp,sp,-96
    80005316:	ec86                	sd	ra,88(sp)
    80005318:	e8a2                	sd	s0,80(sp)
    8000531a:	e4a6                	sd	s1,72(sp)
    8000531c:	e0ca                	sd	s2,64(sp)
    8000531e:	fc4e                	sd	s3,56(sp)
    80005320:	f852                	sd	s4,48(sp)
    80005322:	f456                	sd	s5,40(sp)
    80005324:	1080                	addi	s0,sp,96
    80005326:	84aa                	mv	s1,a0
    80005328:	892e                	mv	s2,a1
    8000532a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	73c080e7          	jalr	1852(ra) # 80001a68 <myproc>
    80005334:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005336:	8526                	mv	a0,s1
    80005338:	ffffc097          	auipc	ra,0xffffc
    8000533c:	906080e7          	jalr	-1786(ra) # 80000c3e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005340:	2184a703          	lw	a4,536(s1)
    80005344:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005348:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000534c:	02f71b63          	bne	a4,a5,80005382 <piperead+0x6e>
    80005350:	2244a783          	lw	a5,548(s1)
    80005354:	c3b1                	beqz	a5,80005398 <piperead+0x84>
    if(killed(pr)){
    80005356:	8552                	mv	a0,s4
    80005358:	ffffd097          	auipc	ra,0xffffd
    8000535c:	3e4080e7          	jalr	996(ra) # 8000273c <killed>
    80005360:	e50d                	bnez	a0,8000538a <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005362:	85a6                	mv	a1,s1
    80005364:	854e                	mv	a0,s3
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	122080e7          	jalr	290(ra) # 80002488 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000536e:	2184a703          	lw	a4,536(s1)
    80005372:	21c4a783          	lw	a5,540(s1)
    80005376:	fcf70de3          	beq	a4,a5,80005350 <piperead+0x3c>
    8000537a:	f05a                	sd	s6,32(sp)
    8000537c:	ec5e                	sd	s7,24(sp)
    8000537e:	e862                	sd	s8,16(sp)
    80005380:	a839                	j	8000539e <piperead+0x8a>
    80005382:	f05a                	sd	s6,32(sp)
    80005384:	ec5e                	sd	s7,24(sp)
    80005386:	e862                	sd	s8,16(sp)
    80005388:	a819                	j	8000539e <piperead+0x8a>
      release(&pi->lock);
    8000538a:	8526                	mv	a0,s1
    8000538c:	ffffc097          	auipc	ra,0xffffc
    80005390:	962080e7          	jalr	-1694(ra) # 80000cee <release>
      return -1;
    80005394:	59fd                	li	s3,-1
    80005396:	a895                	j	8000540a <piperead+0xf6>
    80005398:	f05a                	sd	s6,32(sp)
    8000539a:	ec5e                	sd	s7,24(sp)
    8000539c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000539e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053a0:	faf40c13          	addi	s8,s0,-81
    800053a4:	4b85                	li	s7,1
    800053a6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053a8:	05505363          	blez	s5,800053ee <piperead+0xda>
    if(pi->nread == pi->nwrite)
    800053ac:	2184a783          	lw	a5,536(s1)
    800053b0:	21c4a703          	lw	a4,540(s1)
    800053b4:	02f70d63          	beq	a4,a5,800053ee <piperead+0xda>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053b8:	0017871b          	addiw	a4,a5,1
    800053bc:	20e4ac23          	sw	a4,536(s1)
    800053c0:	1ff7f793          	andi	a5,a5,511
    800053c4:	97a6                	add	a5,a5,s1
    800053c6:	0187c783          	lbu	a5,24(a5)
    800053ca:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053ce:	86de                	mv	a3,s7
    800053d0:	8662                	mv	a2,s8
    800053d2:	85ca                	mv	a1,s2
    800053d4:	050a3503          	ld	a0,80(s4)
    800053d8:	ffffc097          	auipc	ra,0xffffc
    800053dc:	338080e7          	jalr	824(ra) # 80001710 <copyout>
    800053e0:	01650763          	beq	a0,s6,800053ee <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053e4:	2985                	addiw	s3,s3,1
    800053e6:	0905                	addi	s2,s2,1
    800053e8:	fd3a92e3          	bne	s5,s3,800053ac <piperead+0x98>
    800053ec:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800053ee:	21c48513          	addi	a0,s1,540
    800053f2:	ffffd097          	auipc	ra,0xffffd
    800053f6:	0fa080e7          	jalr	250(ra) # 800024ec <wakeup>
  release(&pi->lock);
    800053fa:	8526                	mv	a0,s1
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	8f2080e7          	jalr	-1806(ra) # 80000cee <release>
    80005404:	7b02                	ld	s6,32(sp)
    80005406:	6be2                	ld	s7,24(sp)
    80005408:	6c42                	ld	s8,16(sp)
  return i;
}
    8000540a:	854e                	mv	a0,s3
    8000540c:	60e6                	ld	ra,88(sp)
    8000540e:	6446                	ld	s0,80(sp)
    80005410:	64a6                	ld	s1,72(sp)
    80005412:	6906                	ld	s2,64(sp)
    80005414:	79e2                	ld	s3,56(sp)
    80005416:	7a42                	ld	s4,48(sp)
    80005418:	7aa2                	ld	s5,40(sp)
    8000541a:	6125                	addi	sp,sp,96
    8000541c:	8082                	ret

000000008000541e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000541e:	1141                	addi	sp,sp,-16
    80005420:	e406                	sd	ra,8(sp)
    80005422:	e022                	sd	s0,0(sp)
    80005424:	0800                	addi	s0,sp,16
    80005426:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005428:	0035151b          	slliw	a0,a0,0x3
    8000542c:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    8000542e:	8b89                	andi	a5,a5,2
    80005430:	c399                	beqz	a5,80005436 <flags2perm+0x18>
      perm |= PTE_W;
    80005432:	00456513          	ori	a0,a0,4
    return perm;
}
    80005436:	60a2                	ld	ra,8(sp)
    80005438:	6402                	ld	s0,0(sp)
    8000543a:	0141                	addi	sp,sp,16
    8000543c:	8082                	ret

000000008000543e <exec>:

int
exec(char *path, char **argv)
{
    8000543e:	de010113          	addi	sp,sp,-544
    80005442:	20113c23          	sd	ra,536(sp)
    80005446:	20813823          	sd	s0,528(sp)
    8000544a:	20913423          	sd	s1,520(sp)
    8000544e:	21213023          	sd	s2,512(sp)
    80005452:	1400                	addi	s0,sp,544
    80005454:	892a                	mv	s2,a0
    80005456:	dea43823          	sd	a0,-528(s0)
    8000545a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	60a080e7          	jalr	1546(ra) # 80001a68 <myproc>
    80005466:	84aa                	mv	s1,a0

  begin_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	3fc080e7          	jalr	1020(ra) # 80004864 <begin_op>

  if((ip = namei(path)) == 0){
    80005470:	854a                	mv	a0,s2
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	1ec080e7          	jalr	492(ra) # 8000465e <namei>
    8000547a:	c525                	beqz	a0,800054e2 <exec+0xa4>
    8000547c:	fbd2                	sd	s4,496(sp)
    8000547e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	9fa080e7          	jalr	-1542(ra) # 80003e7a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005488:	04000713          	li	a4,64
    8000548c:	4681                	li	a3,0
    8000548e:	e5040613          	addi	a2,s0,-432
    80005492:	4581                	li	a1,0
    80005494:	8552                	mv	a0,s4
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	ca0080e7          	jalr	-864(ra) # 80004136 <readi>
    8000549e:	04000793          	li	a5,64
    800054a2:	00f51a63          	bne	a0,a5,800054b6 <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800054a6:	e5042703          	lw	a4,-432(s0)
    800054aa:	464c47b7          	lui	a5,0x464c4
    800054ae:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054b2:	02f70e63          	beq	a4,a5,800054ee <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054b6:	8552                	mv	a0,s4
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	c28080e7          	jalr	-984(ra) # 800040e0 <iunlockput>
    end_op();
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	41e080e7          	jalr	1054(ra) # 800048de <end_op>
  }
  return -1;
    800054c8:	557d                	li	a0,-1
    800054ca:	7a5e                	ld	s4,496(sp)
}
    800054cc:	21813083          	ld	ra,536(sp)
    800054d0:	21013403          	ld	s0,528(sp)
    800054d4:	20813483          	ld	s1,520(sp)
    800054d8:	20013903          	ld	s2,512(sp)
    800054dc:	22010113          	addi	sp,sp,544
    800054e0:	8082                	ret
    end_op();
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	3fc080e7          	jalr	1020(ra) # 800048de <end_op>
    return -1;
    800054ea:	557d                	li	a0,-1
    800054ec:	b7c5                	j	800054cc <exec+0x8e>
    800054ee:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800054f0:	8526                	mv	a0,s1
    800054f2:	ffffc097          	auipc	ra,0xffffc
    800054f6:	63a080e7          	jalr	1594(ra) # 80001b2c <proc_pagetable>
    800054fa:	8b2a                	mv	s6,a0
    800054fc:	2c050163          	beqz	a0,800057be <exec+0x380>
    80005500:	ffce                	sd	s3,504(sp)
    80005502:	f7d6                	sd	s5,488(sp)
    80005504:	efde                	sd	s7,472(sp)
    80005506:	ebe2                	sd	s8,464(sp)
    80005508:	e7e6                	sd	s9,456(sp)
    8000550a:	e3ea                	sd	s10,448(sp)
    8000550c:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000550e:	e7042683          	lw	a3,-400(s0)
    80005512:	e8845783          	lhu	a5,-376(s0)
    80005516:	10078363          	beqz	a5,8000561c <exec+0x1de>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000551a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000551c:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000551e:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80005522:	6c85                	lui	s9,0x1
    80005524:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005528:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000552c:	6a85                	lui	s5,0x1
    8000552e:	a0b5                	j	8000559a <exec+0x15c>
      panic("loadseg: address should exist");
    80005530:	00003517          	auipc	a0,0x3
    80005534:	08850513          	addi	a0,a0,136 # 800085b8 <etext+0x5b8>
    80005538:	ffffb097          	auipc	ra,0xffffb
    8000553c:	028080e7          	jalr	40(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005540:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005542:	874a                	mv	a4,s2
    80005544:	009c06bb          	addw	a3,s8,s1
    80005548:	4581                	li	a1,0
    8000554a:	8552                	mv	a0,s4
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	bea080e7          	jalr	-1046(ra) # 80004136 <readi>
    80005554:	26a91963          	bne	s2,a0,800057c6 <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    80005558:	009a84bb          	addw	s1,s5,s1
    8000555c:	0334f463          	bgeu	s1,s3,80005584 <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80005560:	02049593          	slli	a1,s1,0x20
    80005564:	9181                	srli	a1,a1,0x20
    80005566:	95de                	add	a1,a1,s7
    80005568:	855a                	mv	a0,s6
    8000556a:	ffffc097          	auipc	ra,0xffffc
    8000556e:	b6e080e7          	jalr	-1170(ra) # 800010d8 <walkaddr>
    80005572:	862a                	mv	a2,a0
    if(pa == 0)
    80005574:	dd55                	beqz	a0,80005530 <exec+0xf2>
    if(sz - i < PGSIZE)
    80005576:	409987bb          	subw	a5,s3,s1
    8000557a:	893e                	mv	s2,a5
    8000557c:	fcfcf2e3          	bgeu	s9,a5,80005540 <exec+0x102>
    80005580:	8956                	mv	s2,s5
    80005582:	bf7d                	j	80005540 <exec+0x102>
    sz = sz1;
    80005584:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005588:	2d05                	addiw	s10,s10,1
    8000558a:	e0843783          	ld	a5,-504(s0)
    8000558e:	0387869b          	addiw	a3,a5,56
    80005592:	e8845783          	lhu	a5,-376(s0)
    80005596:	08fd5463          	bge	s10,a5,8000561e <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000559a:	e0d43423          	sd	a3,-504(s0)
    8000559e:	876e                	mv	a4,s11
    800055a0:	e1840613          	addi	a2,s0,-488
    800055a4:	4581                	li	a1,0
    800055a6:	8552                	mv	a0,s4
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	b8e080e7          	jalr	-1138(ra) # 80004136 <readi>
    800055b0:	21b51963          	bne	a0,s11,800057c2 <exec+0x384>
    if(ph.type != ELF_PROG_LOAD)
    800055b4:	e1842783          	lw	a5,-488(s0)
    800055b8:	4705                	li	a4,1
    800055ba:	fce797e3          	bne	a5,a4,80005588 <exec+0x14a>
    if(ph.memsz < ph.filesz)
    800055be:	e4043483          	ld	s1,-448(s0)
    800055c2:	e3843783          	ld	a5,-456(s0)
    800055c6:	22f4e063          	bltu	s1,a5,800057e6 <exec+0x3a8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055ca:	e2843783          	ld	a5,-472(s0)
    800055ce:	94be                	add	s1,s1,a5
    800055d0:	20f4ee63          	bltu	s1,a5,800057ec <exec+0x3ae>
    if(ph.vaddr % PGSIZE != 0)
    800055d4:	de843703          	ld	a4,-536(s0)
    800055d8:	8ff9                	and	a5,a5,a4
    800055da:	20079c63          	bnez	a5,800057f2 <exec+0x3b4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055de:	e1c42503          	lw	a0,-484(s0)
    800055e2:	00000097          	auipc	ra,0x0
    800055e6:	e3c080e7          	jalr	-452(ra) # 8000541e <flags2perm>
    800055ea:	86aa                	mv	a3,a0
    800055ec:	8626                	mv	a2,s1
    800055ee:	85ca                	mv	a1,s2
    800055f0:	855a                	mv	a0,s6
    800055f2:	ffffc097          	auipc	ra,0xffffc
    800055f6:	eaa080e7          	jalr	-342(ra) # 8000149c <uvmalloc>
    800055fa:	dea43c23          	sd	a0,-520(s0)
    800055fe:	1e050d63          	beqz	a0,800057f8 <exec+0x3ba>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005602:	e2843b83          	ld	s7,-472(s0)
    80005606:	e2042c03          	lw	s8,-480(s0)
    8000560a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000560e:	00098463          	beqz	s3,80005616 <exec+0x1d8>
    80005612:	4481                	li	s1,0
    80005614:	b7b1                	j	80005560 <exec+0x122>
    sz = sz1;
    80005616:	df843903          	ld	s2,-520(s0)
    8000561a:	b7bd                	j	80005588 <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000561c:	4901                	li	s2,0
  iunlockput(ip);
    8000561e:	8552                	mv	a0,s4
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	ac0080e7          	jalr	-1344(ra) # 800040e0 <iunlockput>
  end_op();
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	2b6080e7          	jalr	694(ra) # 800048de <end_op>
  p = myproc();
    80005630:	ffffc097          	auipc	ra,0xffffc
    80005634:	438080e7          	jalr	1080(ra) # 80001a68 <myproc>
    80005638:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000563a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000563e:	6985                	lui	s3,0x1
    80005640:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005642:	99ca                	add	s3,s3,s2
    80005644:	77fd                	lui	a5,0xfffff
    80005646:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000564a:	4691                	li	a3,4
    8000564c:	6609                	lui	a2,0x2
    8000564e:	964e                	add	a2,a2,s3
    80005650:	85ce                	mv	a1,s3
    80005652:	855a                	mv	a0,s6
    80005654:	ffffc097          	auipc	ra,0xffffc
    80005658:	e48080e7          	jalr	-440(ra) # 8000149c <uvmalloc>
    8000565c:	8a2a                	mv	s4,a0
    8000565e:	e115                	bnez	a0,80005682 <exec+0x244>
    proc_freepagetable(pagetable, sz);
    80005660:	85ce                	mv	a1,s3
    80005662:	855a                	mv	a0,s6
    80005664:	ffffc097          	auipc	ra,0xffffc
    80005668:	564080e7          	jalr	1380(ra) # 80001bc8 <proc_freepagetable>
  return -1;
    8000566c:	557d                	li	a0,-1
    8000566e:	79fe                	ld	s3,504(sp)
    80005670:	7a5e                	ld	s4,496(sp)
    80005672:	7abe                	ld	s5,488(sp)
    80005674:	7b1e                	ld	s6,480(sp)
    80005676:	6bfe                	ld	s7,472(sp)
    80005678:	6c5e                	ld	s8,464(sp)
    8000567a:	6cbe                	ld	s9,456(sp)
    8000567c:	6d1e                	ld	s10,448(sp)
    8000567e:	7dfa                	ld	s11,440(sp)
    80005680:	b5b1                	j	800054cc <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005682:	75f9                	lui	a1,0xffffe
    80005684:	95aa                	add	a1,a1,a0
    80005686:	855a                	mv	a0,s6
    80005688:	ffffc097          	auipc	ra,0xffffc
    8000568c:	056080e7          	jalr	86(ra) # 800016de <uvmclear>
  stackbase = sp - PGSIZE;
    80005690:	7bfd                	lui	s7,0xfffff
    80005692:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80005694:	e0043783          	ld	a5,-512(s0)
    80005698:	6388                	ld	a0,0(a5)
  sp = sz;
    8000569a:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000569c:	4481                	li	s1,0
    ustack[argc] = sp;
    8000569e:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800056a2:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800056a6:	c135                	beqz	a0,8000570a <exec+0x2cc>
    sp -= strlen(argv[argc]) + 1;
    800056a8:	ffffc097          	auipc	ra,0xffffc
    800056ac:	81a080e7          	jalr	-2022(ra) # 80000ec2 <strlen>
    800056b0:	0015079b          	addiw	a5,a0,1
    800056b4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800056b8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800056bc:	15796163          	bltu	s2,s7,800057fe <exec+0x3c0>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800056c0:	e0043d83          	ld	s11,-512(s0)
    800056c4:	000db983          	ld	s3,0(s11)
    800056c8:	854e                	mv	a0,s3
    800056ca:	ffffb097          	auipc	ra,0xffffb
    800056ce:	7f8080e7          	jalr	2040(ra) # 80000ec2 <strlen>
    800056d2:	0015069b          	addiw	a3,a0,1
    800056d6:	864e                	mv	a2,s3
    800056d8:	85ca                	mv	a1,s2
    800056da:	855a                	mv	a0,s6
    800056dc:	ffffc097          	auipc	ra,0xffffc
    800056e0:	034080e7          	jalr	52(ra) # 80001710 <copyout>
    800056e4:	10054f63          	bltz	a0,80005802 <exec+0x3c4>
    ustack[argc] = sp;
    800056e8:	00349793          	slli	a5,s1,0x3
    800056ec:	97e6                	add	a5,a5,s9
    800056ee:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9e90>
  for(argc = 0; argv[argc]; argc++) {
    800056f2:	0485                	addi	s1,s1,1
    800056f4:	008d8793          	addi	a5,s11,8
    800056f8:	e0f43023          	sd	a5,-512(s0)
    800056fc:	008db503          	ld	a0,8(s11)
    80005700:	c509                	beqz	a0,8000570a <exec+0x2cc>
    if(argc >= MAXARG)
    80005702:	fb8493e3          	bne	s1,s8,800056a8 <exec+0x26a>
  sz = sz1;
    80005706:	89d2                	mv	s3,s4
    80005708:	bfa1                	j	80005660 <exec+0x222>
  ustack[argc] = 0;
    8000570a:	00349793          	slli	a5,s1,0x3
    8000570e:	f9078793          	addi	a5,a5,-112
    80005712:	97a2                	add	a5,a5,s0
    80005714:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005718:	00148693          	addi	a3,s1,1
    8000571c:	068e                	slli	a3,a3,0x3
    8000571e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005722:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005726:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005728:	f3796ce3          	bltu	s2,s7,80005660 <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000572c:	e9040613          	addi	a2,s0,-368
    80005730:	85ca                	mv	a1,s2
    80005732:	855a                	mv	a0,s6
    80005734:	ffffc097          	auipc	ra,0xffffc
    80005738:	fdc080e7          	jalr	-36(ra) # 80001710 <copyout>
    8000573c:	f20542e3          	bltz	a0,80005660 <exec+0x222>
  p->trapframe->a1 = sp;
    80005740:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005744:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005748:	df043783          	ld	a5,-528(s0)
    8000574c:	0007c703          	lbu	a4,0(a5)
    80005750:	cf11                	beqz	a4,8000576c <exec+0x32e>
    80005752:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005754:	02f00693          	li	a3,47
    80005758:	a029                	j	80005762 <exec+0x324>
  for(last=s=path; *s; s++)
    8000575a:	0785                	addi	a5,a5,1
    8000575c:	fff7c703          	lbu	a4,-1(a5)
    80005760:	c711                	beqz	a4,8000576c <exec+0x32e>
    if(*s == '/')
    80005762:	fed71ce3          	bne	a4,a3,8000575a <exec+0x31c>
      last = s+1;
    80005766:	def43823          	sd	a5,-528(s0)
    8000576a:	bfc5                	j	8000575a <exec+0x31c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000576c:	4641                	li	a2,16
    8000576e:	df043583          	ld	a1,-528(s0)
    80005772:	158a8513          	addi	a0,s5,344
    80005776:	ffffb097          	auipc	ra,0xffffb
    8000577a:	716080e7          	jalr	1814(ra) # 80000e8c <safestrcpy>
  oldpagetable = p->pagetable;
    8000577e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005782:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005786:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000578a:	058ab783          	ld	a5,88(s5)
    8000578e:	e6843703          	ld	a4,-408(s0)
    80005792:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005794:	058ab783          	ld	a5,88(s5)
    80005798:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000579c:	85ea                	mv	a1,s10
    8000579e:	ffffc097          	auipc	ra,0xffffc
    800057a2:	42a080e7          	jalr	1066(ra) # 80001bc8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800057a6:	0004851b          	sext.w	a0,s1
    800057aa:	79fe                	ld	s3,504(sp)
    800057ac:	7a5e                	ld	s4,496(sp)
    800057ae:	7abe                	ld	s5,488(sp)
    800057b0:	7b1e                	ld	s6,480(sp)
    800057b2:	6bfe                	ld	s7,472(sp)
    800057b4:	6c5e                	ld	s8,464(sp)
    800057b6:	6cbe                	ld	s9,456(sp)
    800057b8:	6d1e                	ld	s10,448(sp)
    800057ba:	7dfa                	ld	s11,440(sp)
    800057bc:	bb01                	j	800054cc <exec+0x8e>
    800057be:	7b1e                	ld	s6,480(sp)
    800057c0:	b9dd                	j	800054b6 <exec+0x78>
    800057c2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800057c6:	df843583          	ld	a1,-520(s0)
    800057ca:	855a                	mv	a0,s6
    800057cc:	ffffc097          	auipc	ra,0xffffc
    800057d0:	3fc080e7          	jalr	1020(ra) # 80001bc8 <proc_freepagetable>
  if(ip){
    800057d4:	79fe                	ld	s3,504(sp)
    800057d6:	7abe                	ld	s5,488(sp)
    800057d8:	7b1e                	ld	s6,480(sp)
    800057da:	6bfe                	ld	s7,472(sp)
    800057dc:	6c5e                	ld	s8,464(sp)
    800057de:	6cbe                	ld	s9,456(sp)
    800057e0:	6d1e                	ld	s10,448(sp)
    800057e2:	7dfa                	ld	s11,440(sp)
    800057e4:	b9c9                	j	800054b6 <exec+0x78>
    800057e6:	df243c23          	sd	s2,-520(s0)
    800057ea:	bff1                	j	800057c6 <exec+0x388>
    800057ec:	df243c23          	sd	s2,-520(s0)
    800057f0:	bfd9                	j	800057c6 <exec+0x388>
    800057f2:	df243c23          	sd	s2,-520(s0)
    800057f6:	bfc1                	j	800057c6 <exec+0x388>
    800057f8:	df243c23          	sd	s2,-520(s0)
    800057fc:	b7e9                	j	800057c6 <exec+0x388>
  sz = sz1;
    800057fe:	89d2                	mv	s3,s4
    80005800:	b585                	j	80005660 <exec+0x222>
    80005802:	89d2                	mv	s3,s4
    80005804:	bdb1                	j	80005660 <exec+0x222>

0000000080005806 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005806:	7179                	addi	sp,sp,-48
    80005808:	f406                	sd	ra,40(sp)
    8000580a:	f022                	sd	s0,32(sp)
    8000580c:	ec26                	sd	s1,24(sp)
    8000580e:	e84a                	sd	s2,16(sp)
    80005810:	1800                	addi	s0,sp,48
    80005812:	892e                	mv	s2,a1
    80005814:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005816:	fdc40593          	addi	a1,s0,-36
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	91a080e7          	jalr	-1766(ra) # 80003134 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005822:	fdc42703          	lw	a4,-36(s0)
    80005826:	47bd                	li	a5,15
    80005828:	02e7eb63          	bltu	a5,a4,8000585e <argfd+0x58>
    8000582c:	ffffc097          	auipc	ra,0xffffc
    80005830:	23c080e7          	jalr	572(ra) # 80001a68 <myproc>
    80005834:	fdc42703          	lw	a4,-36(s0)
    80005838:	01a70793          	addi	a5,a4,26
    8000583c:	078e                	slli	a5,a5,0x3
    8000583e:	953e                	add	a0,a0,a5
    80005840:	611c                	ld	a5,0(a0)
    80005842:	c385                	beqz	a5,80005862 <argfd+0x5c>
    return -1;
  if(pfd)
    80005844:	00090463          	beqz	s2,8000584c <argfd+0x46>
    *pfd = fd;
    80005848:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000584c:	4501                	li	a0,0
  if(pf)
    8000584e:	c091                	beqz	s1,80005852 <argfd+0x4c>
    *pf = f;
    80005850:	e09c                	sd	a5,0(s1)
}
    80005852:	70a2                	ld	ra,40(sp)
    80005854:	7402                	ld	s0,32(sp)
    80005856:	64e2                	ld	s1,24(sp)
    80005858:	6942                	ld	s2,16(sp)
    8000585a:	6145                	addi	sp,sp,48
    8000585c:	8082                	ret
    return -1;
    8000585e:	557d                	li	a0,-1
    80005860:	bfcd                	j	80005852 <argfd+0x4c>
    80005862:	557d                	li	a0,-1
    80005864:	b7fd                	j	80005852 <argfd+0x4c>

0000000080005866 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005866:	1101                	addi	sp,sp,-32
    80005868:	ec06                	sd	ra,24(sp)
    8000586a:	e822                	sd	s0,16(sp)
    8000586c:	e426                	sd	s1,8(sp)
    8000586e:	1000                	addi	s0,sp,32
    80005870:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005872:	ffffc097          	auipc	ra,0xffffc
    80005876:	1f6080e7          	jalr	502(ra) # 80001a68 <myproc>
    8000587a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000587c:	0d050793          	addi	a5,a0,208
    80005880:	4501                	li	a0,0
    80005882:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005884:	6398                	ld	a4,0(a5)
    80005886:	cb19                	beqz	a4,8000589c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005888:	2505                	addiw	a0,a0,1
    8000588a:	07a1                	addi	a5,a5,8
    8000588c:	fed51ce3          	bne	a0,a3,80005884 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005890:	557d                	li	a0,-1
}
    80005892:	60e2                	ld	ra,24(sp)
    80005894:	6442                	ld	s0,16(sp)
    80005896:	64a2                	ld	s1,8(sp)
    80005898:	6105                	addi	sp,sp,32
    8000589a:	8082                	ret
      p->ofile[fd] = f;
    8000589c:	01a50793          	addi	a5,a0,26
    800058a0:	078e                	slli	a5,a5,0x3
    800058a2:	963e                	add	a2,a2,a5
    800058a4:	e204                	sd	s1,0(a2)
      return fd;
    800058a6:	b7f5                	j	80005892 <fdalloc+0x2c>

00000000800058a8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800058a8:	715d                	addi	sp,sp,-80
    800058aa:	e486                	sd	ra,72(sp)
    800058ac:	e0a2                	sd	s0,64(sp)
    800058ae:	fc26                	sd	s1,56(sp)
    800058b0:	f84a                	sd	s2,48(sp)
    800058b2:	f44e                	sd	s3,40(sp)
    800058b4:	ec56                	sd	s5,24(sp)
    800058b6:	e85a                	sd	s6,16(sp)
    800058b8:	0880                	addi	s0,sp,80
    800058ba:	8b2e                	mv	s6,a1
    800058bc:	89b2                	mv	s3,a2
    800058be:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800058c0:	fb040593          	addi	a1,s0,-80
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	db8080e7          	jalr	-584(ra) # 8000467c <nameiparent>
    800058cc:	84aa                	mv	s1,a0
    800058ce:	14050e63          	beqz	a0,80005a2a <create+0x182>
    return 0;

  ilock(dp);
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	5a8080e7          	jalr	1448(ra) # 80003e7a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058da:	4601                	li	a2,0
    800058dc:	fb040593          	addi	a1,s0,-80
    800058e0:	8526                	mv	a0,s1
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	a94080e7          	jalr	-1388(ra) # 80004376 <dirlookup>
    800058ea:	8aaa                	mv	s5,a0
    800058ec:	c539                	beqz	a0,8000593a <create+0x92>
    iunlockput(dp);
    800058ee:	8526                	mv	a0,s1
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	7f0080e7          	jalr	2032(ra) # 800040e0 <iunlockput>
    ilock(ip);
    800058f8:	8556                	mv	a0,s5
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	580080e7          	jalr	1408(ra) # 80003e7a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005902:	4789                	li	a5,2
    80005904:	02fb1463          	bne	s6,a5,8000592c <create+0x84>
    80005908:	044ad783          	lhu	a5,68(s5)
    8000590c:	37f9                	addiw	a5,a5,-2
    8000590e:	17c2                	slli	a5,a5,0x30
    80005910:	93c1                	srli	a5,a5,0x30
    80005912:	4705                	li	a4,1
    80005914:	00f76c63          	bltu	a4,a5,8000592c <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005918:	8556                	mv	a0,s5
    8000591a:	60a6                	ld	ra,72(sp)
    8000591c:	6406                	ld	s0,64(sp)
    8000591e:	74e2                	ld	s1,56(sp)
    80005920:	7942                	ld	s2,48(sp)
    80005922:	79a2                	ld	s3,40(sp)
    80005924:	6ae2                	ld	s5,24(sp)
    80005926:	6b42                	ld	s6,16(sp)
    80005928:	6161                	addi	sp,sp,80
    8000592a:	8082                	ret
    iunlockput(ip);
    8000592c:	8556                	mv	a0,s5
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	7b2080e7          	jalr	1970(ra) # 800040e0 <iunlockput>
    return 0;
    80005936:	4a81                	li	s5,0
    80005938:	b7c5                	j	80005918 <create+0x70>
    8000593a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000593c:	85da                	mv	a1,s6
    8000593e:	4088                	lw	a0,0(s1)
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	396080e7          	jalr	918(ra) # 80003cd6 <ialloc>
    80005948:	8a2a                	mv	s4,a0
    8000594a:	c531                	beqz	a0,80005996 <create+0xee>
  ilock(ip);
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	52e080e7          	jalr	1326(ra) # 80003e7a <ilock>
  ip->major = major;
    80005954:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005958:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000595c:	4905                	li	s2,1
    8000595e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005962:	8552                	mv	a0,s4
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	44a080e7          	jalr	1098(ra) # 80003dae <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000596c:	032b0d63          	beq	s6,s2,800059a6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005970:	004a2603          	lw	a2,4(s4)
    80005974:	fb040593          	addi	a1,s0,-80
    80005978:	8526                	mv	a0,s1
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	c22080e7          	jalr	-990(ra) # 8000459c <dirlink>
    80005982:	08054163          	bltz	a0,80005a04 <create+0x15c>
  iunlockput(dp);
    80005986:	8526                	mv	a0,s1
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	758080e7          	jalr	1880(ra) # 800040e0 <iunlockput>
  return ip;
    80005990:	8ad2                	mv	s5,s4
    80005992:	7a02                	ld	s4,32(sp)
    80005994:	b751                	j	80005918 <create+0x70>
    iunlockput(dp);
    80005996:	8526                	mv	a0,s1
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	748080e7          	jalr	1864(ra) # 800040e0 <iunlockput>
    return 0;
    800059a0:	8ad2                	mv	s5,s4
    800059a2:	7a02                	ld	s4,32(sp)
    800059a4:	bf95                	j	80005918 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800059a6:	004a2603          	lw	a2,4(s4)
    800059aa:	00003597          	auipc	a1,0x3
    800059ae:	c2e58593          	addi	a1,a1,-978 # 800085d8 <etext+0x5d8>
    800059b2:	8552                	mv	a0,s4
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	be8080e7          	jalr	-1048(ra) # 8000459c <dirlink>
    800059bc:	04054463          	bltz	a0,80005a04 <create+0x15c>
    800059c0:	40d0                	lw	a2,4(s1)
    800059c2:	00003597          	auipc	a1,0x3
    800059c6:	c1e58593          	addi	a1,a1,-994 # 800085e0 <etext+0x5e0>
    800059ca:	8552                	mv	a0,s4
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	bd0080e7          	jalr	-1072(ra) # 8000459c <dirlink>
    800059d4:	02054863          	bltz	a0,80005a04 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    800059d8:	004a2603          	lw	a2,4(s4)
    800059dc:	fb040593          	addi	a1,s0,-80
    800059e0:	8526                	mv	a0,s1
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	bba080e7          	jalr	-1094(ra) # 8000459c <dirlink>
    800059ea:	00054d63          	bltz	a0,80005a04 <create+0x15c>
    dp->nlink++;  // for ".."
    800059ee:	04a4d783          	lhu	a5,74(s1)
    800059f2:	2785                	addiw	a5,a5,1
    800059f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059f8:	8526                	mv	a0,s1
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	3b4080e7          	jalr	948(ra) # 80003dae <iupdate>
    80005a02:	b751                	j	80005986 <create+0xde>
  ip->nlink = 0;
    80005a04:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a08:	8552                	mv	a0,s4
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	3a4080e7          	jalr	932(ra) # 80003dae <iupdate>
  iunlockput(ip);
    80005a12:	8552                	mv	a0,s4
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	6cc080e7          	jalr	1740(ra) # 800040e0 <iunlockput>
  iunlockput(dp);
    80005a1c:	8526                	mv	a0,s1
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	6c2080e7          	jalr	1730(ra) # 800040e0 <iunlockput>
  return 0;
    80005a26:	7a02                	ld	s4,32(sp)
    80005a28:	bdc5                	j	80005918 <create+0x70>
    return 0;
    80005a2a:	8aaa                	mv	s5,a0
    80005a2c:	b5f5                	j	80005918 <create+0x70>

0000000080005a2e <sys_dup>:
{
    80005a2e:	7179                	addi	sp,sp,-48
    80005a30:	f406                	sd	ra,40(sp)
    80005a32:	f022                	sd	s0,32(sp)
    80005a34:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a36:	fd840613          	addi	a2,s0,-40
    80005a3a:	4581                	li	a1,0
    80005a3c:	4501                	li	a0,0
    80005a3e:	00000097          	auipc	ra,0x0
    80005a42:	dc8080e7          	jalr	-568(ra) # 80005806 <argfd>
    return -1;
    80005a46:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a48:	02054763          	bltz	a0,80005a76 <sys_dup+0x48>
    80005a4c:	ec26                	sd	s1,24(sp)
    80005a4e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005a50:	fd843903          	ld	s2,-40(s0)
    80005a54:	854a                	mv	a0,s2
    80005a56:	00000097          	auipc	ra,0x0
    80005a5a:	e10080e7          	jalr	-496(ra) # 80005866 <fdalloc>
    80005a5e:	84aa                	mv	s1,a0
    return -1;
    80005a60:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a62:	00054f63          	bltz	a0,80005a80 <sys_dup+0x52>
  filedup(f);
    80005a66:	854a                	mv	a0,s2
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	27a080e7          	jalr	634(ra) # 80004ce2 <filedup>
  return fd;
    80005a70:	87a6                	mv	a5,s1
    80005a72:	64e2                	ld	s1,24(sp)
    80005a74:	6942                	ld	s2,16(sp)
}
    80005a76:	853e                	mv	a0,a5
    80005a78:	70a2                	ld	ra,40(sp)
    80005a7a:	7402                	ld	s0,32(sp)
    80005a7c:	6145                	addi	sp,sp,48
    80005a7e:	8082                	ret
    80005a80:	64e2                	ld	s1,24(sp)
    80005a82:	6942                	ld	s2,16(sp)
    80005a84:	bfcd                	j	80005a76 <sys_dup+0x48>

0000000080005a86 <sys_read>:
{
    80005a86:	7179                	addi	sp,sp,-48
    80005a88:	f406                	sd	ra,40(sp)
    80005a8a:	f022                	sd	s0,32(sp)
    80005a8c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a8e:	fd840593          	addi	a1,s0,-40
    80005a92:	4505                	li	a0,1
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	6c0080e7          	jalr	1728(ra) # 80003154 <argaddr>
  argint(2, &n);
    80005a9c:	fe440593          	addi	a1,s0,-28
    80005aa0:	4509                	li	a0,2
    80005aa2:	ffffd097          	auipc	ra,0xffffd
    80005aa6:	692080e7          	jalr	1682(ra) # 80003134 <argint>
  if(argfd(0, 0, &f) < 0)
    80005aaa:	fe840613          	addi	a2,s0,-24
    80005aae:	4581                	li	a1,0
    80005ab0:	4501                	li	a0,0
    80005ab2:	00000097          	auipc	ra,0x0
    80005ab6:	d54080e7          	jalr	-684(ra) # 80005806 <argfd>
    80005aba:	87aa                	mv	a5,a0
    return -1;
    80005abc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005abe:	0007cc63          	bltz	a5,80005ad6 <sys_read+0x50>
  return fileread(f, p, n);
    80005ac2:	fe442603          	lw	a2,-28(s0)
    80005ac6:	fd843583          	ld	a1,-40(s0)
    80005aca:	fe843503          	ld	a0,-24(s0)
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	3ba080e7          	jalr	954(ra) # 80004e88 <fileread>
}
    80005ad6:	70a2                	ld	ra,40(sp)
    80005ad8:	7402                	ld	s0,32(sp)
    80005ada:	6145                	addi	sp,sp,48
    80005adc:	8082                	ret

0000000080005ade <sys_write>:
{
    80005ade:	7179                	addi	sp,sp,-48
    80005ae0:	f406                	sd	ra,40(sp)
    80005ae2:	f022                	sd	s0,32(sp)
    80005ae4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005ae6:	fd840593          	addi	a1,s0,-40
    80005aea:	4505                	li	a0,1
    80005aec:	ffffd097          	auipc	ra,0xffffd
    80005af0:	668080e7          	jalr	1640(ra) # 80003154 <argaddr>
  argint(2, &n);
    80005af4:	fe440593          	addi	a1,s0,-28
    80005af8:	4509                	li	a0,2
    80005afa:	ffffd097          	auipc	ra,0xffffd
    80005afe:	63a080e7          	jalr	1594(ra) # 80003134 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b02:	fe840613          	addi	a2,s0,-24
    80005b06:	4581                	li	a1,0
    80005b08:	4501                	li	a0,0
    80005b0a:	00000097          	auipc	ra,0x0
    80005b0e:	cfc080e7          	jalr	-772(ra) # 80005806 <argfd>
    80005b12:	87aa                	mv	a5,a0
    return -1;
    80005b14:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b16:	0007cc63          	bltz	a5,80005b2e <sys_write+0x50>
  return filewrite(f, p, n);
    80005b1a:	fe442603          	lw	a2,-28(s0)
    80005b1e:	fd843583          	ld	a1,-40(s0)
    80005b22:	fe843503          	ld	a0,-24(s0)
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	434080e7          	jalr	1076(ra) # 80004f5a <filewrite>
}
    80005b2e:	70a2                	ld	ra,40(sp)
    80005b30:	7402                	ld	s0,32(sp)
    80005b32:	6145                	addi	sp,sp,48
    80005b34:	8082                	ret

0000000080005b36 <sys_close>:
{
    80005b36:	1101                	addi	sp,sp,-32
    80005b38:	ec06                	sd	ra,24(sp)
    80005b3a:	e822                	sd	s0,16(sp)
    80005b3c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b3e:	fe040613          	addi	a2,s0,-32
    80005b42:	fec40593          	addi	a1,s0,-20
    80005b46:	4501                	li	a0,0
    80005b48:	00000097          	auipc	ra,0x0
    80005b4c:	cbe080e7          	jalr	-834(ra) # 80005806 <argfd>
    return -1;
    80005b50:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b52:	02054463          	bltz	a0,80005b7a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b56:	ffffc097          	auipc	ra,0xffffc
    80005b5a:	f12080e7          	jalr	-238(ra) # 80001a68 <myproc>
    80005b5e:	fec42783          	lw	a5,-20(s0)
    80005b62:	07e9                	addi	a5,a5,26
    80005b64:	078e                	slli	a5,a5,0x3
    80005b66:	953e                	add	a0,a0,a5
    80005b68:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005b6c:	fe043503          	ld	a0,-32(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	1c4080e7          	jalr	452(ra) # 80004d34 <fileclose>
  return 0;
    80005b78:	4781                	li	a5,0
}
    80005b7a:	853e                	mv	a0,a5
    80005b7c:	60e2                	ld	ra,24(sp)
    80005b7e:	6442                	ld	s0,16(sp)
    80005b80:	6105                	addi	sp,sp,32
    80005b82:	8082                	ret

0000000080005b84 <sys_fstat>:
{
    80005b84:	1101                	addi	sp,sp,-32
    80005b86:	ec06                	sd	ra,24(sp)
    80005b88:	e822                	sd	s0,16(sp)
    80005b8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b8c:	fe040593          	addi	a1,s0,-32
    80005b90:	4505                	li	a0,1
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	5c2080e7          	jalr	1474(ra) # 80003154 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b9a:	fe840613          	addi	a2,s0,-24
    80005b9e:	4581                	li	a1,0
    80005ba0:	4501                	li	a0,0
    80005ba2:	00000097          	auipc	ra,0x0
    80005ba6:	c64080e7          	jalr	-924(ra) # 80005806 <argfd>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bae:	0007ca63          	bltz	a5,80005bc2 <sys_fstat+0x3e>
  return filestat(f, st);
    80005bb2:	fe043583          	ld	a1,-32(s0)
    80005bb6:	fe843503          	ld	a0,-24(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	258080e7          	jalr	600(ra) # 80004e12 <filestat>
}
    80005bc2:	60e2                	ld	ra,24(sp)
    80005bc4:	6442                	ld	s0,16(sp)
    80005bc6:	6105                	addi	sp,sp,32
    80005bc8:	8082                	ret

0000000080005bca <sys_link>:
{
    80005bca:	7169                	addi	sp,sp,-304
    80005bcc:	f606                	sd	ra,296(sp)
    80005bce:	f222                	sd	s0,288(sp)
    80005bd0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bd2:	08000613          	li	a2,128
    80005bd6:	ed040593          	addi	a1,s0,-304
    80005bda:	4501                	li	a0,0
    80005bdc:	ffffd097          	auipc	ra,0xffffd
    80005be0:	598080e7          	jalr	1432(ra) # 80003174 <argstr>
    return -1;
    80005be4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005be6:	12054663          	bltz	a0,80005d12 <sys_link+0x148>
    80005bea:	08000613          	li	a2,128
    80005bee:	f5040593          	addi	a1,s0,-176
    80005bf2:	4505                	li	a0,1
    80005bf4:	ffffd097          	auipc	ra,0xffffd
    80005bf8:	580080e7          	jalr	1408(ra) # 80003174 <argstr>
    return -1;
    80005bfc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bfe:	10054a63          	bltz	a0,80005d12 <sys_link+0x148>
    80005c02:	ee26                	sd	s1,280(sp)
  begin_op();
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	c60080e7          	jalr	-928(ra) # 80004864 <begin_op>
  if((ip = namei(old)) == 0){
    80005c0c:	ed040513          	addi	a0,s0,-304
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	a4e080e7          	jalr	-1458(ra) # 8000465e <namei>
    80005c18:	84aa                	mv	s1,a0
    80005c1a:	c949                	beqz	a0,80005cac <sys_link+0xe2>
  ilock(ip);
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	25e080e7          	jalr	606(ra) # 80003e7a <ilock>
  if(ip->type == T_DIR){
    80005c24:	04449703          	lh	a4,68(s1)
    80005c28:	4785                	li	a5,1
    80005c2a:	08f70863          	beq	a4,a5,80005cba <sys_link+0xf0>
    80005c2e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005c30:	04a4d783          	lhu	a5,74(s1)
    80005c34:	2785                	addiw	a5,a5,1
    80005c36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	172080e7          	jalr	370(ra) # 80003dae <iupdate>
  iunlock(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	2fa080e7          	jalr	762(ra) # 80003f40 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c4e:	fd040593          	addi	a1,s0,-48
    80005c52:	f5040513          	addi	a0,s0,-176
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	a26080e7          	jalr	-1498(ra) # 8000467c <nameiparent>
    80005c5e:	892a                	mv	s2,a0
    80005c60:	cd35                	beqz	a0,80005cdc <sys_link+0x112>
  ilock(dp);
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	218080e7          	jalr	536(ra) # 80003e7a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c6a:	00092703          	lw	a4,0(s2)
    80005c6e:	409c                	lw	a5,0(s1)
    80005c70:	06f71163          	bne	a4,a5,80005cd2 <sys_link+0x108>
    80005c74:	40d0                	lw	a2,4(s1)
    80005c76:	fd040593          	addi	a1,s0,-48
    80005c7a:	854a                	mv	a0,s2
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	920080e7          	jalr	-1760(ra) # 8000459c <dirlink>
    80005c84:	04054763          	bltz	a0,80005cd2 <sys_link+0x108>
  iunlockput(dp);
    80005c88:	854a                	mv	a0,s2
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	456080e7          	jalr	1110(ra) # 800040e0 <iunlockput>
  iput(ip);
    80005c92:	8526                	mv	a0,s1
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	3a4080e7          	jalr	932(ra) # 80004038 <iput>
  end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	c42080e7          	jalr	-958(ra) # 800048de <end_op>
  return 0;
    80005ca4:	4781                	li	a5,0
    80005ca6:	64f2                	ld	s1,280(sp)
    80005ca8:	6952                	ld	s2,272(sp)
    80005caa:	a0a5                	j	80005d12 <sys_link+0x148>
    end_op();
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	c32080e7          	jalr	-974(ra) # 800048de <end_op>
    return -1;
    80005cb4:	57fd                	li	a5,-1
    80005cb6:	64f2                	ld	s1,280(sp)
    80005cb8:	a8a9                	j	80005d12 <sys_link+0x148>
    iunlockput(ip);
    80005cba:	8526                	mv	a0,s1
    80005cbc:	ffffe097          	auipc	ra,0xffffe
    80005cc0:	424080e7          	jalr	1060(ra) # 800040e0 <iunlockput>
    end_op();
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	c1a080e7          	jalr	-998(ra) # 800048de <end_op>
    return -1;
    80005ccc:	57fd                	li	a5,-1
    80005cce:	64f2                	ld	s1,280(sp)
    80005cd0:	a089                	j	80005d12 <sys_link+0x148>
    iunlockput(dp);
    80005cd2:	854a                	mv	a0,s2
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	40c080e7          	jalr	1036(ra) # 800040e0 <iunlockput>
  ilock(ip);
    80005cdc:	8526                	mv	a0,s1
    80005cde:	ffffe097          	auipc	ra,0xffffe
    80005ce2:	19c080e7          	jalr	412(ra) # 80003e7a <ilock>
  ip->nlink--;
    80005ce6:	04a4d783          	lhu	a5,74(s1)
    80005cea:	37fd                	addiw	a5,a5,-1
    80005cec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cf0:	8526                	mv	a0,s1
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	0bc080e7          	jalr	188(ra) # 80003dae <iupdate>
  iunlockput(ip);
    80005cfa:	8526                	mv	a0,s1
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	3e4080e7          	jalr	996(ra) # 800040e0 <iunlockput>
  end_op();
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	bda080e7          	jalr	-1062(ra) # 800048de <end_op>
  return -1;
    80005d0c:	57fd                	li	a5,-1
    80005d0e:	64f2                	ld	s1,280(sp)
    80005d10:	6952                	ld	s2,272(sp)
}
    80005d12:	853e                	mv	a0,a5
    80005d14:	70b2                	ld	ra,296(sp)
    80005d16:	7412                	ld	s0,288(sp)
    80005d18:	6155                	addi	sp,sp,304
    80005d1a:	8082                	ret

0000000080005d1c <sys_unlink>:
{
    80005d1c:	7111                	addi	sp,sp,-256
    80005d1e:	fd86                	sd	ra,248(sp)
    80005d20:	f9a2                	sd	s0,240(sp)
    80005d22:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80005d24:	08000613          	li	a2,128
    80005d28:	f2040593          	addi	a1,s0,-224
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	446080e7          	jalr	1094(ra) # 80003174 <argstr>
    80005d36:	1c054063          	bltz	a0,80005ef6 <sys_unlink+0x1da>
    80005d3a:	f5a6                	sd	s1,232(sp)
  begin_op();
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	b28080e7          	jalr	-1240(ra) # 80004864 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d44:	fa040593          	addi	a1,s0,-96
    80005d48:	f2040513          	addi	a0,s0,-224
    80005d4c:	fffff097          	auipc	ra,0xfffff
    80005d50:	930080e7          	jalr	-1744(ra) # 8000467c <nameiparent>
    80005d54:	84aa                	mv	s1,a0
    80005d56:	c165                	beqz	a0,80005e36 <sys_unlink+0x11a>
  ilock(dp);
    80005d58:	ffffe097          	auipc	ra,0xffffe
    80005d5c:	122080e7          	jalr	290(ra) # 80003e7a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d60:	00003597          	auipc	a1,0x3
    80005d64:	87858593          	addi	a1,a1,-1928 # 800085d8 <etext+0x5d8>
    80005d68:	fa040513          	addi	a0,s0,-96
    80005d6c:	ffffe097          	auipc	ra,0xffffe
    80005d70:	5f0080e7          	jalr	1520(ra) # 8000435c <namecmp>
    80005d74:	16050263          	beqz	a0,80005ed8 <sys_unlink+0x1bc>
    80005d78:	00003597          	auipc	a1,0x3
    80005d7c:	86858593          	addi	a1,a1,-1944 # 800085e0 <etext+0x5e0>
    80005d80:	fa040513          	addi	a0,s0,-96
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	5d8080e7          	jalr	1496(ra) # 8000435c <namecmp>
    80005d8c:	14050663          	beqz	a0,80005ed8 <sys_unlink+0x1bc>
    80005d90:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d92:	f1c40613          	addi	a2,s0,-228
    80005d96:	fa040593          	addi	a1,s0,-96
    80005d9a:	8526                	mv	a0,s1
    80005d9c:	ffffe097          	auipc	ra,0xffffe
    80005da0:	5da080e7          	jalr	1498(ra) # 80004376 <dirlookup>
    80005da4:	892a                	mv	s2,a0
    80005da6:	12050863          	beqz	a0,80005ed6 <sys_unlink+0x1ba>
    80005daa:	edce                	sd	s3,216(sp)
  ilock(ip);
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	0ce080e7          	jalr	206(ra) # 80003e7a <ilock>
  if(ip->nlink < 1)
    80005db4:	04a91783          	lh	a5,74(s2)
    80005db8:	08f05663          	blez	a5,80005e44 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005dbc:	04491703          	lh	a4,68(s2)
    80005dc0:	4785                	li	a5,1
    80005dc2:	08f70b63          	beq	a4,a5,80005e58 <sys_unlink+0x13c>
  memset(&de, 0, sizeof(de));
    80005dc6:	fb040993          	addi	s3,s0,-80
    80005dca:	4641                	li	a2,16
    80005dcc:	4581                	li	a1,0
    80005dce:	854e                	mv	a0,s3
    80005dd0:	ffffb097          	auipc	ra,0xffffb
    80005dd4:	f66080e7          	jalr	-154(ra) # 80000d36 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dd8:	4741                	li	a4,16
    80005dda:	f1c42683          	lw	a3,-228(s0)
    80005dde:	864e                	mv	a2,s3
    80005de0:	4581                	li	a1,0
    80005de2:	8526                	mv	a0,s1
    80005de4:	ffffe097          	auipc	ra,0xffffe
    80005de8:	458080e7          	jalr	1112(ra) # 8000423c <writei>
    80005dec:	47c1                	li	a5,16
    80005dee:	0af51f63          	bne	a0,a5,80005eac <sys_unlink+0x190>
  if(ip->type == T_DIR){
    80005df2:	04491703          	lh	a4,68(s2)
    80005df6:	4785                	li	a5,1
    80005df8:	0cf70463          	beq	a4,a5,80005ec0 <sys_unlink+0x1a4>
  iunlockput(dp);
    80005dfc:	8526                	mv	a0,s1
    80005dfe:	ffffe097          	auipc	ra,0xffffe
    80005e02:	2e2080e7          	jalr	738(ra) # 800040e0 <iunlockput>
  ip->nlink--;
    80005e06:	04a95783          	lhu	a5,74(s2)
    80005e0a:	37fd                	addiw	a5,a5,-1
    80005e0c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e10:	854a                	mv	a0,s2
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	f9c080e7          	jalr	-100(ra) # 80003dae <iupdate>
  iunlockput(ip);
    80005e1a:	854a                	mv	a0,s2
    80005e1c:	ffffe097          	auipc	ra,0xffffe
    80005e20:	2c4080e7          	jalr	708(ra) # 800040e0 <iunlockput>
  end_op();
    80005e24:	fffff097          	auipc	ra,0xfffff
    80005e28:	aba080e7          	jalr	-1350(ra) # 800048de <end_op>
  return 0;
    80005e2c:	4501                	li	a0,0
    80005e2e:	74ae                	ld	s1,232(sp)
    80005e30:	790e                	ld	s2,224(sp)
    80005e32:	69ee                	ld	s3,216(sp)
    80005e34:	a86d                	j	80005eee <sys_unlink+0x1d2>
    end_op();
    80005e36:	fffff097          	auipc	ra,0xfffff
    80005e3a:	aa8080e7          	jalr	-1368(ra) # 800048de <end_op>
    return -1;
    80005e3e:	557d                	li	a0,-1
    80005e40:	74ae                	ld	s1,232(sp)
    80005e42:	a075                	j	80005eee <sys_unlink+0x1d2>
    80005e44:	e9d2                	sd	s4,208(sp)
    80005e46:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80005e48:	00002517          	auipc	a0,0x2
    80005e4c:	7a050513          	addi	a0,a0,1952 # 800085e8 <etext+0x5e8>
    80005e50:	ffffa097          	auipc	ra,0xffffa
    80005e54:	710080e7          	jalr	1808(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e58:	04c92703          	lw	a4,76(s2)
    80005e5c:	02000793          	li	a5,32
    80005e60:	f6e7f3e3          	bgeu	a5,a4,80005dc6 <sys_unlink+0xaa>
    80005e64:	e9d2                	sd	s4,208(sp)
    80005e66:	e5d6                	sd	s5,200(sp)
    80005e68:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e6a:	f0840a93          	addi	s5,s0,-248
    80005e6e:	4a41                	li	s4,16
    80005e70:	8752                	mv	a4,s4
    80005e72:	86ce                	mv	a3,s3
    80005e74:	8656                	mv	a2,s5
    80005e76:	4581                	li	a1,0
    80005e78:	854a                	mv	a0,s2
    80005e7a:	ffffe097          	auipc	ra,0xffffe
    80005e7e:	2bc080e7          	jalr	700(ra) # 80004136 <readi>
    80005e82:	01451d63          	bne	a0,s4,80005e9c <sys_unlink+0x180>
    if(de.inum != 0)
    80005e86:	f0845783          	lhu	a5,-248(s0)
    80005e8a:	eba5                	bnez	a5,80005efa <sys_unlink+0x1de>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e8c:	29c1                	addiw	s3,s3,16
    80005e8e:	04c92783          	lw	a5,76(s2)
    80005e92:	fcf9efe3          	bltu	s3,a5,80005e70 <sys_unlink+0x154>
    80005e96:	6a4e                	ld	s4,208(sp)
    80005e98:	6aae                	ld	s5,200(sp)
    80005e9a:	b735                	j	80005dc6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e9c:	00002517          	auipc	a0,0x2
    80005ea0:	76450513          	addi	a0,a0,1892 # 80008600 <etext+0x600>
    80005ea4:	ffffa097          	auipc	ra,0xffffa
    80005ea8:	6bc080e7          	jalr	1724(ra) # 80000560 <panic>
    80005eac:	e9d2                	sd	s4,208(sp)
    80005eae:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80005eb0:	00002517          	auipc	a0,0x2
    80005eb4:	76850513          	addi	a0,a0,1896 # 80008618 <etext+0x618>
    80005eb8:	ffffa097          	auipc	ra,0xffffa
    80005ebc:	6a8080e7          	jalr	1704(ra) # 80000560 <panic>
    dp->nlink--;
    80005ec0:	04a4d783          	lhu	a5,74(s1)
    80005ec4:	37fd                	addiw	a5,a5,-1
    80005ec6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005eca:	8526                	mv	a0,s1
    80005ecc:	ffffe097          	auipc	ra,0xffffe
    80005ed0:	ee2080e7          	jalr	-286(ra) # 80003dae <iupdate>
    80005ed4:	b725                	j	80005dfc <sys_unlink+0xe0>
    80005ed6:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80005ed8:	8526                	mv	a0,s1
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	206080e7          	jalr	518(ra) # 800040e0 <iunlockput>
  end_op();
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	9fc080e7          	jalr	-1540(ra) # 800048de <end_op>
  return -1;
    80005eea:	557d                	li	a0,-1
    80005eec:	74ae                	ld	s1,232(sp)
}
    80005eee:	70ee                	ld	ra,248(sp)
    80005ef0:	744e                	ld	s0,240(sp)
    80005ef2:	6111                	addi	sp,sp,256
    80005ef4:	8082                	ret
    return -1;
    80005ef6:	557d                	li	a0,-1
    80005ef8:	bfdd                	j	80005eee <sys_unlink+0x1d2>
    iunlockput(ip);
    80005efa:	854a                	mv	a0,s2
    80005efc:	ffffe097          	auipc	ra,0xffffe
    80005f00:	1e4080e7          	jalr	484(ra) # 800040e0 <iunlockput>
    goto bad;
    80005f04:	790e                	ld	s2,224(sp)
    80005f06:	69ee                	ld	s3,216(sp)
    80005f08:	6a4e                	ld	s4,208(sp)
    80005f0a:	6aae                	ld	s5,200(sp)
    80005f0c:	b7f1                	j	80005ed8 <sys_unlink+0x1bc>

0000000080005f0e <sys_open>:

uint64
sys_open(void)
{
    80005f0e:	7131                	addi	sp,sp,-192
    80005f10:	fd06                	sd	ra,184(sp)
    80005f12:	f922                	sd	s0,176(sp)
    80005f14:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005f16:	f4c40593          	addi	a1,s0,-180
    80005f1a:	4505                	li	a0,1
    80005f1c:	ffffd097          	auipc	ra,0xffffd
    80005f20:	218080e7          	jalr	536(ra) # 80003134 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f24:	08000613          	li	a2,128
    80005f28:	f5040593          	addi	a1,s0,-176
    80005f2c:	4501                	li	a0,0
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	246080e7          	jalr	582(ra) # 80003174 <argstr>
    80005f36:	87aa                	mv	a5,a0
    return -1;
    80005f38:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f3a:	0a07cf63          	bltz	a5,80005ff8 <sys_open+0xea>
    80005f3e:	f526                	sd	s1,168(sp)

  begin_op();
    80005f40:	fffff097          	auipc	ra,0xfffff
    80005f44:	924080e7          	jalr	-1756(ra) # 80004864 <begin_op>

  if(omode & O_CREATE){
    80005f48:	f4c42783          	lw	a5,-180(s0)
    80005f4c:	2007f793          	andi	a5,a5,512
    80005f50:	cfdd                	beqz	a5,8000600e <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    80005f52:	4681                	li	a3,0
    80005f54:	4601                	li	a2,0
    80005f56:	4589                	li	a1,2
    80005f58:	f5040513          	addi	a0,s0,-176
    80005f5c:	00000097          	auipc	ra,0x0
    80005f60:	94c080e7          	jalr	-1716(ra) # 800058a8 <create>
    80005f64:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f66:	cd49                	beqz	a0,80006000 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f68:	04449703          	lh	a4,68(s1)
    80005f6c:	478d                	li	a5,3
    80005f6e:	00f71763          	bne	a4,a5,80005f7c <sys_open+0x6e>
    80005f72:	0464d703          	lhu	a4,70(s1)
    80005f76:	47a5                	li	a5,9
    80005f78:	0ee7e263          	bltu	a5,a4,8000605c <sys_open+0x14e>
    80005f7c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f7e:	fffff097          	auipc	ra,0xfffff
    80005f82:	cfa080e7          	jalr	-774(ra) # 80004c78 <filealloc>
    80005f86:	892a                	mv	s2,a0
    80005f88:	cd65                	beqz	a0,80006080 <sys_open+0x172>
    80005f8a:	ed4e                	sd	s3,152(sp)
    80005f8c:	00000097          	auipc	ra,0x0
    80005f90:	8da080e7          	jalr	-1830(ra) # 80005866 <fdalloc>
    80005f94:	89aa                	mv	s3,a0
    80005f96:	0c054f63          	bltz	a0,80006074 <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f9a:	04449703          	lh	a4,68(s1)
    80005f9e:	478d                	li	a5,3
    80005fa0:	0ef70d63          	beq	a4,a5,8000609a <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005fa4:	4789                	li	a5,2
    80005fa6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005faa:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005fae:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005fb2:	f4c42783          	lw	a5,-180(s0)
    80005fb6:	0017f713          	andi	a4,a5,1
    80005fba:	00174713          	xori	a4,a4,1
    80005fbe:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005fc2:	0037f713          	andi	a4,a5,3
    80005fc6:	00e03733          	snez	a4,a4
    80005fca:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005fce:	4007f793          	andi	a5,a5,1024
    80005fd2:	c791                	beqz	a5,80005fde <sys_open+0xd0>
    80005fd4:	04449703          	lh	a4,68(s1)
    80005fd8:	4789                	li	a5,2
    80005fda:	0cf70763          	beq	a4,a5,800060a8 <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80005fde:	8526                	mv	a0,s1
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	f60080e7          	jalr	-160(ra) # 80003f40 <iunlock>
  end_op();
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	8f6080e7          	jalr	-1802(ra) # 800048de <end_op>

  return fd;
    80005ff0:	854e                	mv	a0,s3
    80005ff2:	74aa                	ld	s1,168(sp)
    80005ff4:	790a                	ld	s2,160(sp)
    80005ff6:	69ea                	ld	s3,152(sp)
}
    80005ff8:	70ea                	ld	ra,184(sp)
    80005ffa:	744a                	ld	s0,176(sp)
    80005ffc:	6129                	addi	sp,sp,192
    80005ffe:	8082                	ret
      end_op();
    80006000:	fffff097          	auipc	ra,0xfffff
    80006004:	8de080e7          	jalr	-1826(ra) # 800048de <end_op>
      return -1;
    80006008:	557d                	li	a0,-1
    8000600a:	74aa                	ld	s1,168(sp)
    8000600c:	b7f5                	j	80005ff8 <sys_open+0xea>
    if((ip = namei(path)) == 0){
    8000600e:	f5040513          	addi	a0,s0,-176
    80006012:	ffffe097          	auipc	ra,0xffffe
    80006016:	64c080e7          	jalr	1612(ra) # 8000465e <namei>
    8000601a:	84aa                	mv	s1,a0
    8000601c:	c90d                	beqz	a0,8000604e <sys_open+0x140>
    ilock(ip);
    8000601e:	ffffe097          	auipc	ra,0xffffe
    80006022:	e5c080e7          	jalr	-420(ra) # 80003e7a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006026:	04449703          	lh	a4,68(s1)
    8000602a:	4785                	li	a5,1
    8000602c:	f2f71ee3          	bne	a4,a5,80005f68 <sys_open+0x5a>
    80006030:	f4c42783          	lw	a5,-180(s0)
    80006034:	d7a1                	beqz	a5,80005f7c <sys_open+0x6e>
      iunlockput(ip);
    80006036:	8526                	mv	a0,s1
    80006038:	ffffe097          	auipc	ra,0xffffe
    8000603c:	0a8080e7          	jalr	168(ra) # 800040e0 <iunlockput>
      end_op();
    80006040:	fffff097          	auipc	ra,0xfffff
    80006044:	89e080e7          	jalr	-1890(ra) # 800048de <end_op>
      return -1;
    80006048:	557d                	li	a0,-1
    8000604a:	74aa                	ld	s1,168(sp)
    8000604c:	b775                	j	80005ff8 <sys_open+0xea>
      end_op();
    8000604e:	fffff097          	auipc	ra,0xfffff
    80006052:	890080e7          	jalr	-1904(ra) # 800048de <end_op>
      return -1;
    80006056:	557d                	li	a0,-1
    80006058:	74aa                	ld	s1,168(sp)
    8000605a:	bf79                	j	80005ff8 <sys_open+0xea>
    iunlockput(ip);
    8000605c:	8526                	mv	a0,s1
    8000605e:	ffffe097          	auipc	ra,0xffffe
    80006062:	082080e7          	jalr	130(ra) # 800040e0 <iunlockput>
    end_op();
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	878080e7          	jalr	-1928(ra) # 800048de <end_op>
    return -1;
    8000606e:	557d                	li	a0,-1
    80006070:	74aa                	ld	s1,168(sp)
    80006072:	b759                	j	80005ff8 <sys_open+0xea>
      fileclose(f);
    80006074:	854a                	mv	a0,s2
    80006076:	fffff097          	auipc	ra,0xfffff
    8000607a:	cbe080e7          	jalr	-834(ra) # 80004d34 <fileclose>
    8000607e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006080:	8526                	mv	a0,s1
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	05e080e7          	jalr	94(ra) # 800040e0 <iunlockput>
    end_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	854080e7          	jalr	-1964(ra) # 800048de <end_op>
    return -1;
    80006092:	557d                	li	a0,-1
    80006094:	74aa                	ld	s1,168(sp)
    80006096:	790a                	ld	s2,160(sp)
    80006098:	b785                	j	80005ff8 <sys_open+0xea>
    f->type = FD_DEVICE;
    8000609a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000609e:	04649783          	lh	a5,70(s1)
    800060a2:	02f91223          	sh	a5,36(s2)
    800060a6:	b721                	j	80005fae <sys_open+0xa0>
    itrunc(ip);
    800060a8:	8526                	mv	a0,s1
    800060aa:	ffffe097          	auipc	ra,0xffffe
    800060ae:	ee2080e7          	jalr	-286(ra) # 80003f8c <itrunc>
    800060b2:	b735                	j	80005fde <sys_open+0xd0>

00000000800060b4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800060b4:	7175                	addi	sp,sp,-144
    800060b6:	e506                	sd	ra,136(sp)
    800060b8:	e122                	sd	s0,128(sp)
    800060ba:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	7a8080e7          	jalr	1960(ra) # 80004864 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800060c4:	08000613          	li	a2,128
    800060c8:	f7040593          	addi	a1,s0,-144
    800060cc:	4501                	li	a0,0
    800060ce:	ffffd097          	auipc	ra,0xffffd
    800060d2:	0a6080e7          	jalr	166(ra) # 80003174 <argstr>
    800060d6:	02054963          	bltz	a0,80006108 <sys_mkdir+0x54>
    800060da:	4681                	li	a3,0
    800060dc:	4601                	li	a2,0
    800060de:	4585                	li	a1,1
    800060e0:	f7040513          	addi	a0,s0,-144
    800060e4:	fffff097          	auipc	ra,0xfffff
    800060e8:	7c4080e7          	jalr	1988(ra) # 800058a8 <create>
    800060ec:	cd11                	beqz	a0,80006108 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060ee:	ffffe097          	auipc	ra,0xffffe
    800060f2:	ff2080e7          	jalr	-14(ra) # 800040e0 <iunlockput>
  end_op();
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	7e8080e7          	jalr	2024(ra) # 800048de <end_op>
  return 0;
    800060fe:	4501                	li	a0,0
}
    80006100:	60aa                	ld	ra,136(sp)
    80006102:	640a                	ld	s0,128(sp)
    80006104:	6149                	addi	sp,sp,144
    80006106:	8082                	ret
    end_op();
    80006108:	ffffe097          	auipc	ra,0xffffe
    8000610c:	7d6080e7          	jalr	2006(ra) # 800048de <end_op>
    return -1;
    80006110:	557d                	li	a0,-1
    80006112:	b7fd                	j	80006100 <sys_mkdir+0x4c>

0000000080006114 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006114:	7135                	addi	sp,sp,-160
    80006116:	ed06                	sd	ra,152(sp)
    80006118:	e922                	sd	s0,144(sp)
    8000611a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000611c:	ffffe097          	auipc	ra,0xffffe
    80006120:	748080e7          	jalr	1864(ra) # 80004864 <begin_op>
  argint(1, &major);
    80006124:	f6c40593          	addi	a1,s0,-148
    80006128:	4505                	li	a0,1
    8000612a:	ffffd097          	auipc	ra,0xffffd
    8000612e:	00a080e7          	jalr	10(ra) # 80003134 <argint>
  argint(2, &minor);
    80006132:	f6840593          	addi	a1,s0,-152
    80006136:	4509                	li	a0,2
    80006138:	ffffd097          	auipc	ra,0xffffd
    8000613c:	ffc080e7          	jalr	-4(ra) # 80003134 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006140:	08000613          	li	a2,128
    80006144:	f7040593          	addi	a1,s0,-144
    80006148:	4501                	li	a0,0
    8000614a:	ffffd097          	auipc	ra,0xffffd
    8000614e:	02a080e7          	jalr	42(ra) # 80003174 <argstr>
    80006152:	02054b63          	bltz	a0,80006188 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006156:	f6841683          	lh	a3,-152(s0)
    8000615a:	f6c41603          	lh	a2,-148(s0)
    8000615e:	458d                	li	a1,3
    80006160:	f7040513          	addi	a0,s0,-144
    80006164:	fffff097          	auipc	ra,0xfffff
    80006168:	744080e7          	jalr	1860(ra) # 800058a8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000616c:	cd11                	beqz	a0,80006188 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000616e:	ffffe097          	auipc	ra,0xffffe
    80006172:	f72080e7          	jalr	-142(ra) # 800040e0 <iunlockput>
  end_op();
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	768080e7          	jalr	1896(ra) # 800048de <end_op>
  return 0;
    8000617e:	4501                	li	a0,0
}
    80006180:	60ea                	ld	ra,152(sp)
    80006182:	644a                	ld	s0,144(sp)
    80006184:	610d                	addi	sp,sp,160
    80006186:	8082                	ret
    end_op();
    80006188:	ffffe097          	auipc	ra,0xffffe
    8000618c:	756080e7          	jalr	1878(ra) # 800048de <end_op>
    return -1;
    80006190:	557d                	li	a0,-1
    80006192:	b7fd                	j	80006180 <sys_mknod+0x6c>

0000000080006194 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006194:	7135                	addi	sp,sp,-160
    80006196:	ed06                	sd	ra,152(sp)
    80006198:	e922                	sd	s0,144(sp)
    8000619a:	e14a                	sd	s2,128(sp)
    8000619c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000619e:	ffffc097          	auipc	ra,0xffffc
    800061a2:	8ca080e7          	jalr	-1846(ra) # 80001a68 <myproc>
    800061a6:	892a                	mv	s2,a0
  
  begin_op();
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	6bc080e7          	jalr	1724(ra) # 80004864 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061b0:	08000613          	li	a2,128
    800061b4:	f6040593          	addi	a1,s0,-160
    800061b8:	4501                	li	a0,0
    800061ba:	ffffd097          	auipc	ra,0xffffd
    800061be:	fba080e7          	jalr	-70(ra) # 80003174 <argstr>
    800061c2:	04054d63          	bltz	a0,8000621c <sys_chdir+0x88>
    800061c6:	e526                	sd	s1,136(sp)
    800061c8:	f6040513          	addi	a0,s0,-160
    800061cc:	ffffe097          	auipc	ra,0xffffe
    800061d0:	492080e7          	jalr	1170(ra) # 8000465e <namei>
    800061d4:	84aa                	mv	s1,a0
    800061d6:	c131                	beqz	a0,8000621a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800061d8:	ffffe097          	auipc	ra,0xffffe
    800061dc:	ca2080e7          	jalr	-862(ra) # 80003e7a <ilock>
  if(ip->type != T_DIR){
    800061e0:	04449703          	lh	a4,68(s1)
    800061e4:	4785                	li	a5,1
    800061e6:	04f71163          	bne	a4,a5,80006228 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800061ea:	8526                	mv	a0,s1
    800061ec:	ffffe097          	auipc	ra,0xffffe
    800061f0:	d54080e7          	jalr	-684(ra) # 80003f40 <iunlock>
  iput(p->cwd);
    800061f4:	15093503          	ld	a0,336(s2)
    800061f8:	ffffe097          	auipc	ra,0xffffe
    800061fc:	e40080e7          	jalr	-448(ra) # 80004038 <iput>
  end_op();
    80006200:	ffffe097          	auipc	ra,0xffffe
    80006204:	6de080e7          	jalr	1758(ra) # 800048de <end_op>
  p->cwd = ip;
    80006208:	14993823          	sd	s1,336(s2)
  return 0;
    8000620c:	4501                	li	a0,0
    8000620e:	64aa                	ld	s1,136(sp)
}
    80006210:	60ea                	ld	ra,152(sp)
    80006212:	644a                	ld	s0,144(sp)
    80006214:	690a                	ld	s2,128(sp)
    80006216:	610d                	addi	sp,sp,160
    80006218:	8082                	ret
    8000621a:	64aa                	ld	s1,136(sp)
    end_op();
    8000621c:	ffffe097          	auipc	ra,0xffffe
    80006220:	6c2080e7          	jalr	1730(ra) # 800048de <end_op>
    return -1;
    80006224:	557d                	li	a0,-1
    80006226:	b7ed                	j	80006210 <sys_chdir+0x7c>
    iunlockput(ip);
    80006228:	8526                	mv	a0,s1
    8000622a:	ffffe097          	auipc	ra,0xffffe
    8000622e:	eb6080e7          	jalr	-330(ra) # 800040e0 <iunlockput>
    end_op();
    80006232:	ffffe097          	auipc	ra,0xffffe
    80006236:	6ac080e7          	jalr	1708(ra) # 800048de <end_op>
    return -1;
    8000623a:	557d                	li	a0,-1
    8000623c:	64aa                	ld	s1,136(sp)
    8000623e:	bfc9                	j	80006210 <sys_chdir+0x7c>

0000000080006240 <sys_exec>:

uint64
sys_exec(void)
{
    80006240:	7105                	addi	sp,sp,-480
    80006242:	ef86                	sd	ra,472(sp)
    80006244:	eba2                	sd	s0,464(sp)
    80006246:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006248:	e2840593          	addi	a1,s0,-472
    8000624c:	4505                	li	a0,1
    8000624e:	ffffd097          	auipc	ra,0xffffd
    80006252:	f06080e7          	jalr	-250(ra) # 80003154 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006256:	08000613          	li	a2,128
    8000625a:	f3040593          	addi	a1,s0,-208
    8000625e:	4501                	li	a0,0
    80006260:	ffffd097          	auipc	ra,0xffffd
    80006264:	f14080e7          	jalr	-236(ra) # 80003174 <argstr>
    80006268:	87aa                	mv	a5,a0
    return -1;
    8000626a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000626c:	0e07ce63          	bltz	a5,80006368 <sys_exec+0x128>
    80006270:	e7a6                	sd	s1,456(sp)
    80006272:	e3ca                	sd	s2,448(sp)
    80006274:	ff4e                	sd	s3,440(sp)
    80006276:	fb52                	sd	s4,432(sp)
    80006278:	f756                	sd	s5,424(sp)
    8000627a:	f35a                	sd	s6,416(sp)
    8000627c:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000627e:	e3040a13          	addi	s4,s0,-464
    80006282:	10000613          	li	a2,256
    80006286:	4581                	li	a1,0
    80006288:	8552                	mv	a0,s4
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	aac080e7          	jalr	-1364(ra) # 80000d36 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006292:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80006294:	89d2                	mv	s3,s4
    80006296:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006298:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000629c:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000629e:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062a2:	00391513          	slli	a0,s2,0x3
    800062a6:	85d6                	mv	a1,s5
    800062a8:	e2843783          	ld	a5,-472(s0)
    800062ac:	953e                	add	a0,a0,a5
    800062ae:	ffffd097          	auipc	ra,0xffffd
    800062b2:	de8080e7          	jalr	-536(ra) # 80003096 <fetchaddr>
    800062b6:	02054a63          	bltz	a0,800062ea <sys_exec+0xaa>
    if(uarg == 0){
    800062ba:	e2043783          	ld	a5,-480(s0)
    800062be:	cbb1                	beqz	a5,80006312 <sys_exec+0xd2>
    argv[i] = kalloc();
    800062c0:	ffffb097          	auipc	ra,0xffffb
    800062c4:	88a080e7          	jalr	-1910(ra) # 80000b4a <kalloc>
    800062c8:	85aa                	mv	a1,a0
    800062ca:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800062ce:	cd11                	beqz	a0,800062ea <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800062d0:	865a                	mv	a2,s6
    800062d2:	e2043503          	ld	a0,-480(s0)
    800062d6:	ffffd097          	auipc	ra,0xffffd
    800062da:	e12080e7          	jalr	-494(ra) # 800030e8 <fetchstr>
    800062de:	00054663          	bltz	a0,800062ea <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    800062e2:	0905                	addi	s2,s2,1
    800062e4:	09a1                	addi	s3,s3,8
    800062e6:	fb791ee3          	bne	s2,s7,800062a2 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ea:	100a0a13          	addi	s4,s4,256
    800062ee:	6088                	ld	a0,0(s1)
    800062f0:	c525                	beqz	a0,80006358 <sys_exec+0x118>
    kfree(argv[i]);
    800062f2:	ffffa097          	auipc	ra,0xffffa
    800062f6:	75a080e7          	jalr	1882(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062fa:	04a1                	addi	s1,s1,8
    800062fc:	ff4499e3          	bne	s1,s4,800062ee <sys_exec+0xae>
  return -1;
    80006300:	557d                	li	a0,-1
    80006302:	64be                	ld	s1,456(sp)
    80006304:	691e                	ld	s2,448(sp)
    80006306:	79fa                	ld	s3,440(sp)
    80006308:	7a5a                	ld	s4,432(sp)
    8000630a:	7aba                	ld	s5,424(sp)
    8000630c:	7b1a                	ld	s6,416(sp)
    8000630e:	6bfa                	ld	s7,408(sp)
    80006310:	a8a1                	j	80006368 <sys_exec+0x128>
      argv[i] = 0;
    80006312:	0009079b          	sext.w	a5,s2
    80006316:	e3040593          	addi	a1,s0,-464
    8000631a:	078e                	slli	a5,a5,0x3
    8000631c:	97ae                	add	a5,a5,a1
    8000631e:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80006322:	f3040513          	addi	a0,s0,-208
    80006326:	fffff097          	auipc	ra,0xfffff
    8000632a:	118080e7          	jalr	280(ra) # 8000543e <exec>
    8000632e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006330:	100a0a13          	addi	s4,s4,256
    80006334:	6088                	ld	a0,0(s1)
    80006336:	c901                	beqz	a0,80006346 <sys_exec+0x106>
    kfree(argv[i]);
    80006338:	ffffa097          	auipc	ra,0xffffa
    8000633c:	714080e7          	jalr	1812(ra) # 80000a4c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006340:	04a1                	addi	s1,s1,8
    80006342:	ff4499e3          	bne	s1,s4,80006334 <sys_exec+0xf4>
  return ret;
    80006346:	854a                	mv	a0,s2
    80006348:	64be                	ld	s1,456(sp)
    8000634a:	691e                	ld	s2,448(sp)
    8000634c:	79fa                	ld	s3,440(sp)
    8000634e:	7a5a                	ld	s4,432(sp)
    80006350:	7aba                	ld	s5,424(sp)
    80006352:	7b1a                	ld	s6,416(sp)
    80006354:	6bfa                	ld	s7,408(sp)
    80006356:	a809                	j	80006368 <sys_exec+0x128>
  return -1;
    80006358:	557d                	li	a0,-1
    8000635a:	64be                	ld	s1,456(sp)
    8000635c:	691e                	ld	s2,448(sp)
    8000635e:	79fa                	ld	s3,440(sp)
    80006360:	7a5a                	ld	s4,432(sp)
    80006362:	7aba                	ld	s5,424(sp)
    80006364:	7b1a                	ld	s6,416(sp)
    80006366:	6bfa                	ld	s7,408(sp)
}
    80006368:	60fe                	ld	ra,472(sp)
    8000636a:	645e                	ld	s0,464(sp)
    8000636c:	613d                	addi	sp,sp,480
    8000636e:	8082                	ret

0000000080006370 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006370:	7139                	addi	sp,sp,-64
    80006372:	fc06                	sd	ra,56(sp)
    80006374:	f822                	sd	s0,48(sp)
    80006376:	f426                	sd	s1,40(sp)
    80006378:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000637a:	ffffb097          	auipc	ra,0xffffb
    8000637e:	6ee080e7          	jalr	1774(ra) # 80001a68 <myproc>
    80006382:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006384:	fd840593          	addi	a1,s0,-40
    80006388:	4501                	li	a0,0
    8000638a:	ffffd097          	auipc	ra,0xffffd
    8000638e:	dca080e7          	jalr	-566(ra) # 80003154 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006392:	fc840593          	addi	a1,s0,-56
    80006396:	fd040513          	addi	a0,s0,-48
    8000639a:	fffff097          	auipc	ra,0xfffff
    8000639e:	d0e080e7          	jalr	-754(ra) # 800050a8 <pipealloc>
    return -1;
    800063a2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800063a4:	0c054463          	bltz	a0,8000646c <sys_pipe+0xfc>
  fd0 = -1;
    800063a8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800063ac:	fd043503          	ld	a0,-48(s0)
    800063b0:	fffff097          	auipc	ra,0xfffff
    800063b4:	4b6080e7          	jalr	1206(ra) # 80005866 <fdalloc>
    800063b8:	fca42223          	sw	a0,-60(s0)
    800063bc:	08054b63          	bltz	a0,80006452 <sys_pipe+0xe2>
    800063c0:	fc843503          	ld	a0,-56(s0)
    800063c4:	fffff097          	auipc	ra,0xfffff
    800063c8:	4a2080e7          	jalr	1186(ra) # 80005866 <fdalloc>
    800063cc:	fca42023          	sw	a0,-64(s0)
    800063d0:	06054863          	bltz	a0,80006440 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063d4:	4691                	li	a3,4
    800063d6:	fc440613          	addi	a2,s0,-60
    800063da:	fd843583          	ld	a1,-40(s0)
    800063de:	68a8                	ld	a0,80(s1)
    800063e0:	ffffb097          	auipc	ra,0xffffb
    800063e4:	330080e7          	jalr	816(ra) # 80001710 <copyout>
    800063e8:	02054063          	bltz	a0,80006408 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063ec:	4691                	li	a3,4
    800063ee:	fc040613          	addi	a2,s0,-64
    800063f2:	fd843583          	ld	a1,-40(s0)
    800063f6:	95b6                	add	a1,a1,a3
    800063f8:	68a8                	ld	a0,80(s1)
    800063fa:	ffffb097          	auipc	ra,0xffffb
    800063fe:	316080e7          	jalr	790(ra) # 80001710 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006402:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006404:	06055463          	bgez	a0,8000646c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006408:	fc442783          	lw	a5,-60(s0)
    8000640c:	07e9                	addi	a5,a5,26
    8000640e:	078e                	slli	a5,a5,0x3
    80006410:	97a6                	add	a5,a5,s1
    80006412:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006416:	fc042783          	lw	a5,-64(s0)
    8000641a:	07e9                	addi	a5,a5,26
    8000641c:	078e                	slli	a5,a5,0x3
    8000641e:	94be                	add	s1,s1,a5
    80006420:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006424:	fd043503          	ld	a0,-48(s0)
    80006428:	fffff097          	auipc	ra,0xfffff
    8000642c:	90c080e7          	jalr	-1780(ra) # 80004d34 <fileclose>
    fileclose(wf);
    80006430:	fc843503          	ld	a0,-56(s0)
    80006434:	fffff097          	auipc	ra,0xfffff
    80006438:	900080e7          	jalr	-1792(ra) # 80004d34 <fileclose>
    return -1;
    8000643c:	57fd                	li	a5,-1
    8000643e:	a03d                	j	8000646c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006440:	fc442783          	lw	a5,-60(s0)
    80006444:	0007c763          	bltz	a5,80006452 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006448:	07e9                	addi	a5,a5,26
    8000644a:	078e                	slli	a5,a5,0x3
    8000644c:	97a6                	add	a5,a5,s1
    8000644e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006452:	fd043503          	ld	a0,-48(s0)
    80006456:	fffff097          	auipc	ra,0xfffff
    8000645a:	8de080e7          	jalr	-1826(ra) # 80004d34 <fileclose>
    fileclose(wf);
    8000645e:	fc843503          	ld	a0,-56(s0)
    80006462:	fffff097          	auipc	ra,0xfffff
    80006466:	8d2080e7          	jalr	-1838(ra) # 80004d34 <fileclose>
    return -1;
    8000646a:	57fd                	li	a5,-1
}
    8000646c:	853e                	mv	a0,a5
    8000646e:	70e2                	ld	ra,56(sp)
    80006470:	7442                	ld	s0,48(sp)
    80006472:	74a2                	ld	s1,40(sp)
    80006474:	6121                	addi	sp,sp,64
    80006476:	8082                	ret
	...

0000000080006480 <kernelvec>:
    80006480:	7111                	addi	sp,sp,-256
    80006482:	e006                	sd	ra,0(sp)
    80006484:	e40a                	sd	sp,8(sp)
    80006486:	e80e                	sd	gp,16(sp)
    80006488:	ec12                	sd	tp,24(sp)
    8000648a:	f016                	sd	t0,32(sp)
    8000648c:	f41a                	sd	t1,40(sp)
    8000648e:	f81e                	sd	t2,48(sp)
    80006490:	fc22                	sd	s0,56(sp)
    80006492:	e0a6                	sd	s1,64(sp)
    80006494:	e4aa                	sd	a0,72(sp)
    80006496:	e8ae                	sd	a1,80(sp)
    80006498:	ecb2                	sd	a2,88(sp)
    8000649a:	f0b6                	sd	a3,96(sp)
    8000649c:	f4ba                	sd	a4,104(sp)
    8000649e:	f8be                	sd	a5,112(sp)
    800064a0:	fcc2                	sd	a6,120(sp)
    800064a2:	e146                	sd	a7,128(sp)
    800064a4:	e54a                	sd	s2,136(sp)
    800064a6:	e94e                	sd	s3,144(sp)
    800064a8:	ed52                	sd	s4,152(sp)
    800064aa:	f156                	sd	s5,160(sp)
    800064ac:	f55a                	sd	s6,168(sp)
    800064ae:	f95e                	sd	s7,176(sp)
    800064b0:	fd62                	sd	s8,184(sp)
    800064b2:	e1e6                	sd	s9,192(sp)
    800064b4:	e5ea                	sd	s10,200(sp)
    800064b6:	e9ee                	sd	s11,208(sp)
    800064b8:	edf2                	sd	t3,216(sp)
    800064ba:	f1f6                	sd	t4,224(sp)
    800064bc:	f5fa                	sd	t5,232(sp)
    800064be:	f9fe                	sd	t6,240(sp)
    800064c0:	aa3fc0ef          	jal	80002f62 <kerneltrap>
    800064c4:	6082                	ld	ra,0(sp)
    800064c6:	6122                	ld	sp,8(sp)
    800064c8:	61c2                	ld	gp,16(sp)
    800064ca:	7282                	ld	t0,32(sp)
    800064cc:	7322                	ld	t1,40(sp)
    800064ce:	73c2                	ld	t2,48(sp)
    800064d0:	7462                	ld	s0,56(sp)
    800064d2:	6486                	ld	s1,64(sp)
    800064d4:	6526                	ld	a0,72(sp)
    800064d6:	65c6                	ld	a1,80(sp)
    800064d8:	6666                	ld	a2,88(sp)
    800064da:	7686                	ld	a3,96(sp)
    800064dc:	7726                	ld	a4,104(sp)
    800064de:	77c6                	ld	a5,112(sp)
    800064e0:	7866                	ld	a6,120(sp)
    800064e2:	688a                	ld	a7,128(sp)
    800064e4:	692a                	ld	s2,136(sp)
    800064e6:	69ca                	ld	s3,144(sp)
    800064e8:	6a6a                	ld	s4,152(sp)
    800064ea:	7a8a                	ld	s5,160(sp)
    800064ec:	7b2a                	ld	s6,168(sp)
    800064ee:	7bca                	ld	s7,176(sp)
    800064f0:	7c6a                	ld	s8,184(sp)
    800064f2:	6c8e                	ld	s9,192(sp)
    800064f4:	6d2e                	ld	s10,200(sp)
    800064f6:	6dce                	ld	s11,208(sp)
    800064f8:	6e6e                	ld	t3,216(sp)
    800064fa:	7e8e                	ld	t4,224(sp)
    800064fc:	7f2e                	ld	t5,232(sp)
    800064fe:	7fce                	ld	t6,240(sp)
    80006500:	6111                	addi	sp,sp,256
    80006502:	10200073          	sret
    80006506:	00000013          	nop
    8000650a:	00000013          	nop
    8000650e:	0001                	nop

0000000080006510 <timervec>:
    80006510:	34051573          	csrrw	a0,mscratch,a0
    80006514:	e10c                	sd	a1,0(a0)
    80006516:	e510                	sd	a2,8(a0)
    80006518:	e914                	sd	a3,16(a0)
    8000651a:	6d0c                	ld	a1,24(a0)
    8000651c:	7110                	ld	a2,32(a0)
    8000651e:	6194                	ld	a3,0(a1)
    80006520:	96b2                	add	a3,a3,a2
    80006522:	e194                	sd	a3,0(a1)
    80006524:	4589                	li	a1,2
    80006526:	14459073          	csrw	sip,a1
    8000652a:	6914                	ld	a3,16(a0)
    8000652c:	6510                	ld	a2,8(a0)
    8000652e:	610c                	ld	a1,0(a0)
    80006530:	34051573          	csrrw	a0,mscratch,a0
    80006534:	30200073          	mret
	...

000000008000653a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000653a:	1141                	addi	sp,sp,-16
    8000653c:	e406                	sd	ra,8(sp)
    8000653e:	e022                	sd	s0,0(sp)
    80006540:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006542:	0c000737          	lui	a4,0xc000
    80006546:	4785                	li	a5,1
    80006548:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000654a:	c35c                	sw	a5,4(a4)
}
    8000654c:	60a2                	ld	ra,8(sp)
    8000654e:	6402                	ld	s0,0(sp)
    80006550:	0141                	addi	sp,sp,16
    80006552:	8082                	ret

0000000080006554 <plicinithart>:

void
plicinithart(void)
{
    80006554:	1141                	addi	sp,sp,-16
    80006556:	e406                	sd	ra,8(sp)
    80006558:	e022                	sd	s0,0(sp)
    8000655a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000655c:	ffffb097          	auipc	ra,0xffffb
    80006560:	4d8080e7          	jalr	1240(ra) # 80001a34 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006564:	0085171b          	slliw	a4,a0,0x8
    80006568:	0c0027b7          	lui	a5,0xc002
    8000656c:	97ba                	add	a5,a5,a4
    8000656e:	40200713          	li	a4,1026
    80006572:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006576:	00d5151b          	slliw	a0,a0,0xd
    8000657a:	0c2017b7          	lui	a5,0xc201
    8000657e:	97aa                	add	a5,a5,a0
    80006580:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006584:	60a2                	ld	ra,8(sp)
    80006586:	6402                	ld	s0,0(sp)
    80006588:	0141                	addi	sp,sp,16
    8000658a:	8082                	ret

000000008000658c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000658c:	1141                	addi	sp,sp,-16
    8000658e:	e406                	sd	ra,8(sp)
    80006590:	e022                	sd	s0,0(sp)
    80006592:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006594:	ffffb097          	auipc	ra,0xffffb
    80006598:	4a0080e7          	jalr	1184(ra) # 80001a34 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000659c:	00d5151b          	slliw	a0,a0,0xd
    800065a0:	0c2017b7          	lui	a5,0xc201
    800065a4:	97aa                	add	a5,a5,a0
  return irq;
}
    800065a6:	43c8                	lw	a0,4(a5)
    800065a8:	60a2                	ld	ra,8(sp)
    800065aa:	6402                	ld	s0,0(sp)
    800065ac:	0141                	addi	sp,sp,16
    800065ae:	8082                	ret

00000000800065b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800065b0:	1101                	addi	sp,sp,-32
    800065b2:	ec06                	sd	ra,24(sp)
    800065b4:	e822                	sd	s0,16(sp)
    800065b6:	e426                	sd	s1,8(sp)
    800065b8:	1000                	addi	s0,sp,32
    800065ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800065bc:	ffffb097          	auipc	ra,0xffffb
    800065c0:	478080e7          	jalr	1144(ra) # 80001a34 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800065c4:	00d5179b          	slliw	a5,a0,0xd
    800065c8:	0c201737          	lui	a4,0xc201
    800065cc:	97ba                	add	a5,a5,a4
    800065ce:	c3c4                	sw	s1,4(a5)
}
    800065d0:	60e2                	ld	ra,24(sp)
    800065d2:	6442                	ld	s0,16(sp)
    800065d4:	64a2                	ld	s1,8(sp)
    800065d6:	6105                	addi	sp,sp,32
    800065d8:	8082                	ret

00000000800065da <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800065da:	1141                	addi	sp,sp,-16
    800065dc:	e406                	sd	ra,8(sp)
    800065de:	e022                	sd	s0,0(sp)
    800065e0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800065e2:	479d                	li	a5,7
    800065e4:	04a7cc63          	blt	a5,a0,8000663c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800065e8:	0001f797          	auipc	a5,0x1f
    800065ec:	a4878793          	addi	a5,a5,-1464 # 80025030 <disk>
    800065f0:	97aa                	add	a5,a5,a0
    800065f2:	0187c783          	lbu	a5,24(a5)
    800065f6:	ebb9                	bnez	a5,8000664c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800065f8:	00451693          	slli	a3,a0,0x4
    800065fc:	0001f797          	auipc	a5,0x1f
    80006600:	a3478793          	addi	a5,a5,-1484 # 80025030 <disk>
    80006604:	6398                	ld	a4,0(a5)
    80006606:	9736                	add	a4,a4,a3
    80006608:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    8000660c:	6398                	ld	a4,0(a5)
    8000660e:	9736                	add	a4,a4,a3
    80006610:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006614:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006618:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000661c:	97aa                	add	a5,a5,a0
    8000661e:	4705                	li	a4,1
    80006620:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006624:	0001f517          	auipc	a0,0x1f
    80006628:	a2450513          	addi	a0,a0,-1500 # 80025048 <disk+0x18>
    8000662c:	ffffc097          	auipc	ra,0xffffc
    80006630:	ec0080e7          	jalr	-320(ra) # 800024ec <wakeup>
}
    80006634:	60a2                	ld	ra,8(sp)
    80006636:	6402                	ld	s0,0(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret
    panic("free_desc 1");
    8000663c:	00002517          	auipc	a0,0x2
    80006640:	fec50513          	addi	a0,a0,-20 # 80008628 <etext+0x628>
    80006644:	ffffa097          	auipc	ra,0xffffa
    80006648:	f1c080e7          	jalr	-228(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000664c:	00002517          	auipc	a0,0x2
    80006650:	fec50513          	addi	a0,a0,-20 # 80008638 <etext+0x638>
    80006654:	ffffa097          	auipc	ra,0xffffa
    80006658:	f0c080e7          	jalr	-244(ra) # 80000560 <panic>

000000008000665c <virtio_disk_init>:
{
    8000665c:	1101                	addi	sp,sp,-32
    8000665e:	ec06                	sd	ra,24(sp)
    80006660:	e822                	sd	s0,16(sp)
    80006662:	e426                	sd	s1,8(sp)
    80006664:	e04a                	sd	s2,0(sp)
    80006666:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006668:	00002597          	auipc	a1,0x2
    8000666c:	fe058593          	addi	a1,a1,-32 # 80008648 <etext+0x648>
    80006670:	0001f517          	auipc	a0,0x1f
    80006674:	ae850513          	addi	a0,a0,-1304 # 80025158 <disk+0x128>
    80006678:	ffffa097          	auipc	ra,0xffffa
    8000667c:	532080e7          	jalr	1330(ra) # 80000baa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006680:	100017b7          	lui	a5,0x10001
    80006684:	4398                	lw	a4,0(a5)
    80006686:	2701                	sext.w	a4,a4
    80006688:	747277b7          	lui	a5,0x74727
    8000668c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006690:	16f71463          	bne	a4,a5,800067f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006694:	100017b7          	lui	a5,0x10001
    80006698:	43dc                	lw	a5,4(a5)
    8000669a:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000669c:	4709                	li	a4,2
    8000669e:	14e79d63          	bne	a5,a4,800067f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066a2:	100017b7          	lui	a5,0x10001
    800066a6:	479c                	lw	a5,8(a5)
    800066a8:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800066aa:	14e79763          	bne	a5,a4,800067f8 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800066ae:	100017b7          	lui	a5,0x10001
    800066b2:	47d8                	lw	a4,12(a5)
    800066b4:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066b6:	554d47b7          	lui	a5,0x554d4
    800066ba:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800066be:	12f71d63          	bne	a4,a5,800067f8 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066c2:	100017b7          	lui	a5,0x10001
    800066c6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ca:	4705                	li	a4,1
    800066cc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ce:	470d                	li	a4,3
    800066d0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800066d2:	10001737          	lui	a4,0x10001
    800066d6:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800066d8:	c7ffe6b7          	lui	a3,0xc7ffe
    800066dc:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd95ef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800066e0:	8f75                	and	a4,a4,a3
    800066e2:	100016b7          	lui	a3,0x10001
    800066e6:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066e8:	472d                	li	a4,11
    800066ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ec:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800066f0:	439c                	lw	a5,0(a5)
    800066f2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800066f6:	8ba1                	andi	a5,a5,8
    800066f8:	10078863          	beqz	a5,80006808 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800066fc:	100017b7          	lui	a5,0x10001
    80006700:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006704:	43fc                	lw	a5,68(a5)
    80006706:	2781                	sext.w	a5,a5
    80006708:	10079863          	bnez	a5,80006818 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000670c:	100017b7          	lui	a5,0x10001
    80006710:	5bdc                	lw	a5,52(a5)
    80006712:	2781                	sext.w	a5,a5
  if(max == 0)
    80006714:	10078a63          	beqz	a5,80006828 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006718:	471d                	li	a4,7
    8000671a:	10f77f63          	bgeu	a4,a5,80006838 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    8000671e:	ffffa097          	auipc	ra,0xffffa
    80006722:	42c080e7          	jalr	1068(ra) # 80000b4a <kalloc>
    80006726:	0001f497          	auipc	s1,0x1f
    8000672a:	90a48493          	addi	s1,s1,-1782 # 80025030 <disk>
    8000672e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	41a080e7          	jalr	1050(ra) # 80000b4a <kalloc>
    80006738:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000673a:	ffffa097          	auipc	ra,0xffffa
    8000673e:	410080e7          	jalr	1040(ra) # 80000b4a <kalloc>
    80006742:	87aa                	mv	a5,a0
    80006744:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006746:	6088                	ld	a0,0(s1)
    80006748:	10050063          	beqz	a0,80006848 <virtio_disk_init+0x1ec>
    8000674c:	0001f717          	auipc	a4,0x1f
    80006750:	8ec73703          	ld	a4,-1812(a4) # 80025038 <disk+0x8>
    80006754:	cb75                	beqz	a4,80006848 <virtio_disk_init+0x1ec>
    80006756:	cbed                	beqz	a5,80006848 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006758:	6605                	lui	a2,0x1
    8000675a:	4581                	li	a1,0
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	5da080e7          	jalr	1498(ra) # 80000d36 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006764:	0001f497          	auipc	s1,0x1f
    80006768:	8cc48493          	addi	s1,s1,-1844 # 80025030 <disk>
    8000676c:	6605                	lui	a2,0x1
    8000676e:	4581                	li	a1,0
    80006770:	6488                	ld	a0,8(s1)
    80006772:	ffffa097          	auipc	ra,0xffffa
    80006776:	5c4080e7          	jalr	1476(ra) # 80000d36 <memset>
  memset(disk.used, 0, PGSIZE);
    8000677a:	6605                	lui	a2,0x1
    8000677c:	4581                	li	a1,0
    8000677e:	6888                	ld	a0,16(s1)
    80006780:	ffffa097          	auipc	ra,0xffffa
    80006784:	5b6080e7          	jalr	1462(ra) # 80000d36 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006788:	100017b7          	lui	a5,0x10001
    8000678c:	4721                	li	a4,8
    8000678e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006790:	4098                	lw	a4,0(s1)
    80006792:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006796:	40d8                	lw	a4,4(s1)
    80006798:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000679c:	649c                	ld	a5,8(s1)
    8000679e:	0007869b          	sext.w	a3,a5
    800067a2:	10001737          	lui	a4,0x10001
    800067a6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800067aa:	9781                	srai	a5,a5,0x20
    800067ac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800067b0:	689c                	ld	a5,16(s1)
    800067b2:	0007869b          	sext.w	a3,a5
    800067b6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800067ba:	9781                	srai	a5,a5,0x20
    800067bc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800067c0:	4785                	li	a5,1
    800067c2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800067c4:	00f48c23          	sb	a5,24(s1)
    800067c8:	00f48ca3          	sb	a5,25(s1)
    800067cc:	00f48d23          	sb	a5,26(s1)
    800067d0:	00f48da3          	sb	a5,27(s1)
    800067d4:	00f48e23          	sb	a5,28(s1)
    800067d8:	00f48ea3          	sb	a5,29(s1)
    800067dc:	00f48f23          	sb	a5,30(s1)
    800067e0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800067e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800067e8:	07272823          	sw	s2,112(a4)
}
    800067ec:	60e2                	ld	ra,24(sp)
    800067ee:	6442                	ld	s0,16(sp)
    800067f0:	64a2                	ld	s1,8(sp)
    800067f2:	6902                	ld	s2,0(sp)
    800067f4:	6105                	addi	sp,sp,32
    800067f6:	8082                	ret
    panic("could not find virtio disk");
    800067f8:	00002517          	auipc	a0,0x2
    800067fc:	e6050513          	addi	a0,a0,-416 # 80008658 <etext+0x658>
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	d60080e7          	jalr	-672(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006808:	00002517          	auipc	a0,0x2
    8000680c:	e7050513          	addi	a0,a0,-400 # 80008678 <etext+0x678>
    80006810:	ffffa097          	auipc	ra,0xffffa
    80006814:	d50080e7          	jalr	-688(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006818:	00002517          	auipc	a0,0x2
    8000681c:	e8050513          	addi	a0,a0,-384 # 80008698 <etext+0x698>
    80006820:	ffffa097          	auipc	ra,0xffffa
    80006824:	d40080e7          	jalr	-704(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006828:	00002517          	auipc	a0,0x2
    8000682c:	e9050513          	addi	a0,a0,-368 # 800086b8 <etext+0x6b8>
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	d30080e7          	jalr	-720(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006838:	00002517          	auipc	a0,0x2
    8000683c:	ea050513          	addi	a0,a0,-352 # 800086d8 <etext+0x6d8>
    80006840:	ffffa097          	auipc	ra,0xffffa
    80006844:	d20080e7          	jalr	-736(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006848:	00002517          	auipc	a0,0x2
    8000684c:	eb050513          	addi	a0,a0,-336 # 800086f8 <etext+0x6f8>
    80006850:	ffffa097          	auipc	ra,0xffffa
    80006854:	d10080e7          	jalr	-752(ra) # 80000560 <panic>

0000000080006858 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006858:	711d                	addi	sp,sp,-96
    8000685a:	ec86                	sd	ra,88(sp)
    8000685c:	e8a2                	sd	s0,80(sp)
    8000685e:	e4a6                	sd	s1,72(sp)
    80006860:	e0ca                	sd	s2,64(sp)
    80006862:	fc4e                	sd	s3,56(sp)
    80006864:	f852                	sd	s4,48(sp)
    80006866:	f456                	sd	s5,40(sp)
    80006868:	f05a                	sd	s6,32(sp)
    8000686a:	ec5e                	sd	s7,24(sp)
    8000686c:	e862                	sd	s8,16(sp)
    8000686e:	1080                	addi	s0,sp,96
    80006870:	89aa                	mv	s3,a0
    80006872:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006874:	00c52b83          	lw	s7,12(a0)
    80006878:	001b9b9b          	slliw	s7,s7,0x1
    8000687c:	1b82                	slli	s7,s7,0x20
    8000687e:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006882:	0001f517          	auipc	a0,0x1f
    80006886:	8d650513          	addi	a0,a0,-1834 # 80025158 <disk+0x128>
    8000688a:	ffffa097          	auipc	ra,0xffffa
    8000688e:	3b4080e7          	jalr	948(ra) # 80000c3e <acquire>
  for(int i = 0; i < NUM; i++){
    80006892:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006894:	0001ea97          	auipc	s5,0x1e
    80006898:	79ca8a93          	addi	s5,s5,1948 # 80025030 <disk>
  for(int i = 0; i < 3; i++){
    8000689c:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    8000689e:	5c7d                	li	s8,-1
    800068a0:	a885                	j	80006910 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800068a2:	00fa8733          	add	a4,s5,a5
    800068a6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800068aa:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800068ac:	0207c563          	bltz	a5,800068d6 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    800068b0:	2905                	addiw	s2,s2,1
    800068b2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800068b4:	07490263          	beq	s2,s4,80006918 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    800068b8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800068ba:	0001e717          	auipc	a4,0x1e
    800068be:	77670713          	addi	a4,a4,1910 # 80025030 <disk>
    800068c2:	4781                	li	a5,0
    if(disk.free[i]){
    800068c4:	01874683          	lbu	a3,24(a4)
    800068c8:	fee9                	bnez	a3,800068a2 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    800068ca:	2785                	addiw	a5,a5,1
    800068cc:	0705                	addi	a4,a4,1
    800068ce:	fe979be3          	bne	a5,s1,800068c4 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    800068d2:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800068d6:	03205163          	blez	s2,800068f8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800068da:	fa042503          	lw	a0,-96(s0)
    800068de:	00000097          	auipc	ra,0x0
    800068e2:	cfc080e7          	jalr	-772(ra) # 800065da <free_desc>
      for(int j = 0; j < i; j++)
    800068e6:	4785                	li	a5,1
    800068e8:	0127d863          	bge	a5,s2,800068f8 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    800068ec:	fa442503          	lw	a0,-92(s0)
    800068f0:	00000097          	auipc	ra,0x0
    800068f4:	cea080e7          	jalr	-790(ra) # 800065da <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800068f8:	0001f597          	auipc	a1,0x1f
    800068fc:	86058593          	addi	a1,a1,-1952 # 80025158 <disk+0x128>
    80006900:	0001e517          	auipc	a0,0x1e
    80006904:	74850513          	addi	a0,a0,1864 # 80025048 <disk+0x18>
    80006908:	ffffc097          	auipc	ra,0xffffc
    8000690c:	b80080e7          	jalr	-1152(ra) # 80002488 <sleep>
  for(int i = 0; i < 3; i++){
    80006910:	fa040613          	addi	a2,s0,-96
    80006914:	4901                	li	s2,0
    80006916:	b74d                	j	800068b8 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006918:	fa042503          	lw	a0,-96(s0)
    8000691c:	00451693          	slli	a3,a0,0x4

  if(write)
    80006920:	0001e797          	auipc	a5,0x1e
    80006924:	71078793          	addi	a5,a5,1808 # 80025030 <disk>
    80006928:	00a50713          	addi	a4,a0,10
    8000692c:	0712                	slli	a4,a4,0x4
    8000692e:	973e                	add	a4,a4,a5
    80006930:	01603633          	snez	a2,s6
    80006934:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006936:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000693a:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000693e:	6398                	ld	a4,0(a5)
    80006940:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006942:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006946:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006948:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000694a:	6390                	ld	a2,0(a5)
    8000694c:	00d605b3          	add	a1,a2,a3
    80006950:	4741                	li	a4,16
    80006952:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006954:	4805                	li	a6,1
    80006956:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000695a:	fa442703          	lw	a4,-92(s0)
    8000695e:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006962:	0712                	slli	a4,a4,0x4
    80006964:	963a                	add	a2,a2,a4
    80006966:	05898593          	addi	a1,s3,88
    8000696a:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000696c:	0007b883          	ld	a7,0(a5)
    80006970:	9746                	add	a4,a4,a7
    80006972:	40000613          	li	a2,1024
    80006976:	c710                	sw	a2,8(a4)
  if(write)
    80006978:	001b3613          	seqz	a2,s6
    8000697c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006980:	01066633          	or	a2,a2,a6
    80006984:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006988:	fa842583          	lw	a1,-88(s0)
    8000698c:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006990:	00250613          	addi	a2,a0,2
    80006994:	0612                	slli	a2,a2,0x4
    80006996:	963e                	add	a2,a2,a5
    80006998:	577d                	li	a4,-1
    8000699a:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000699e:	0592                	slli	a1,a1,0x4
    800069a0:	98ae                	add	a7,a7,a1
    800069a2:	03068713          	addi	a4,a3,48
    800069a6:	973e                	add	a4,a4,a5
    800069a8:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800069ac:	6398                	ld	a4,0(a5)
    800069ae:	972e                	add	a4,a4,a1
    800069b0:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800069b4:	4689                	li	a3,2
    800069b6:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800069ba:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800069be:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800069c2:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800069c6:	6794                	ld	a3,8(a5)
    800069c8:	0026d703          	lhu	a4,2(a3)
    800069cc:	8b1d                	andi	a4,a4,7
    800069ce:	0706                	slli	a4,a4,0x1
    800069d0:	96ba                	add	a3,a3,a4
    800069d2:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800069d6:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800069da:	6798                	ld	a4,8(a5)
    800069dc:	00275783          	lhu	a5,2(a4)
    800069e0:	2785                	addiw	a5,a5,1
    800069e2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800069e6:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800069ea:	100017b7          	lui	a5,0x10001
    800069ee:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800069f2:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    800069f6:	0001e917          	auipc	s2,0x1e
    800069fa:	76290913          	addi	s2,s2,1890 # 80025158 <disk+0x128>
  while(b->disk == 1) {
    800069fe:	84c2                	mv	s1,a6
    80006a00:	01079c63          	bne	a5,a6,80006a18 <virtio_disk_rw+0x1c0>
    sleep(b, &disk.vdisk_lock);
    80006a04:	85ca                	mv	a1,s2
    80006a06:	854e                	mv	a0,s3
    80006a08:	ffffc097          	auipc	ra,0xffffc
    80006a0c:	a80080e7          	jalr	-1408(ra) # 80002488 <sleep>
  while(b->disk == 1) {
    80006a10:	0049a783          	lw	a5,4(s3)
    80006a14:	fe9788e3          	beq	a5,s1,80006a04 <virtio_disk_rw+0x1ac>
  }

  disk.info[idx[0]].b = 0;
    80006a18:	fa042903          	lw	s2,-96(s0)
    80006a1c:	00290713          	addi	a4,s2,2
    80006a20:	0712                	slli	a4,a4,0x4
    80006a22:	0001e797          	auipc	a5,0x1e
    80006a26:	60e78793          	addi	a5,a5,1550 # 80025030 <disk>
    80006a2a:	97ba                	add	a5,a5,a4
    80006a2c:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006a30:	0001e997          	auipc	s3,0x1e
    80006a34:	60098993          	addi	s3,s3,1536 # 80025030 <disk>
    80006a38:	00491713          	slli	a4,s2,0x4
    80006a3c:	0009b783          	ld	a5,0(s3)
    80006a40:	97ba                	add	a5,a5,a4
    80006a42:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a46:	854a                	mv	a0,s2
    80006a48:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a4c:	00000097          	auipc	ra,0x0
    80006a50:	b8e080e7          	jalr	-1138(ra) # 800065da <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a54:	8885                	andi	s1,s1,1
    80006a56:	f0ed                	bnez	s1,80006a38 <virtio_disk_rw+0x1e0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a58:	0001e517          	auipc	a0,0x1e
    80006a5c:	70050513          	addi	a0,a0,1792 # 80025158 <disk+0x128>
    80006a60:	ffffa097          	auipc	ra,0xffffa
    80006a64:	28e080e7          	jalr	654(ra) # 80000cee <release>
}
    80006a68:	60e6                	ld	ra,88(sp)
    80006a6a:	6446                	ld	s0,80(sp)
    80006a6c:	64a6                	ld	s1,72(sp)
    80006a6e:	6906                	ld	s2,64(sp)
    80006a70:	79e2                	ld	s3,56(sp)
    80006a72:	7a42                	ld	s4,48(sp)
    80006a74:	7aa2                	ld	s5,40(sp)
    80006a76:	7b02                	ld	s6,32(sp)
    80006a78:	6be2                	ld	s7,24(sp)
    80006a7a:	6c42                	ld	s8,16(sp)
    80006a7c:	6125                	addi	sp,sp,96
    80006a7e:	8082                	ret

0000000080006a80 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a80:	1101                	addi	sp,sp,-32
    80006a82:	ec06                	sd	ra,24(sp)
    80006a84:	e822                	sd	s0,16(sp)
    80006a86:	e426                	sd	s1,8(sp)
    80006a88:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a8a:	0001e497          	auipc	s1,0x1e
    80006a8e:	5a648493          	addi	s1,s1,1446 # 80025030 <disk>
    80006a92:	0001e517          	auipc	a0,0x1e
    80006a96:	6c650513          	addi	a0,a0,1734 # 80025158 <disk+0x128>
    80006a9a:	ffffa097          	auipc	ra,0xffffa
    80006a9e:	1a4080e7          	jalr	420(ra) # 80000c3e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006aa2:	100017b7          	lui	a5,0x10001
    80006aa6:	53bc                	lw	a5,96(a5)
    80006aa8:	8b8d                	andi	a5,a5,3
    80006aaa:	10001737          	lui	a4,0x10001
    80006aae:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006ab0:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006ab4:	689c                	ld	a5,16(s1)
    80006ab6:	0204d703          	lhu	a4,32(s1)
    80006aba:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006abe:	04f70863          	beq	a4,a5,80006b0e <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006ac2:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006ac6:	6898                	ld	a4,16(s1)
    80006ac8:	0204d783          	lhu	a5,32(s1)
    80006acc:	8b9d                	andi	a5,a5,7
    80006ace:	078e                	slli	a5,a5,0x3
    80006ad0:	97ba                	add	a5,a5,a4
    80006ad2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ad4:	00278713          	addi	a4,a5,2
    80006ad8:	0712                	slli	a4,a4,0x4
    80006ada:	9726                	add	a4,a4,s1
    80006adc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006ae0:	e721                	bnez	a4,80006b28 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006ae2:	0789                	addi	a5,a5,2
    80006ae4:	0792                	slli	a5,a5,0x4
    80006ae6:	97a6                	add	a5,a5,s1
    80006ae8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006aea:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006aee:	ffffc097          	auipc	ra,0xffffc
    80006af2:	9fe080e7          	jalr	-1538(ra) # 800024ec <wakeup>

    disk.used_idx += 1;
    80006af6:	0204d783          	lhu	a5,32(s1)
    80006afa:	2785                	addiw	a5,a5,1
    80006afc:	17c2                	slli	a5,a5,0x30
    80006afe:	93c1                	srli	a5,a5,0x30
    80006b00:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006b04:	6898                	ld	a4,16(s1)
    80006b06:	00275703          	lhu	a4,2(a4)
    80006b0a:	faf71ce3          	bne	a4,a5,80006ac2 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006b0e:	0001e517          	auipc	a0,0x1e
    80006b12:	64a50513          	addi	a0,a0,1610 # 80025158 <disk+0x128>
    80006b16:	ffffa097          	auipc	ra,0xffffa
    80006b1a:	1d8080e7          	jalr	472(ra) # 80000cee <release>
}
    80006b1e:	60e2                	ld	ra,24(sp)
    80006b20:	6442                	ld	s0,16(sp)
    80006b22:	64a2                	ld	s1,8(sp)
    80006b24:	6105                	addi	sp,sp,32
    80006b26:	8082                	ret
      panic("virtio_disk_intr status");
    80006b28:	00002517          	auipc	a0,0x2
    80006b2c:	be850513          	addi	a0,a0,-1048 # 80008710 <etext+0x710>
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	a30080e7          	jalr	-1488(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
