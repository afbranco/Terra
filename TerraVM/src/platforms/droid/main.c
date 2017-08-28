#define nx_struct struct
#define nx_union union
#define dbg(mode, format, ...) ((void)0)
#define dbg_clear(mode, format, ...) ((void)0)
#define dbg_active(mode) 0
# 149 "/usr/lib/gcc/x86_64-linux-gnu/5/include/stddef.h" 3
typedef long int ptrdiff_t;
#line 216
typedef long unsigned int size_t;
#line 328
typedef int wchar_t;
#line 429
#line 426
typedef struct __nesc_unnamed4242 {
  long long __max_align_ll __attribute((__aligned__(__alignof__(long long )))) ;
  long double __max_align_ld __attribute((__aligned__(__alignof__(long double )))) ;
} max_align_t;
# 8 "/usr/lib/x86_64-linux-gnu/ncc/deputy_nodeputy.h"
struct __nesc_attr_nonnull {
#line 8
  int dummy;
}  ;
#line 9
struct __nesc_attr_bnd {
#line 9
  void *lo, *hi;
}  ;
#line 10
struct __nesc_attr_bnd_nok {
#line 10
  void *lo, *hi;
}  ;
#line 11
struct __nesc_attr_count {
#line 11
  int n;
}  ;
#line 12
struct __nesc_attr_count_nok {
#line 12
  int n;
}  ;
#line 13
struct __nesc_attr_one {
#line 13
  int dummy;
}  ;
#line 14
struct __nesc_attr_one_nok {
#line 14
  int dummy;
}  ;
#line 15
struct __nesc_attr_dmemset {
#line 15
  int a1, a2, a3;
}  ;
#line 16
struct __nesc_attr_dmemcpy {
#line 16
  int a1, a2, a3;
}  ;
#line 17
struct __nesc_attr_nts {
#line 17
  int dummy;
}  ;
# 39 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/machine/_types.h"
typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef short __int16_t;
typedef unsigned short __uint16_t;
typedef int __int32_t;
typedef unsigned int __uint32_t;

typedef long long __int64_t;

typedef unsigned long long __uint64_t;


typedef __int8_t __int_least8_t;
typedef __uint8_t __uint_least8_t;
typedef __int16_t __int_least16_t;
typedef __uint16_t __uint_least16_t;
typedef __int32_t __int_least32_t;
typedef __uint32_t __uint_least32_t;
typedef __int64_t __int_least64_t;
typedef __uint64_t __uint_least64_t;


typedef __int32_t __int_fast8_t;
typedef __uint32_t __uint_fast8_t;
typedef __int32_t __int_fast16_t;
typedef __uint32_t __uint_fast16_t;
typedef __int32_t __int_fast32_t;
typedef __uint32_t __uint_fast32_t;
typedef __int64_t __int_fast64_t;
typedef __uint64_t __uint_fast64_t;


typedef int __intptr_t;
typedef unsigned int __uintptr_t;


typedef __int64_t __intmax_t;
typedef __uint64_t __uintmax_t;


typedef __int32_t __register_t;


typedef unsigned long __vaddr_t;
typedef unsigned long __paddr_t;
typedef unsigned long __vsize_t;
typedef unsigned long __psize_t;


typedef int __clock_t;
typedef int __clockid_t;
typedef long __ptrdiff_t;
typedef int __time_t;
typedef int __timer_t;

typedef __builtin_va_list __va_list;






typedef int __wchar_t;

typedef int __wint_t;
typedef int __rune_t;
typedef void *__wctrans_t;
typedef void *__wctype_t;
# 42 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/_types.h"
typedef unsigned long __cpuid_t;
typedef __int32_t __dev_t;
typedef __uint32_t __fixpt_t;
typedef __uint32_t __gid_t;
typedef __uint32_t __id_t;
typedef __uint32_t __in_addr_t;
typedef __uint16_t __in_port_t;
typedef __uint32_t __ino_t;
typedef long __key_t;
typedef __uint32_t __mode_t;
typedef __uint32_t __nlink_t;
typedef __int32_t __pid_t;
typedef __uint64_t __rlim_t;
typedef __uint16_t __sa_family_t;
typedef __int32_t __segsz_t;
typedef __uint32_t __socklen_t;
typedef __int32_t __swblk_t;
typedef __uint32_t __uid_t;
typedef __uint32_t __useconds_t;
typedef __int32_t __suseconds_t;








#line 67
typedef union __nesc_unnamed4243 {
  char __mbstate8[128];
  __int64_t __mbstateL;
} __mbstate_t;
# 42 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/stdint.h"
typedef __int8_t int8_t;
typedef __uint8_t uint8_t;
typedef __int16_t int16_t;
typedef __uint16_t uint16_t;
typedef __int32_t int32_t;
typedef __uint32_t uint32_t;
typedef __int64_t int64_t;
typedef __uint64_t uint64_t;





typedef int8_t int_least8_t;
typedef int8_t int_fast8_t;

typedef uint8_t uint_least8_t;
typedef uint8_t uint_fast8_t;
#line 88
typedef int16_t int_least16_t;
typedef int32_t int_fast16_t;

typedef uint16_t uint_least16_t;
typedef uint32_t uint_fast16_t;
#line 121
typedef int32_t int_least32_t;
typedef int32_t int_fast32_t;

typedef uint32_t uint_least32_t;
typedef uint32_t uint_fast32_t;
#line 154
typedef int64_t int_least64_t;
typedef int64_t int_fast64_t;

typedef uint64_t uint_least64_t;
typedef uint64_t uint_fast64_t;
#line 195
typedef long intptr_t;
typedef unsigned long uintptr_t;
#line 220
typedef uint64_t uintmax_t;
typedef int64_t intmax_t;
#line 254
typedef int ssize_t;
# 249 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/inttypes.h"
#line 246
typedef struct __nesc_unnamed4244 {
  intmax_t quot;
  intmax_t rem;
} imaxdiv_t;
# 281 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline uint8_t __nesc_ntoh_uint8(const void * source)  ;




static __inline uint8_t __nesc_hton_uint8(void * target, uint8_t value)  ;
#line 303
static __inline int8_t __nesc_ntoh_int8(const void * source)  ;
#line 303
static __inline int8_t __nesc_hton_int8(void * target, int8_t value)  ;






static __inline uint16_t __nesc_ntoh_uint16(const void * source)  ;




static __inline uint16_t __nesc_hton_uint16(void * target, uint16_t value)  ;
#line 334
static __inline int16_t __nesc_ntoh_int16(const void * source)  ;
#line 334
static __inline int16_t __nesc_hton_int16(void * target, int16_t value)  ;





static __inline uint32_t __nesc_ntoh_uint32(const void * source)  ;






static __inline uint32_t __nesc_hton_uint32(void * target, uint32_t value)  ;
#line 372
static __inline int32_t __nesc_ntoh_int32(const void * source)  ;
#line 372
static __inline int32_t __nesc_hton_int32(void * target, int32_t value)  ;
#line 431
typedef struct { unsigned char nxdata[1]; } __attribute__((packed)) nx_int8_t;typedef int8_t __nesc_nxbase_nx_int8_t  ;
typedef struct { unsigned char nxdata[2]; } __attribute__((packed)) nx_int16_t;typedef int16_t __nesc_nxbase_nx_int16_t  ;
typedef struct { unsigned char nxdata[4]; } __attribute__((packed)) nx_int32_t;typedef int32_t __nesc_nxbase_nx_int32_t  ;
typedef struct { unsigned char nxdata[8]; } __attribute__((packed)) nx_int64_t;typedef int64_t __nesc_nxbase_nx_int64_t  ;
typedef struct { unsigned char nxdata[1]; } __attribute__((packed)) nx_uint8_t;typedef uint8_t __nesc_nxbase_nx_uint8_t  ;
typedef struct { unsigned char nxdata[2]; } __attribute__((packed)) nx_uint16_t;typedef uint16_t __nesc_nxbase_nx_uint16_t  ;
typedef struct { unsigned char nxdata[4]; } __attribute__((packed)) nx_uint32_t;typedef uint32_t __nesc_nxbase_nx_uint32_t  ;
typedef struct { unsigned char nxdata[8]; } __attribute__((packed)) nx_uint64_t;typedef uint64_t __nesc_nxbase_nx_uint64_t  ;


typedef struct { unsigned char nxdata[1]; } __attribute__((packed)) nxle_int8_t;typedef int8_t __nesc_nxbase_nxle_int8_t  ;
typedef struct { unsigned char nxdata[2]; } __attribute__((packed)) nxle_int16_t;typedef int16_t __nesc_nxbase_nxle_int16_t  ;
typedef struct { unsigned char nxdata[4]; } __attribute__((packed)) nxle_int32_t;typedef int32_t __nesc_nxbase_nxle_int32_t  ;
typedef struct { unsigned char nxdata[8]; } __attribute__((packed)) nxle_int64_t;typedef int64_t __nesc_nxbase_nxle_int64_t  ;
typedef struct { unsigned char nxdata[1]; } __attribute__((packed)) nxle_uint8_t;typedef uint8_t __nesc_nxbase_nxle_uint8_t  ;
typedef struct { unsigned char nxdata[2]; } __attribute__((packed)) nxle_uint16_t;typedef uint16_t __nesc_nxbase_nxle_uint16_t  ;
typedef struct { unsigned char nxdata[4]; } __attribute__((packed)) nxle_uint32_t;typedef uint32_t __nesc_nxbase_nxle_uint32_t  ;
typedef struct { unsigned char nxdata[8]; } __attribute__((packed)) nxle_uint64_t;typedef uint64_t __nesc_nxbase_nxle_uint64_t  ;
# 43 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/malloc.h"
struct mallinfo {
  size_t arena;
  size_t ordblks;
  size_t smblks;
  size_t hblks;
  size_t hblkhd;
  size_t usmblks;
  size_t fsmblks;
  size_t uordblks;
  size_t fordblks;
  size_t keepcost;
};


struct mallinfo;
# 41 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/string.h"
extern void *memcpy(void *arg_0x7f7d47c2cbf0, const void *arg_0x7f7d47c2b020, size_t arg_0x7f7d47c2b2c8);

extern void *memset(void *arg_0x7f7d47c29980, int arg_0x7f7d47c29be8, size_t arg_0x7f7d47c28020);
# 34 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/posix_types.h"
#line 32
typedef struct __nesc_unnamed4245 {
  unsigned long fds_bits[1024 / (8 * sizeof(unsigned long ))];
} __kernel_fd_set;

typedef void (*__kernel_sighandler_t)(int arg_0x7f7d47c01c88);

typedef int __kernel_key_t;
typedef int __kernel_mqd_t;
# 15 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/posix_types.h"
typedef unsigned long __kernel_ino_t;
typedef unsigned short __kernel_mode_t;
typedef unsigned short __kernel_nlink_t;
typedef long __kernel_off_t;
typedef int __kernel_pid_t;
typedef unsigned short __kernel_ipc_pid_t;
typedef unsigned short __kernel_uid_t;
typedef unsigned short __kernel_gid_t;
typedef unsigned int __kernel_size_t;
typedef int __kernel_ssize_t;
typedef int __kernel_ptrdiff_t;
typedef long __kernel_time_t;
typedef long __kernel_suseconds_t;
typedef long __kernel_clock_t;
typedef int __kernel_timer_t;
typedef int __kernel_clockid_t;
typedef int __kernel_daddr_t;
typedef char *__kernel_caddr_t;
typedef unsigned short __kernel_uid16_t;
typedef unsigned short __kernel_gid16_t;
typedef unsigned int __kernel_uid32_t;
typedef unsigned int __kernel_gid32_t;

typedef unsigned short __kernel_old_uid_t;
typedef unsigned short __kernel_old_gid_t;
typedef unsigned short __kernel_old_dev_t;


typedef long long __kernel_loff_t;








#line 46
typedef struct __nesc_unnamed4246 {



  int __val[2];
} 
__kernel_fsid_t;
# 17 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/types.h"
typedef unsigned short umode_t;

typedef signed char __s8;
typedef unsigned char __u8;

typedef signed short __s16;
typedef unsigned short __u16;

typedef signed int __s32;
typedef unsigned int __u32;


typedef signed long long __s64;
typedef unsigned long long __u64;
# 21 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/types.h"
typedef __u16 __le16;
typedef __u16 __be16;
typedef __u32 __le32;
typedef __u32 __be32;

typedef __u64 __le64;
typedef __u64 __be64;


struct ustat {
  __kernel_daddr_t f_tfree;
  __kernel_ino_t f_tinode;
  char f_fname[6];
  char f_fpack[6];
};
# 34 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/machine/kernel.h"
typedef unsigned long __kernel_blkcnt_t;
typedef unsigned long __kernel_blksize_t;


typedef unsigned long __kernel_fsblkcnt_t;
typedef unsigned long __kernel_fsfilcnt_t;
typedef unsigned int __kernel_id_t;
# 42 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/types.h"
typedef __u32 __kernel_dev_t;









typedef __kernel_blkcnt_t blkcnt_t;
typedef __kernel_blksize_t blksize_t;
typedef __kernel_clock_t clock_t;
typedef __kernel_clockid_t clockid_t;
typedef __kernel_dev_t dev_t;
typedef __kernel_fsblkcnt_t fsblkcnt_t;
typedef __kernel_fsfilcnt_t fsfilcnt_t;
typedef __kernel_gid32_t gid_t;
typedef __kernel_id_t id_t;
typedef __kernel_ino_t ino_t;
typedef __kernel_key_t key_t;
typedef __kernel_mode_t mode_t;
typedef __kernel_nlink_t nlink_t;


typedef __kernel_off_t off_t;

typedef __kernel_loff_t loff_t;
typedef loff_t off64_t;

typedef __kernel_pid_t pid_t;
#line 93
typedef __kernel_suseconds_t suseconds_t;
typedef __kernel_time_t time_t;
typedef __kernel_uid32_t uid_t;
typedef signed long useconds_t;

typedef __kernel_daddr_t daddr_t;
typedef __kernel_timer_t timer_t;
typedef __kernel_mqd_t mqd_t;

typedef __kernel_caddr_t caddr_t;
typedef unsigned int uint_t;
typedef unsigned int uint;





typedef unsigned char u_char;
typedef unsigned short u_short;
typedef unsigned int u_int;
typedef unsigned long u_long;

typedef uint32_t u_int32_t;
typedef uint16_t u_int16_t;
typedef uint8_t u_int8_t;
typedef uint64_t u_int64_t;
# 50 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/stdlib.h"
extern __attribute((__noreturn__)) void exit(int arg_0x7f7d47bd4060);
#line 149
#line 146
typedef struct __nesc_unnamed4247 {
  int quot;
  int rem;
} div_t;






#line 153
typedef struct __nesc_unnamed4248 {
  long int quot;
  long int rem;
} ldiv_t;






#line 160
typedef struct __nesc_unnamed4249 {
  long long int quot;
  long long int rem;
} lldiv_t;
# 27 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/math.h"
union __infinity_un {
  unsigned char __uc[8];
  double __ud;
};

union __nan_un {
  unsigned char __uc[sizeof(float )];
  float __uf;
};
# 27 "/home/mauricio/Terra/TerraVM/src/system/tos.h"
typedef uint8_t bool;
enum __nesc_unnamed4250 {
#line 28
  FALSE = 0, TRUE = 1
};







typedef int64_t s64;
typedef uint64_t u64;
typedef int32_t s32;
typedef uint32_t u32;
typedef int16_t s16;
typedef uint16_t u16;
typedef int8_t s8;
typedef uint8_t u8;
typedef float f32;



typedef nx_int8_t nx_bool;





uint16_t TOS_NODE_ID = 4097;






struct __nesc_attr_atmostonce {
};
#line 63
struct __nesc_attr_atleastonce {
};
#line 64
struct __nesc_attr_exactlyonce {
};
#line 91
extern void dbgIx(char *canal, char *format, ...);
# 51 "/home/mauricio/Terra/TerraVM/src/system/TinyError.h"
enum __nesc_unnamed4251 {
  SUCCESS = 0, 
  FAIL = 1, 
  ESIZE = 2, 
  ECANCEL = 3, 
  EOFF = 4, 
  EBUSY = 5, 
  EINVAL = 6, 
  ERETRY = 7, 
  ERESERVE = 8, 
  EALREADY = 9, 
  ENOMEM = 10, 
  ENOACK = 11, 
  ELAST = 11
};

typedef uint8_t error_t  ;

static inline error_t ecombine(error_t r1, error_t r2)  ;
# 4 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
static __inline void __nesc_enable_interrupt();
static __inline void __nesc_disable_interrupt();

typedef uint8_t __nesc_atomic_t;
typedef uint8_t mcu_power_t;

__inline __nesc_atomic_t __nesc_atomic_start(void )  ;



__inline void __nesc_atomic_end(__nesc_atomic_t x)  ;



typedef struct { unsigned char nxdata[4]; } __attribute__((packed)) nx_float;typedef float __nesc_nxbase_nx_float  ;

static __inline float __nesc_ntoh_afloat(const void * source)  ;





static __inline float __nesc_hton_afloat(void * target, float value)  ;







enum __nesc_unnamed4252 {
  TOS_SLEEP_NONE = 0
};
# 30 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/poll.h"
struct pollfd {
  int fd;
  short events;
  short revents;
};
# 36 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/poll.h"
typedef unsigned int nfds_t;
# 19 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/time.h"
struct timespec {
  time_t tv_sec;
  long tv_nsec;
};


struct timeval {
  time_t tv_sec;
  suseconds_t tv_usec;
};

struct timezone {
  int tz_minuteswest;
  int tz_dsttime;
};
#line 47
struct itimerspec {
  struct timespec it_interval;
  struct timespec it_value;
};

struct itimerval {
  struct timeval it_interval;
  struct timeval it_value;
};
# 37 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/time.h"
extern int gettimeofday(struct timeval *arg_0x7f7d47acb468, struct timezone *arg_0x7f7d47acb7c0);
# 21 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm-generic/siginfo.h"
#line 18
typedef union sigval {
  int sival_int;
  void *sival_ptr;
} sigval_t;
#line 89
#line 42
typedef struct siginfo {
  int si_signo;
  int si_errno;
  int si_code;

  union __nesc_unnamed4253 {
    int _pad[(128 - 3 * sizeof(int )) / sizeof(int )];

    struct __nesc_unnamed4254 {
      pid_t _pid;
      __kernel_uid32_t _uid;
    } _kill;

    struct __nesc_unnamed4255 {
      timer_t _tid;
      int _overrun;
      char _pad[sizeof(__kernel_uid32_t ) - sizeof(int )];
      sigval_t _sigval;
      int _sys_private;
    } _timer;

    struct __nesc_unnamed4256 {
      pid_t _pid;
      __kernel_uid32_t _uid;
      sigval_t _sigval;
    } _rt;

    struct __nesc_unnamed4257 {
      pid_t _pid;
      __kernel_uid32_t _uid;
      int _status;
      clock_t _utime;
      clock_t _stime;
    } _sigchld;

    struct __nesc_unnamed4258 {
      void *_addr;
    } 


    _sigfault;

    struct __nesc_unnamed4259 {
      long _band;
      int _fd;
    } _sigpoll;
  } _sifields;
} siginfo_t;
#line 207
#line 194
typedef struct sigevent {
  sigval_t sigev_value;
  int sigev_signo;
  int sigev_notify;
  union __nesc_unnamed4260 {
    int _pad[(64 - (sizeof(int ) * 2 + sizeof(sigval_t ))) / sizeof(int )];
    int _tid;

    struct __nesc_unnamed4261 {
      void (*_function)(sigval_t arg_0x7f7d47ab85b0);
      void *_attribute;
    } _sigev_thread;
  } _sigev_un;
} sigevent_t;
# 45 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/time.h"
struct tm {
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;

  long int tm_gmtoff;
  const char *tm_zone;
};
#line 73
struct tm;
struct tm;

struct tm;
struct tm;
# 17 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/signal.h"
struct siginfo;


typedef unsigned long sigset_t;
# 28 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm-generic/signal.h"
typedef void __signalfn_t(int arg_0x7f7d47a93498);
typedef __signalfn_t *__sighandler_t;

typedef void __restorefn_t(void );
typedef __restorefn_t *__sigrestore_t;
# 84 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/signal.h"
struct sigaction {
  union __nesc_unnamed4262 {
    __sighandler_t _sa_handler;
    void (*_sa_sigaction)(int arg_0x7f7d47a915a0, struct siginfo *arg_0x7f7d47a918e8, void *arg_0x7f7d47a91b88);
  } _u;
  sigset_t sa_mask;
  unsigned long sa_flags;
  void (*sa_restorer)(void );
};








#line 97
typedef struct sigaltstack {
  void *ss_sp;
  int ss_flags;
  size_t ss_size;
} stack_t;
# 15 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm/sigcontext.h"
struct sigcontext {
  unsigned long trap_no;
  unsigned long error_code;
  unsigned long oldmask;
  unsigned long arm_r0;
  unsigned long arm_r1;
  unsigned long arm_r2;
  unsigned long arm_r3;
  unsigned long arm_r4;
  unsigned long arm_r5;
  unsigned long arm_r6;
  unsigned long arm_r7;
  unsigned long arm_r8;
  unsigned long arm_r9;
  unsigned long arm_r10;
  unsigned long arm_fp;
  unsigned long arm_ip;
  unsigned long arm_sp;
  unsigned long arm_lr;
  unsigned long arm_pc;
  unsigned long arm_cpsr;
  unsigned long fault_address;
};
# 104 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/user.h"
struct user_fpregs_struct {
  unsigned short cwd;
  unsigned short swd;
  unsigned short ftw;
  unsigned short fop;
  __u64 rip;
  __u64 rdp;
  __u32 mxcsr;
  __u32 mxcsr_mask;
  __u32 st_space[32];
  __u32 xmm_space[64];
  __u32 padding[24];
};
struct user_regs_struct {
  unsigned long r15;
  unsigned long r14;
  unsigned long r13;
  unsigned long r12;
  unsigned long rbp;
  unsigned long rbx;
  unsigned long r11;
  unsigned long r10;
  unsigned long r9;
  unsigned long r8;
  unsigned long rax;
  unsigned long rcx;
  unsigned long rdx;
  unsigned long rsi;
  unsigned long rdi;
  unsigned long orig_rax;
  unsigned long rip;
  unsigned long cs;
  unsigned long eflags;
  unsigned long rsp;
  unsigned long ss;
  unsigned long fs_base;
  unsigned long gs_base;
  unsigned long ds;
  unsigned long es;
  unsigned long fs;
  unsigned long gs;
};
struct user {
  struct user_regs_struct regs;
  int u_fpvalid;
  int pad0;
  struct user_fpregs_struct i387;
  unsigned long int u_tsize;
  unsigned long int u_dsize;
  unsigned long int u_ssize;
  unsigned long start_code;
  unsigned long start_stack;
  long int signal;
  int reserved;
  int pad1;
  unsigned long u_ar0;
  struct user_fpregs_struct *u_fpstate;
  unsigned long magic;
  char u_comm[32];
  unsigned long u_debugreg[8];
  unsigned long error_code;
  unsigned long fault_address;
};
# 214 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/ucontext.h"
enum __nesc_unnamed4263 {
  REG_R8 = 0, 
  REG_R9, 
  REG_R10, 
  REG_R11, 
  REG_R12, 
  REG_R13, 
  REG_R14, 
  REG_R15, 
  REG_RDI, 
  REG_RSI, 
  REG_RBP, 
  REG_RBX, 
  REG_RDX, 
  REG_RAX, 
  REG_RCX, 
  REG_RSP, 
  REG_RIP, 
  REG_EFL, 
  REG_CSGSFS, 
  REG_ERR, 
  REG_TRAPNO, 
  REG_OLDMASK, 
  REG_CR2, 
  NGREG
};

typedef long greg_t;
typedef greg_t gregset_t[NGREG];

struct _libc_fpxreg {
  unsigned short significand[4];
  unsigned short exponent;
  unsigned short padding[3];
};

struct _libc_xmmreg {
  uint32_t element[4];
};

struct _libc_fpstate {
  uint16_t cwd;
  uint16_t swd;
  uint16_t ftw;
  uint16_t fop;
  uint64_t rip;
  uint64_t rdp;
  uint32_t mxcsr;
  uint32_t mxcr_mask;
  struct _libc_fpxreg _st[8];
  struct _libc_xmmreg _xmm[16];
  uint32_t padding[24];
};

typedef struct _libc_fpstate *fpregset_t;





#line 270
typedef struct __nesc_unnamed4264 {
  gregset_t gregs;
  fpregset_t fpregs;
  unsigned long __reserved1[8];
} mcontext_t;








#line 276
typedef struct ucontext {
  unsigned long uc_flags;
  struct ucontext *uc_link;
  stack_t uc_stack;
  mcontext_t uc_mcontext;
  sigset_t uc_sigmask;
  struct _libc_fpstate __fpregs_mem;
} ucontext_t;
# 47 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/signal.h"
typedef int sig_atomic_t;
#line 89
static __inline int sigemptyset(sigset_t *set);
#line 103
typedef void (*sig_t)(int arg_0x7f7d47a5d540);
typedef sig_t sighandler_t;
#line 120
extern int sigaction(int arg_0x7f7d47a55020, const struct sigaction *arg_0x7f7d47a553b8, struct sigaction *arg_0x7f7d47a55718);
# 41 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sched.h"
struct sched_param {
  int sched_priority;
};
# 43 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/pthread.h"
#line 40
typedef struct __nesc_unnamed4265 {

  int volatile value;
} pthread_mutex_t;









enum __nesc_unnamed4266 {
  PTHREAD_MUTEX_NORMAL = 0, 
  PTHREAD_MUTEX_RECURSIVE = 1, 
  PTHREAD_MUTEX_ERRORCHECK = 2, 

  PTHREAD_MUTEX_ERRORCHECK_NP = PTHREAD_MUTEX_ERRORCHECK, 
  PTHREAD_MUTEX_RECURSIVE_NP = PTHREAD_MUTEX_RECURSIVE, 

  PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL
};






#line 66
typedef struct __nesc_unnamed4267 {

  int volatile value;
} pthread_cond_t;









#line 71
typedef struct __nesc_unnamed4268 {

  uint32_t flags;
  void *stack_base;
  size_t stack_size;
  size_t guard_size;
  int32_t sched_policy;
  int32_t sched_priority;
} pthread_attr_t;

typedef long pthread_mutexattr_t;
typedef long pthread_condattr_t;

typedef int pthread_key_t;
typedef long pthread_t;

typedef volatile int pthread_once_t;
#line 232
typedef int pthread_rwlockattr_t;









#line 234
typedef struct __nesc_unnamed4269 {
  pthread_mutex_t lock;
  pthread_cond_t cond;
  int numLocks;
  int writerThreadId;
  int pendingReaders;
  int pendingWriters;
  void *reserved[4];
} pthread_rwlock_t;
#line 279
typedef void (*__pthread_cleanup_func_t)(void *arg_0x7f7d479e3378);





#line 281
typedef struct __pthread_cleanup_t {
  struct __pthread_cleanup_t *__cleanup_prev;
  __pthread_cleanup_func_t __cleanup_routine;
  void *__cleanup_arg;
} __pthread_cleanup_t;
# 27 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/asset_manager.h"
struct AAssetManager;
typedef struct AAssetManager AAssetManager;

struct AAssetDir;
typedef struct AAssetDir AAssetDir;

struct AAsset;
typedef struct AAsset AAsset;


enum __nesc_unnamed4270 {
  AASSET_MODE_UNKNOWN = 0, 
  AASSET_MODE_RANDOM = 1, 
  AASSET_MODE_STREAMING = 2, 
  AASSET_MODE_BUFFER = 3
};
# 26 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/configuration.h"
struct AConfiguration;
typedef struct AConfiguration AConfiguration;

enum __nesc_unnamed4271 {
  ACONFIGURATION_ORIENTATION_ANY = 0x0000, 
  ACONFIGURATION_ORIENTATION_PORT = 0x0001, 
  ACONFIGURATION_ORIENTATION_LAND = 0x0002, 
  ACONFIGURATION_ORIENTATION_SQUARE = 0x0003, 

  ACONFIGURATION_TOUCHSCREEN_ANY = 0x0000, 
  ACONFIGURATION_TOUCHSCREEN_NOTOUCH = 0x0001, 
  ACONFIGURATION_TOUCHSCREEN_STYLUS = 0x0002, 
  ACONFIGURATION_TOUCHSCREEN_FINGER = 0x0003, 

  ACONFIGURATION_DENSITY_DEFAULT = 0, 
  ACONFIGURATION_DENSITY_LOW = 120, 
  ACONFIGURATION_DENSITY_MEDIUM = 160, 
  ACONFIGURATION_DENSITY_HIGH = 240, 
  ACONFIGURATION_DENSITY_NONE = 0xffff, 

  ACONFIGURATION_KEYBOARD_ANY = 0x0000, 
  ACONFIGURATION_KEYBOARD_NOKEYS = 0x0001, 
  ACONFIGURATION_KEYBOARD_QWERTY = 0x0002, 
  ACONFIGURATION_KEYBOARD_12KEY = 0x0003, 

  ACONFIGURATION_NAVIGATION_ANY = 0x0000, 
  ACONFIGURATION_NAVIGATION_NONAV = 0x0001, 
  ACONFIGURATION_NAVIGATION_DPAD = 0x0002, 
  ACONFIGURATION_NAVIGATION_TRACKBALL = 0x0003, 
  ACONFIGURATION_NAVIGATION_WHEEL = 0x0004, 

  ACONFIGURATION_KEYSHIDDEN_ANY = 0x0000, 
  ACONFIGURATION_KEYSHIDDEN_NO = 0x0001, 
  ACONFIGURATION_KEYSHIDDEN_YES = 0x0002, 
  ACONFIGURATION_KEYSHIDDEN_SOFT = 0x0003, 

  ACONFIGURATION_NAVHIDDEN_ANY = 0x0000, 
  ACONFIGURATION_NAVHIDDEN_NO = 0x0001, 
  ACONFIGURATION_NAVHIDDEN_YES = 0x0002, 

  ACONFIGURATION_SCREENSIZE_ANY = 0x00, 
  ACONFIGURATION_SCREENSIZE_SMALL = 0x01, 
  ACONFIGURATION_SCREENSIZE_NORMAL = 0x02, 
  ACONFIGURATION_SCREENSIZE_LARGE = 0x03, 
  ACONFIGURATION_SCREENSIZE_XLARGE = 0x04, 

  ACONFIGURATION_SCREENLONG_ANY = 0x00, 
  ACONFIGURATION_SCREENLONG_NO = 0x1, 
  ACONFIGURATION_SCREENLONG_YES = 0x2, 

  ACONFIGURATION_UI_MODE_TYPE_ANY = 0x00, 
  ACONFIGURATION_UI_MODE_TYPE_NORMAL = 0x01, 
  ACONFIGURATION_UI_MODE_TYPE_DESK = 0x02, 
  ACONFIGURATION_UI_MODE_TYPE_CAR = 0x03, 

  ACONFIGURATION_UI_MODE_NIGHT_ANY = 0x00, 
  ACONFIGURATION_UI_MODE_NIGHT_NO = 0x1, 
  ACONFIGURATION_UI_MODE_NIGHT_YES = 0x2, 

  ACONFIGURATION_MCC = 0x0001, 
  ACONFIGURATION_MNC = 0x0002, 
  ACONFIGURATION_LOCALE = 0x0004, 
  ACONFIGURATION_TOUCHSCREEN = 0x0008, 
  ACONFIGURATION_KEYBOARD = 0x0010, 
  ACONFIGURATION_KEYBOARD_HIDDEN = 0x0020, 
  ACONFIGURATION_NAVIGATION = 0x0040, 
  ACONFIGURATION_ORIENTATION = 0x0080, 
  ACONFIGURATION_DENSITY = 0x0100, 
  ACONFIGURATION_SCREEN_SIZE = 0x0200, 
  ACONFIGURATION_VERSION = 0x0400, 
  ACONFIGURATION_SCREEN_LAYOUT = 0x0800, 
  ACONFIGURATION_UI_MODE = 0x1000
};
# 38 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/looper.h"
struct ALooper;
typedef struct ALooper ALooper;







enum __nesc_unnamed4272 {







  ALOOPER_PREPARE_ALLOW_NON_CALLBACKS = 1 << 0
};










enum __nesc_unnamed4273 {





  ALOOPER_POLL_WAKE = -1, 





  ALOOPER_POLL_CALLBACK = -2, 





  ALOOPER_POLL_TIMEOUT = -3, 





  ALOOPER_POLL_ERROR = -4
};
#line 111
enum __nesc_unnamed4274 {



  ALOOPER_EVENT_INPUT = 1 << 0, 




  ALOOPER_EVENT_OUTPUT = 1 << 1, 







  ALOOPER_EVENT_ERROR = 1 << 2, 








  ALOOPER_EVENT_HANGUP = 1 << 3, 








  ALOOPER_EVENT_INVALID = 1 << 4
};
#line 159
typedef int (*ALooper_callbackFunc)(int fd, int events, void *data);
# 40 "/usr/lib/gcc/x86_64-linux-gnu/5/include/stdarg.h" 3
typedef __builtin_va_list __gnuc_va_list;
#line 98
typedef __gnuc_va_list va_list;
# 44 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/jni.h"
typedef unsigned char jboolean;
typedef signed char jbyte;
typedef unsigned short jchar;
typedef short jshort;
typedef int jint;
typedef long long jlong;
typedef float jfloat;
typedef double jdouble;



typedef jint jsize;
#line 98
typedef void *jobject;
typedef jobject jclass;
typedef jobject jstring;
typedef jobject jarray;
typedef jarray jobjectArray;
typedef jarray jbooleanArray;
typedef jarray jbyteArray;
typedef jarray jcharArray;
typedef jarray jshortArray;
typedef jarray jintArray;
typedef jarray jlongArray;
typedef jarray jfloatArray;
typedef jarray jdoubleArray;
typedef jobject jthrowable;
typedef jobject jweak;



struct _jfieldID;
typedef struct _jfieldID *jfieldID;

struct _jmethodID;
typedef struct _jmethodID *jmethodID;

struct JNIInvokeInterface;
#line 134
#line 124
typedef union jvalue {
  jboolean z;
  jbyte b;
  jchar c;
  jshort s;
  jint i;
  jlong j;
  jfloat f;
  jdouble d;
  jobject l;
} jvalue;






#line 136
typedef enum jobjectRefType {
  JNIInvalidRefType = 0, 
  JNILocalRefType = 1, 
  JNIGlobalRefType = 2, 
  JNIWeakGlobalRefType = 3
} jobjectRefType;





#line 143
typedef struct __nesc_unnamed4275 {
  const char *name;
  const char *signature;
  void *fnPtr;
} JNINativeMethod;

struct _JNIEnv;
struct _JavaVM;
typedef const struct JNINativeInterface *C_JNIEnv;





typedef const struct JNINativeInterface *JNIEnv;
typedef const struct JNIInvokeInterface *JavaVM;





struct JNINativeInterface {
  void *reserved0;
  void *reserved1;
  void *reserved2;
  void *reserved3;

  jint (*GetVersion)(JNIEnv *arg_0x7f7d4796e9e0);

  jclass (*DefineClass)(JNIEnv *arg_0x7f7d4796d138, const char *arg_0x7f7d4796d410, jobject arg_0x7f7d4796d6c0, const jbyte *arg_0x7f7d4796d9d0, 
  jsize arg_0x7f7d4796dc90);
  jclass (*FindClass)(JNIEnv *arg_0x7f7d4796b418, const char *arg_0x7f7d4796b6f0);

  jmethodID (*FromReflectedMethod)(JNIEnv *arg_0x7f7d4796be80, jobject arg_0x7f7d4796a158);
  jfieldID (*FromReflectedField)(JNIEnv *arg_0x7f7d4796a8d8, jobject arg_0x7f7d4796ab88);

  jobject (*ToReflectedMethod)(JNIEnv *arg_0x7f7d47969340, jclass arg_0x7f7d479695e8, jmethodID arg_0x7f7d479698b0, jboolean arg_0x7f7d47969b70);

  jclass (*GetSuperclass)(JNIEnv *arg_0x7f7d47968300, jclass arg_0x7f7d479685a8);
  jboolean (*IsAssignableFrom)(JNIEnv *arg_0x7f7d47968d18, jclass arg_0x7f7d47967020, jclass arg_0x7f7d479672c8);


  jobject (*ToReflectedField)(JNIEnv *arg_0x7f7d47967a48, jclass arg_0x7f7d47967cf0, jfieldID arg_0x7f7d47965020, jboolean arg_0x7f7d479652e0);

  jint (*Throw)(JNIEnv *arg_0x7f7d479659b8, jthrowable arg_0x7f7d47965c88);
  jint (*ThrowNew)(JNIEnv *arg_0x7f7d479643b8, jclass arg_0x7f7d47964660, const char *arg_0x7f7d47964938);
  jthrowable (*ExceptionOccurred)(JNIEnv *arg_0x7f7d47963100);
  void (*ExceptionDescribe)(JNIEnv *arg_0x7f7d47963820);
  void (*ExceptionClear)(JNIEnv *arg_0x7f7d47962020);
  void (*FatalError)(JNIEnv *arg_0x7f7d479626f8, const char *arg_0x7f7d479629d0);

  jint (*PushLocalFrame)(JNIEnv *arg_0x7f7d47960138, jint arg_0x7f7d479603d0);
  jobject (*PopLocalFrame)(JNIEnv *arg_0x7f7d47960b10, jobject arg_0x7f7d47960dc0);

  jobject (*NewGlobalRef)(JNIEnv *arg_0x7f7d4795f570, jobject arg_0x7f7d4795f820);
  void (*DeleteGlobalRef)(JNIEnv *arg_0x7f7d4795e020, jobject arg_0x7f7d4795e2d0);
  void (*DeleteLocalRef)(JNIEnv *arg_0x7f7d4795e9d0, jobject arg_0x7f7d4795ec80);
  jboolean (*IsSameObject)(JNIEnv *arg_0x7f7d4795d438, jobject arg_0x7f7d4795d6e8, jobject arg_0x7f7d4795d998);

  jobject (*NewLocalRef)(JNIEnv *arg_0x7f7d4795c100, jobject arg_0x7f7d4795c3b0);
  jint (*EnsureLocalCapacity)(JNIEnv *arg_0x7f7d4795cb10, jint arg_0x7f7d4795cda8);

  jobject (*AllocObject)(JNIEnv *arg_0x7f7d4795a508, jclass arg_0x7f7d4795a7b0);
  jobject (*NewObject)(JNIEnv *arg_0x7f7d47959020, jclass arg_0x7f7d479592c8, jmethodID arg_0x7f7d47959590, ...);
  jobject (*NewObjectV)(JNIEnv *arg_0x7f7d47959ce0, jclass arg_0x7f7d47958020, jmethodID arg_0x7f7d479582e8, va_list arg_0x7f7d47958598);
  jobject (*NewObjectA)(JNIEnv *arg_0x7f7d47958cb8, jclass arg_0x7f7d47957020, jmethodID arg_0x7f7d479572e8, jvalue *arg_0x7f7d479575c8);

  jclass (*GetObjectClass)(JNIEnv *arg_0x7f7d47957d08, jobject arg_0x7f7d47955020);
  jboolean (*IsInstanceOf)(JNIEnv *arg_0x7f7d47955768, jobject arg_0x7f7d47955a18, jclass arg_0x7f7d47955cc0);
  jmethodID (*GetMethodID)(JNIEnv *arg_0x7f7d47954428, jclass arg_0x7f7d479546d0, const char *arg_0x7f7d479549a8, const char *arg_0x7f7d47954c80);

  jobject (*CallObjectMethod)(JNIEnv *arg_0x7f7d47953460, jobject arg_0x7f7d47953710, jmethodID arg_0x7f7d479539d8, ...);
  jobject (*CallObjectMethodV)(JNIEnv *arg_0x7f7d479521f8, jobject arg_0x7f7d479524a8, jmethodID arg_0x7f7d47952770, va_list arg_0x7f7d47952a20);
  jobject (*CallObjectMethodA)(JNIEnv *arg_0x7f7d479511f8, jobject arg_0x7f7d479514a8, jmethodID arg_0x7f7d47951770, jvalue *arg_0x7f7d47951a50);
  jboolean (*CallBooleanMethod)(JNIEnv *arg_0x7f7d4794f1f8, jobject arg_0x7f7d4794f4a8, jmethodID arg_0x7f7d4794f770, ...);
  jboolean (*CallBooleanMethodV)(JNIEnv *arg_0x7f7d4794e020, jobject arg_0x7f7d4794e2d0, jmethodID arg_0x7f7d4794e598, va_list arg_0x7f7d4794e848);
  jboolean (*CallBooleanMethodA)(JNIEnv *arg_0x7f7d4794d020, jobject arg_0x7f7d4794d2d0, jmethodID arg_0x7f7d4794d598, jvalue *arg_0x7f7d4794d878);
  jbyte (*CallByteMethod)(JNIEnv *arg_0x7f7d4794c020, jobject arg_0x7f7d4794c2d0, jmethodID arg_0x7f7d4794c598, ...);
  jbyte (*CallByteMethodV)(JNIEnv *arg_0x7f7d4794cd08, jobject arg_0x7f7d4794a020, jmethodID arg_0x7f7d4794a2e8, va_list arg_0x7f7d4794a598);
  jbyte (*CallByteMethodA)(JNIEnv *arg_0x7f7d4794acd8, jobject arg_0x7f7d47949020, jmethodID arg_0x7f7d479492e8, jvalue *arg_0x7f7d479495c8);
  jchar (*CallCharMethod)(JNIEnv *arg_0x7f7d47949d00, jobject arg_0x7f7d47948020, jmethodID arg_0x7f7d479482e8, ...);
  jchar (*CallCharMethodV)(JNIEnv *arg_0x7f7d47948a58, jobject arg_0x7f7d47948d08, jmethodID arg_0x7f7d47947020, va_list arg_0x7f7d479472d0);
  jchar (*CallCharMethodA)(JNIEnv *arg_0x7f7d47947a10, jobject arg_0x7f7d47947cc0, jmethodID arg_0x7f7d47945020, jvalue *arg_0x7f7d47945300);
  jshort (*CallShortMethod)(JNIEnv *arg_0x7f7d47945a48, jobject arg_0x7f7d47945cf8, jmethodID arg_0x7f7d47944020, ...);
  jshort (*CallShortMethodV)(JNIEnv *arg_0x7f7d479447a8, jobject arg_0x7f7d47944a58, jmethodID arg_0x7f7d47944d20, va_list arg_0x7f7d47943020);
  jshort (*CallShortMethodA)(JNIEnv *arg_0x7f7d47943778, jobject arg_0x7f7d47943a28, jmethodID arg_0x7f7d47943cf0, jvalue *arg_0x7f7d47942020);
  jint (*CallIntMethod)(JNIEnv *arg_0x7f7d47942748, jobject arg_0x7f7d479429f8, jmethodID arg_0x7f7d47942cc0, ...);
  jint (*CallIntMethodV)(JNIEnv *arg_0x7f7d47941448, jobject arg_0x7f7d479416f8, jmethodID arg_0x7f7d479419c0, va_list arg_0x7f7d47941c70);
  jint (*CallIntMethodA)(JNIEnv *arg_0x7f7d4793f448, jobject arg_0x7f7d4793f6f8, jmethodID arg_0x7f7d4793f9c0, jvalue *arg_0x7f7d4793fca0);
  jlong (*CallLongMethod)(JNIEnv *arg_0x7f7d4793e448, jobject arg_0x7f7d4793e6f8, jmethodID arg_0x7f7d4793e9c0, ...);
  jlong (*CallLongMethodV)(JNIEnv *arg_0x7f7d4793d178, jobject arg_0x7f7d4793d428, jmethodID arg_0x7f7d4793d6f0, va_list arg_0x7f7d4793d9a0);
  jlong (*CallLongMethodA)(JNIEnv *arg_0x7f7d4793c138, jobject arg_0x7f7d4793c3e8, jmethodID arg_0x7f7d4793c6b0, jvalue *arg_0x7f7d4793c990);
  jfloat (*CallFloatMethod)(JNIEnv *arg_0x7f7d4793a100, jobject arg_0x7f7d4793a3b0, jmethodID arg_0x7f7d4793a678, ...);
  jfloat (*CallFloatMethodV)(JNIEnv *arg_0x7f7d4793ae00, jobject arg_0x7f7d47939100, jmethodID arg_0x7f7d479393c8, va_list arg_0x7f7d47939678);
  jfloat (*CallFloatMethodA)(JNIEnv *arg_0x7f7d47939dd0, jobject arg_0x7f7d479380c8, jmethodID arg_0x7f7d47938390, jvalue *arg_0x7f7d47938670);
  jdouble (*CallDoubleMethod)(JNIEnv *arg_0x7f7d47938dd0, jobject arg_0x7f7d479370c8, jmethodID arg_0x7f7d47937390, ...);
  jdouble (*CallDoubleMethodV)(JNIEnv *arg_0x7f7d47937b28, jobject arg_0x7f7d47937dd8, jmethodID arg_0x7f7d479350c8, va_list arg_0x7f7d47935378);
  jdouble (*CallDoubleMethodA)(JNIEnv *arg_0x7f7d47935ae0, jobject arg_0x7f7d47935d90, jmethodID arg_0x7f7d479340c8, jvalue *arg_0x7f7d479343a8);
  void (*CallVoidMethod)(JNIEnv *arg_0x7f7d47934aa8, jobject arg_0x7f7d47934d58, jmethodID arg_0x7f7d47933060, ...);
  void (*CallVoidMethodV)(JNIEnv *arg_0x7f7d47933798, jobject arg_0x7f7d47933a48, jmethodID arg_0x7f7d47933d10, va_list arg_0x7f7d47932020);
  void (*CallVoidMethodA)(JNIEnv *arg_0x7f7d47932728, jobject arg_0x7f7d479329d8, jmethodID arg_0x7f7d47932ca0, jvalue *arg_0x7f7d47930020);

  jobject (*CallNonvirtualObjectMethod)(JNIEnv *arg_0x7f7d479307e0, jobject arg_0x7f7d47930a90, jclass arg_0x7f7d47930d38, 
  jmethodID arg_0x7f7d4792f060, ...);
  jobject (*CallNonvirtualObjectMethodV)(JNIEnv *arg_0x7f7d4792f858, jobject arg_0x7f7d4792fb08, jclass arg_0x7f7d4792fdb0, 
  jmethodID arg_0x7f7d4792e0c8, va_list arg_0x7f7d4792e378);
  jobject (*CallNonvirtualObjectMethodA)(JNIEnv *arg_0x7f7d4792eb40, jobject arg_0x7f7d4792edf0, jclass arg_0x7f7d4792d0c8, 
  jmethodID arg_0x7f7d4792d3b0, jvalue *arg_0x7f7d4792d690);
  jboolean (*CallNonvirtualBooleanMethod)(JNIEnv *arg_0x7f7d4792de68, jobject arg_0x7f7d4792c148, jclass arg_0x7f7d4792c3f0, 
  jmethodID arg_0x7f7d4792c6d8, ...);
  jboolean (*CallNonvirtualBooleanMethodV)(JNIEnv *arg_0x7f7d4792a020, jobject arg_0x7f7d4792a2d0, jclass arg_0x7f7d4792a578, 
  jmethodID arg_0x7f7d4792a860, va_list arg_0x7f7d4792ab10);
  jboolean (*CallNonvirtualBooleanMethodA)(JNIEnv *arg_0x7f7d47929340, jobject arg_0x7f7d479295f0, jclass arg_0x7f7d47929898, 
  jmethodID arg_0x7f7d47929b80, jvalue *arg_0x7f7d47929e60);
  jbyte (*CallNonvirtualByteMethod)(JNIEnv *arg_0x7f7d47928638, jobject arg_0x7f7d479288e8, jclass arg_0x7f7d47928b90, 
  jmethodID arg_0x7f7d47928e78, ...);
  jbyte (*CallNonvirtualByteMethodV)(JNIEnv *arg_0x7f7d47927680, jobject arg_0x7f7d47927930, jclass arg_0x7f7d47927bd8, 
  jmethodID arg_0x7f7d47925020, va_list arg_0x7f7d479252d0);
  jbyte (*CallNonvirtualByteMethodA)(JNIEnv *arg_0x7f7d47925a78, jobject arg_0x7f7d47925d28, jclass arg_0x7f7d47924020, 
  jmethodID arg_0x7f7d47924308, jvalue *arg_0x7f7d479245e8);
  jchar (*CallNonvirtualCharMethod)(JNIEnv *arg_0x7f7d47924d88, jobject arg_0x7f7d47923060, jclass arg_0x7f7d47923308, 
  jmethodID arg_0x7f7d479235f0, ...);
  jchar (*CallNonvirtualCharMethodV)(JNIEnv *arg_0x7f7d47923dc8, jobject arg_0x7f7d479220c8, jclass arg_0x7f7d47922370, 
  jmethodID arg_0x7f7d47922658, va_list arg_0x7f7d47922908);
  jchar (*CallNonvirtualCharMethodA)(JNIEnv *arg_0x7f7d47921100, jobject arg_0x7f7d479213b0, jclass arg_0x7f7d47921658, 
  jmethodID arg_0x7f7d47921940, jvalue *arg_0x7f7d47921c20);
  jshort (*CallNonvirtualShortMethod)(JNIEnv *arg_0x7f7d4791f4b8, jobject arg_0x7f7d4791f768, jclass arg_0x7f7d4791fa10, 
  jmethodID arg_0x7f7d4791fcf8, ...);
  jshort (*CallNonvirtualShortMethodV)(JNIEnv *arg_0x7f7d4791e538, jobject arg_0x7f7d4791e7e8, jclass arg_0x7f7d4791ea90, 
  jmethodID arg_0x7f7d4791ed78, va_list arg_0x7f7d4791d060);
  jshort (*CallNonvirtualShortMethodA)(JNIEnv *arg_0x7f7d4791d818, jobject arg_0x7f7d4791dac8, jclass arg_0x7f7d4791dd70, 
  jmethodID arg_0x7f7d4791c0c8, jvalue *arg_0x7f7d4791c3a8);
  jint (*CallNonvirtualIntMethod)(JNIEnv *arg_0x7f7d4791cb30, jobject arg_0x7f7d4791cde0, jclass arg_0x7f7d4791a0c8, 
  jmethodID arg_0x7f7d4791a3b0, ...);
  jint (*CallNonvirtualIntMethodV)(JNIEnv *arg_0x7f7d4791ab78, jobject arg_0x7f7d4791ae28, jclass arg_0x7f7d47919100, 
  jmethodID arg_0x7f7d479193e8, va_list arg_0x7f7d47919698);
  jint (*CallNonvirtualIntMethodA)(JNIEnv *arg_0x7f7d47919e30, jobject arg_0x7f7d47918148, jclass arg_0x7f7d479183f0, 
  jmethodID arg_0x7f7d479186d8, jvalue *arg_0x7f7d479189b8);
  jlong (*CallNonvirtualLongMethod)(JNIEnv *arg_0x7f7d479171f8, jobject arg_0x7f7d479174a8, jclass arg_0x7f7d47917750, 
  jmethodID arg_0x7f7d47917a38, ...);
  jlong (*CallNonvirtualLongMethodV)(JNIEnv *arg_0x7f7d47916248, jobject arg_0x7f7d479164f8, jclass arg_0x7f7d479167a0, 
  jmethodID arg_0x7f7d47916a88, va_list arg_0x7f7d47916d38);
  jlong (*CallNonvirtualLongMethodA)(JNIEnv *arg_0x7f7d47914528, jobject arg_0x7f7d479147d8, jclass arg_0x7f7d47914a80, 
  jmethodID arg_0x7f7d47914d68, jvalue *arg_0x7f7d479130c8);
  jfloat (*CallNonvirtualFloatMethod)(JNIEnv *arg_0x7f7d47913878, jobject arg_0x7f7d47913b28, jclass arg_0x7f7d47913dd0, 
  jmethodID arg_0x7f7d47912100, ...);
  jfloat (*CallNonvirtualFloatMethodV)(JNIEnv *arg_0x7f7d479128e8, jobject arg_0x7f7d47912b98, jclass arg_0x7f7d47912e40, 
  jmethodID arg_0x7f7d47911160, va_list arg_0x7f7d47911410);
  jfloat (*CallNonvirtualFloatMethodA)(JNIEnv *arg_0x7f7d47911bc8, jobject arg_0x7f7d47911e78, jclass arg_0x7f7d4790f150, 
  jmethodID arg_0x7f7d4790f438, jvalue *arg_0x7f7d4790f718);
  jdouble (*CallNonvirtualDoubleMethod)(JNIEnv *arg_0x7f7d4790e020, jobject arg_0x7f7d4790e2d0, jclass arg_0x7f7d4790e578, 
  jmethodID arg_0x7f7d4790e860, ...);
  jdouble (*CallNonvirtualDoubleMethodV)(JNIEnv *arg_0x7f7d4790d0c8, jobject arg_0x7f7d4790d378, jclass arg_0x7f7d4790d620, 
  jmethodID arg_0x7f7d4790d908, va_list arg_0x7f7d4790dbb8);
  jdouble (*CallNonvirtualDoubleMethodA)(JNIEnv *arg_0x7f7d4790c3b8, jobject arg_0x7f7d4790c668, jclass arg_0x7f7d4790c910, 
  jmethodID arg_0x7f7d4790cbf8, jvalue *arg_0x7f7d4790a020);
  void (*CallNonvirtualVoidMethod)(JNIEnv *arg_0x7f7d4790a788, jobject arg_0x7f7d4790aa38, jclass arg_0x7f7d4790ace0, 
  jmethodID arg_0x7f7d47909020, ...);
  void (*CallNonvirtualVoidMethodV)(JNIEnv *arg_0x7f7d479097c0, jobject arg_0x7f7d47909a70, jclass arg_0x7f7d47909d18, 
  jmethodID arg_0x7f7d47908060, va_list arg_0x7f7d47908310);
  void (*CallNonvirtualVoidMethodA)(JNIEnv *arg_0x7f7d47908a80, jobject arg_0x7f7d47908d30, jclass arg_0x7f7d47907020, 
  jmethodID arg_0x7f7d47907308, jvalue *arg_0x7f7d479075e8);

  jfieldID (*GetFieldID)(JNIEnv *arg_0x7f7d47907d18, jclass arg_0x7f7d47906020, const char *arg_0x7f7d479062f8, const char *arg_0x7f7d479065d0);

  jobject (*GetObjectField)(JNIEnv *arg_0x7f7d47906d18, jobject arg_0x7f7d47904020, jfieldID arg_0x7f7d479042e0);
  jboolean (*GetBooleanField)(JNIEnv *arg_0x7f7d47904a40, jobject arg_0x7f7d47904cf0, jfieldID arg_0x7f7d47903020);
  jbyte (*GetByteField)(JNIEnv *arg_0x7f7d47903748, jobject arg_0x7f7d479039f8, jfieldID arg_0x7f7d47903cb8);
  jchar (*GetCharField)(JNIEnv *arg_0x7f7d47902438, jobject arg_0x7f7d479026e8, jfieldID arg_0x7f7d479029a8);
  jshort (*GetShortField)(JNIEnv *arg_0x7f7d47901138, jobject arg_0x7f7d479013e8, jfieldID arg_0x7f7d479016a8);
  jint (*GetIntField)(JNIEnv *arg_0x7f7d47901db8, jobject arg_0x7f7d478ff0c8, jfieldID arg_0x7f7d478ff388);
  jlong (*GetLongField)(JNIEnv *arg_0x7f7d478ffab0, jobject arg_0x7f7d478ffd60, jfieldID arg_0x7f7d478fe060);
  jfloat (*GetFloatField)(JNIEnv *arg_0x7f7d478fe798, jobject arg_0x7f7d478fea48, jfieldID arg_0x7f7d478fed08);
  jdouble (*GetDoubleField)(JNIEnv *arg_0x7f7d478fd480, jobject arg_0x7f7d478fd730, jfieldID arg_0x7f7d478fd9f0);

  void (*SetObjectField)(JNIEnv *arg_0x7f7d478fc138, jobject arg_0x7f7d478fc3e8, jfieldID arg_0x7f7d478fc6a8, jobject arg_0x7f7d478fc958);
  void (*SetBooleanField)(JNIEnv *arg_0x7f7d478fb0c8, jobject arg_0x7f7d478fb378, jfieldID arg_0x7f7d478fb638, jboolean arg_0x7f7d478fb8f8);
  void (*SetByteField)(JNIEnv *arg_0x7f7d478f9020, jobject arg_0x7f7d478f92d0, jfieldID arg_0x7f7d478f9590, jbyte arg_0x7f7d478f9830);
  void (*SetCharField)(JNIEnv *arg_0x7f7d478f8020, jobject arg_0x7f7d478f82d0, jfieldID arg_0x7f7d478f8590, jchar arg_0x7f7d478f8830);
  void (*SetShortField)(JNIEnv *arg_0x7f7d478f7020, jobject arg_0x7f7d478f72d0, jfieldID arg_0x7f7d478f7590, jshort arg_0x7f7d478f7838);
  void (*SetIntField)(JNIEnv *arg_0x7f7d478f6020, jobject arg_0x7f7d478f62d0, jfieldID arg_0x7f7d478f6590, jint arg_0x7f7d478f6828);
  void (*SetLongField)(JNIEnv *arg_0x7f7d478f4020, jobject arg_0x7f7d478f42d0, jfieldID arg_0x7f7d478f4590, jlong arg_0x7f7d478f4830);
  void (*SetFloatField)(JNIEnv *arg_0x7f7d478f3020, jobject arg_0x7f7d478f32d0, jfieldID arg_0x7f7d478f3590, jfloat arg_0x7f7d478f3838);
  void (*SetDoubleField)(JNIEnv *arg_0x7f7d478f2020, jobject arg_0x7f7d478f22d0, jfieldID arg_0x7f7d478f2590, jdouble arg_0x7f7d478f2840);

  jmethodID (*GetStaticMethodID)(JNIEnv *arg_0x7f7d478f1020, jclass arg_0x7f7d478f12c8, const char *arg_0x7f7d478f15a0, const char *arg_0x7f7d478f1878);

  jobject (*CallStaticObjectMethod)(JNIEnv *arg_0x7f7d478f0060, jclass arg_0x7f7d478f0308, jmethodID arg_0x7f7d478f05d0, ...);
  jobject (*CallStaticObjectMethodV)(JNIEnv *arg_0x7f7d478f0da0, jclass arg_0x7f7d478ee0c8, jmethodID arg_0x7f7d478ee390, va_list arg_0x7f7d478ee640);
  jobject (*CallStaticObjectMethodA)(JNIEnv *arg_0x7f7d478eede0, jclass arg_0x7f7d478ed0c8, jmethodID arg_0x7f7d478ed390, jvalue *arg_0x7f7d478ed670);
  jboolean (*CallStaticBooleanMethod)(JNIEnv *arg_0x7f7d478ede20, jclass arg_0x7f7d478ec100, jmethodID arg_0x7f7d478ec3c8, ...);
  jboolean (*CallStaticBooleanMethodV)(JNIEnv *arg_0x7f7d478ecbb8, jclass arg_0x7f7d478ece60, jmethodID arg_0x7f7d478eb160, 
  va_list arg_0x7f7d478eb430);
  jboolean (*CallStaticBooleanMethodA)(JNIEnv *arg_0x7f7d478ebbf0, jclass arg_0x7f7d478e9020, jmethodID arg_0x7f7d478e92e8, 
  jvalue *arg_0x7f7d478e95e8);
  jbyte (*CallStaticByteMethod)(JNIEnv *arg_0x7f7d478e9d60, jclass arg_0x7f7d478e8060, jmethodID arg_0x7f7d478e8328, ...);
  jbyte (*CallStaticByteMethodV)(JNIEnv *arg_0x7f7d478e8ad8, jclass arg_0x7f7d478e8d80, jmethodID arg_0x7f7d478e70c8, va_list arg_0x7f7d478e7378);
  jbyte (*CallStaticByteMethodA)(JNIEnv *arg_0x7f7d478e7af8, jclass arg_0x7f7d478e7da0, jmethodID arg_0x7f7d478e60c8, jvalue *arg_0x7f7d478e63a8);
  jchar (*CallStaticCharMethod)(JNIEnv *arg_0x7f7d478e6b20, jclass arg_0x7f7d478e6dc8, jmethodID arg_0x7f7d478e40c8, ...);
  jchar (*CallStaticCharMethodV)(JNIEnv *arg_0x7f7d478e4878, jclass arg_0x7f7d478e4b20, jmethodID arg_0x7f7d478e4de8, va_list arg_0x7f7d478e30c8);
  jchar (*CallStaticCharMethodA)(JNIEnv *arg_0x7f7d478e3848, jclass arg_0x7f7d478e3af0, jmethodID arg_0x7f7d478e3db8, jvalue *arg_0x7f7d478e20c8);
  jshort (*CallStaticShortMethod)(JNIEnv *arg_0x7f7d478e2850, jclass arg_0x7f7d478e2af8, jmethodID arg_0x7f7d478e2dc0, ...);
  jshort (*CallStaticShortMethodV)(JNIEnv *arg_0x7f7d478e15c8, jclass arg_0x7f7d478e1870, jmethodID arg_0x7f7d478e1b38, va_list arg_0x7f7d478e1de8);
  jshort (*CallStaticShortMethodA)(JNIEnv *arg_0x7f7d478e05c8, jclass arg_0x7f7d478e0870, jmethodID arg_0x7f7d478e0b38, jvalue *arg_0x7f7d478e0e18);
  jint (*CallStaticIntMethod)(JNIEnv *arg_0x7f7d478de5f8, jclass arg_0x7f7d478de8a0, jmethodID arg_0x7f7d478deb68, ...);
  jint (*CallStaticIntMethodV)(JNIEnv *arg_0x7f7d478dd340, jclass arg_0x7f7d478dd5e8, jmethodID arg_0x7f7d478dd8b0, va_list arg_0x7f7d478ddb60);
  jint (*CallStaticIntMethodA)(JNIEnv *arg_0x7f7d478dc300, jclass arg_0x7f7d478dc5a8, jmethodID arg_0x7f7d478dc870, jvalue *arg_0x7f7d478dcb50);
  jlong (*CallStaticLongMethod)(JNIEnv *arg_0x7f7d478da300, jclass arg_0x7f7d478da5a8, jmethodID arg_0x7f7d478da870, ...);
  jlong (*CallStaticLongMethodV)(JNIEnv *arg_0x7f7d478d8060, jclass arg_0x7f7d478d8308, jmethodID arg_0x7f7d478d85d0, va_list arg_0x7f7d478d8880);
  jlong (*CallStaticLongMethodA)(JNIEnv *arg_0x7f7d478d7060, jclass arg_0x7f7d478d7308, jmethodID arg_0x7f7d478d75d0, jvalue *arg_0x7f7d478d78b0);
  jfloat (*CallStaticFloatMethod)(JNIEnv *arg_0x7f7d478d6060, jclass arg_0x7f7d478d6308, jmethodID arg_0x7f7d478d65d0, ...);
  jfloat (*CallStaticFloatMethodV)(JNIEnv *arg_0x7f7d478d6d90, jclass arg_0x7f7d478d5060, jmethodID arg_0x7f7d478d5328, va_list arg_0x7f7d478d55d8);
  jfloat (*CallStaticFloatMethodA)(JNIEnv *arg_0x7f7d478d5d68, jclass arg_0x7f7d478d3060, jmethodID arg_0x7f7d478d3328, jvalue *arg_0x7f7d478d3608);
  jdouble (*CallStaticDoubleMethod)(JNIEnv *arg_0x7f7d478d3da0, jclass arg_0x7f7d478d20c8, jmethodID arg_0x7f7d478d2390, ...);
  jdouble (*CallStaticDoubleMethodV)(JNIEnv *arg_0x7f7d478d2b60, jclass arg_0x7f7d478d2e08, jmethodID arg_0x7f7d478d1100, va_list arg_0x7f7d478d13b0);
  jdouble (*CallStaticDoubleMethodA)(JNIEnv *arg_0x7f7d478d1b50, jclass arg_0x7f7d478d1df8, jmethodID arg_0x7f7d478d0100, jvalue *arg_0x7f7d478d03e0);
  void (*CallStaticVoidMethod)(JNIEnv *arg_0x7f7d478d0b20, jclass arg_0x7f7d478d0dc8, jmethodID arg_0x7f7d478cf0c8, ...);
  void (*CallStaticVoidMethodV)(JNIEnv *arg_0x7f7d478cf840, jclass arg_0x7f7d478cfae8, jmethodID arg_0x7f7d478cfdb0, va_list arg_0x7f7d478cd0c8);
  void (*CallStaticVoidMethodA)(JNIEnv *arg_0x7f7d478cd810, jclass arg_0x7f7d478cdab8, jmethodID arg_0x7f7d478cdd80, jvalue *arg_0x7f7d478cc0c8);

  jfieldID (*GetStaticFieldID)(JNIEnv *arg_0x7f7d478cc838, jclass arg_0x7f7d478ccae0, const char *arg_0x7f7d478ccdb8, 
  const char *arg_0x7f7d478cb100);

  jobject (*GetStaticObjectField)(JNIEnv *arg_0x7f7d478cb888, jclass arg_0x7f7d478cbb30, jfieldID arg_0x7f7d478cbdf0);
  jboolean (*GetStaticBooleanField)(JNIEnv *arg_0x7f7d478ca5d8, jclass arg_0x7f7d478ca880, jfieldID arg_0x7f7d478cab40);
  jbyte (*GetStaticByteField)(JNIEnv *arg_0x7f7d478c82c8, jclass arg_0x7f7d478c8570, jfieldID arg_0x7f7d478c8830);
  jchar (*GetStaticCharField)(JNIEnv *arg_0x7f7d478c7020, jclass arg_0x7f7d478c72c8, jfieldID arg_0x7f7d478c7588);
  jshort (*GetStaticShortField)(JNIEnv *arg_0x7f7d478c7cf8, jclass arg_0x7f7d478c6020, jfieldID arg_0x7f7d478c62e0);
  jint (*GetStaticIntField)(JNIEnv *arg_0x7f7d478c6a30, jclass arg_0x7f7d478c6cd8, jfieldID arg_0x7f7d478c5020);
  jlong (*GetStaticLongField)(JNIEnv *arg_0x7f7d478c5780, jclass arg_0x7f7d478c5a28, jfieldID arg_0x7f7d478c5ce8);
  jfloat (*GetStaticFloatField)(JNIEnv *arg_0x7f7d478c34b0, jclass arg_0x7f7d478c3758, jfieldID arg_0x7f7d478c3a18);
  jdouble (*GetStaticDoubleField)(JNIEnv *arg_0x7f7d478c21f8, jclass arg_0x7f7d478c24a0, jfieldID arg_0x7f7d478c2760);

  void (*SetStaticObjectField)(JNIEnv *arg_0x7f7d478c1020, jclass arg_0x7f7d478c12c8, jfieldID arg_0x7f7d478c1588, jobject arg_0x7f7d478c1838);
  void (*SetStaticBooleanField)(JNIEnv *arg_0x7f7d478c0020, jclass arg_0x7f7d478c02c8, jfieldID arg_0x7f7d478c0588, jboolean arg_0x7f7d478c0848);
  void (*SetStaticByteField)(JNIEnv *arg_0x7f7d478bf020, jclass arg_0x7f7d478bf2c8, jfieldID arg_0x7f7d478bf588, jbyte arg_0x7f7d478bf828);
  void (*SetStaticCharField)(JNIEnv *arg_0x7f7d478bd020, jclass arg_0x7f7d478bd2c8, jfieldID arg_0x7f7d478bd588, jchar arg_0x7f7d478bd828);
  void (*SetStaticShortField)(JNIEnv *arg_0x7f7d478bc020, jclass arg_0x7f7d478bc2c8, jfieldID arg_0x7f7d478bc588, jshort arg_0x7f7d478bc830);
  void (*SetStaticIntField)(JNIEnv *arg_0x7f7d478bb020, jclass arg_0x7f7d478bb2c8, jfieldID arg_0x7f7d478bb588, jint arg_0x7f7d478bb820);
  void (*SetStaticLongField)(JNIEnv *arg_0x7f7d478ba020, jclass arg_0x7f7d478ba2c8, jfieldID arg_0x7f7d478ba588, jlong arg_0x7f7d478ba828);
  void (*SetStaticFloatField)(JNIEnv *arg_0x7f7d478b9020, jclass arg_0x7f7d478b92c8, jfieldID arg_0x7f7d478b9588, jfloat arg_0x7f7d478b9830);
  void (*SetStaticDoubleField)(JNIEnv *arg_0x7f7d478b7020, jclass arg_0x7f7d478b72c8, jfieldID arg_0x7f7d478b7588, jdouble arg_0x7f7d478b7838);

  jstring (*NewString)(JNIEnv *arg_0x7f7d478b6020, const jchar *arg_0x7f7d478b6330, jsize arg_0x7f7d478b65d0);
  jsize (*GetStringLength)(JNIEnv *arg_0x7f7d478b6d10, jstring arg_0x7f7d478b5020);
  const jchar *(*GetStringChars)(JNIEnv *arg_0x7f7d478b5790, jstring arg_0x7f7d478b5a40, jboolean *arg_0x7f7d478b5d38);
  void (*ReleaseStringChars)(JNIEnv *arg_0x7f7d478b44c8, jstring arg_0x7f7d478b4778, const jchar *arg_0x7f7d478b4a88);
  jstring (*NewStringUTF)(JNIEnv *arg_0x7f7d478b21f8, const char *arg_0x7f7d478b24d0);
  jsize (*GetStringUTFLength)(JNIEnv *arg_0x7f7d478b2c30, jstring arg_0x7f7d478b1020);

  const char *(*GetStringUTFChars)(JNIEnv *arg_0x7f7d478b1798, jstring arg_0x7f7d478b1a48, jboolean *arg_0x7f7d478b1d40);
  void (*ReleaseStringUTFChars)(JNIEnv *arg_0x7f7d478b04e8, jstring arg_0x7f7d478b0798, const char *arg_0x7f7d478b0a70);
  jsize (*GetArrayLength)(JNIEnv *arg_0x7f7d478af1f8, jarray arg_0x7f7d478af4a0);
  jobjectArray (*NewObjectArray)(JNIEnv *arg_0x7f7d478afc20, jsize arg_0x7f7d478ad020, jclass arg_0x7f7d478ad2c8, jobject arg_0x7f7d478ad578);
  jobject (*GetObjectArrayElement)(JNIEnv *arg_0x7f7d478add08, jobjectArray arg_0x7f7d478ac020, jsize arg_0x7f7d478ac2c0);
  void (*SetObjectArrayElement)(JNIEnv *arg_0x7f7d478aca08, jobjectArray arg_0x7f7d478accf0, jsize arg_0x7f7d478ab020, jobject arg_0x7f7d478ab2d0);

  jbooleanArray (*NewBooleanArray)(JNIEnv *arg_0x7f7d478aba60, jsize arg_0x7f7d478abd00);
  jbyteArray (*NewByteArray)(JNIEnv *arg_0x7f7d478aa4d8, jsize arg_0x7f7d478aa778);
  jcharArray (*NewCharArray)(JNIEnv *arg_0x7f7d478a9020, jsize arg_0x7f7d478a92c0);
  jshortArray (*NewShortArray)(JNIEnv *arg_0x7f7d478a9a28, jsize arg_0x7f7d478a9cc8);
  jintArray (*NewIntArray)(JNIEnv *arg_0x7f7d478a7460, jsize arg_0x7f7d478a7700);
  jlongArray (*NewLongArray)(JNIEnv *arg_0x7f7d478a7e58, jsize arg_0x7f7d478a6138);
  jfloatArray (*NewFloatArray)(JNIEnv *arg_0x7f7d478a68a0, jsize arg_0x7f7d478a6b40);
  jdoubleArray (*NewDoubleArray)(JNIEnv *arg_0x7f7d478a5300, jsize arg_0x7f7d478a55a0);

  jboolean *(*GetBooleanArrayElements)(JNIEnv *arg_0x7f7d478a5d50, jbooleanArray arg_0x7f7d478a40c8, jboolean *arg_0x7f7d478a43c0);
  jbyte *(*GetByteArrayElements)(JNIEnv *arg_0x7f7d478a4b70, jbyteArray arg_0x7f7d478a4e40, jboolean *arg_0x7f7d478a3190);
  jchar *(*GetCharArrayElements)(JNIEnv *arg_0x7f7d478a3940, jcharArray arg_0x7f7d478a3c10, jboolean *arg_0x7f7d478a1020);
  jshort *(*GetShortArrayElements)(JNIEnv *arg_0x7f7d478a17e0, jshortArray arg_0x7f7d478a1ab8, jboolean *arg_0x7f7d478a1db0);
  jint *(*GetIntArrayElements)(JNIEnv *arg_0x7f7d478a0598, jintArray arg_0x7f7d478a0860, jboolean *arg_0x7f7d478a0b58);
  jlong *(*GetLongArrayElements)(JNIEnv *arg_0x7f7d4789f340, jlongArray arg_0x7f7d4789f610, jboolean *arg_0x7f7d4789f908);
  jfloat *(*GetFloatArrayElements)(JNIEnv *arg_0x7f7d4789e100, jfloatArray arg_0x7f7d4789e3d8, jboolean *arg_0x7f7d4789e6d0);
  jdouble *(*GetDoubleArrayElements)(JNIEnv *arg_0x7f7d4789c020, jdoubleArray arg_0x7f7d4789c308, jboolean *arg_0x7f7d4789c600);

  void (*ReleaseBooleanArrayElements)(JNIEnv *arg_0x7f7d4789cdb8, jbooleanArray arg_0x7f7d4789b100, 
  jboolean *arg_0x7f7d4789b418, jint arg_0x7f7d4789b6b0);
  void (*ReleaseByteArrayElements)(JNIEnv *arg_0x7f7d4789be18, jbyteArray arg_0x7f7d4789a168, 
  jbyte *arg_0x7f7d4789a460, jint arg_0x7f7d4789a6f8);
  void (*ReleaseCharArrayElements)(JNIEnv *arg_0x7f7d4789ae60, jcharArray arg_0x7f7d47899168, 
  jchar *arg_0x7f7d47899460, jint arg_0x7f7d478996f8);
  void (*ReleaseShortArrayElements)(JNIEnv *arg_0x7f7d47899e68, jshortArray arg_0x7f7d47897170, 
  jshort *arg_0x7f7d47897470, jint arg_0x7f7d47897708);
  void (*ReleaseIntArrayElements)(JNIEnv *arg_0x7f7d47897e60, jintArray arg_0x7f7d47896160, 
  jint *arg_0x7f7d47896450, jint arg_0x7f7d478966e8);
  void (*ReleaseLongArrayElements)(JNIEnv *arg_0x7f7d47896e50, jlongArray arg_0x7f7d47895168, 
  jlong *arg_0x7f7d47895460, jint arg_0x7f7d478956f8);
  void (*ReleaseFloatArrayElements)(JNIEnv *arg_0x7f7d47895e68, jfloatArray arg_0x7f7d47893170, 
  jfloat *arg_0x7f7d47893470, jint arg_0x7f7d47893708);
  void (*ReleaseDoubleArrayElements)(JNIEnv *arg_0x7f7d47893e80, jdoubleArray arg_0x7f7d47892190, 
  jdouble *arg_0x7f7d47892498, jint arg_0x7f7d47892730);

  void (*GetBooleanArrayRegion)(JNIEnv *arg_0x7f7d47892e78, jbooleanArray arg_0x7f7d47891198, 
  jsize arg_0x7f7d47891458, jsize arg_0x7f7d478916f8, jboolean *arg_0x7f7d478919f0);
  void (*GetByteArrayRegion)(JNIEnv *arg_0x7f7d47890138, jbyteArray arg_0x7f7d47890408, 
  jsize arg_0x7f7d478906c8, jsize arg_0x7f7d47890968, jbyte *arg_0x7f7d47890c40);
  void (*GetCharArrayRegion)(JNIEnv *arg_0x7f7d4788e3b8, jcharArray arg_0x7f7d4788e688, 
  jsize arg_0x7f7d4788e948, jsize arg_0x7f7d4788ebe8, jchar *arg_0x7f7d4788d020);
  void (*GetShortArrayRegion)(JNIEnv *arg_0x7f7d4788d750, jshortArray arg_0x7f7d4788da28, 
  jsize arg_0x7f7d4788dce8, jsize arg_0x7f7d4788c020, jshort *arg_0x7f7d4788c300);
  void (*GetIntArrayRegion)(JNIEnv *arg_0x7f7d4788ca20, jintArray arg_0x7f7d4788cce8, 
  jsize arg_0x7f7d4788b020, jsize arg_0x7f7d4788b2c0, jint *arg_0x7f7d4788b590);
  void (*GetLongArrayRegion)(JNIEnv *arg_0x7f7d4788bcb8, jlongArray arg_0x7f7d47889020, 
  jsize arg_0x7f7d478892e0, jsize arg_0x7f7d47889580, jlong *arg_0x7f7d47889858);
  void (*GetFloatArrayRegion)(JNIEnv *arg_0x7f7d47888020, jfloatArray arg_0x7f7d478882f8, 
  jsize arg_0x7f7d478885b8, jsize arg_0x7f7d47888858, jfloat *arg_0x7f7d47888b38);
  void (*GetDoubleArrayRegion)(JNIEnv *arg_0x7f7d478872c8, jdoubleArray arg_0x7f7d478875b0, 
  jsize arg_0x7f7d47887870, jsize arg_0x7f7d47887b10, jdouble *arg_0x7f7d47887df8);


  void (*SetBooleanArrayRegion)(JNIEnv *arg_0x7f7d478865a0, jbooleanArray arg_0x7f7d47886890, 
  jsize arg_0x7f7d47886b50, jsize arg_0x7f7d47886df0, const jboolean *arg_0x7f7d47884190);
  void (*SetByteArrayRegion)(JNIEnv *arg_0x7f7d478848b8, jbyteArray arg_0x7f7d47884b88, 
  jsize arg_0x7f7d47884e48, jsize arg_0x7f7d47883138, const jbyte *arg_0x7f7d47883448);
  void (*SetCharArrayRegion)(JNIEnv *arg_0x7f7d47883b70, jcharArray arg_0x7f7d47883e40, 
  jsize arg_0x7f7d47882138, jsize arg_0x7f7d478823d8, const jchar *arg_0x7f7d478826e8);
  void (*SetShortArrayRegion)(JNIEnv *arg_0x7f7d47882e18, jshortArray arg_0x7f7d47881170, 
  jsize arg_0x7f7d47881430, jsize arg_0x7f7d478816d0, const jshort *arg_0x7f7d478819e8);
  void (*SetIntArrayRegion)(JNIEnv *arg_0x7f7d4787f138, jintArray arg_0x7f7d4787f400, 
  jsize arg_0x7f7d4787f6c0, jsize arg_0x7f7d4787f960, const jint *arg_0x7f7d4787fc68);
  void (*SetLongArrayRegion)(JNIEnv *arg_0x7f7d4787e3b8, jlongArray arg_0x7f7d4787e688, 
  jsize arg_0x7f7d4787e948, jsize arg_0x7f7d4787ebe8, const jlong *arg_0x7f7d4787d020);
  void (*SetFloatArrayRegion)(JNIEnv *arg_0x7f7d4787d750, jfloatArray arg_0x7f7d4787da28, 
  jsize arg_0x7f7d4787dce8, jsize arg_0x7f7d4787c020, const jfloat *arg_0x7f7d4787c338);
  void (*SetDoubleArrayRegion)(JNIEnv *arg_0x7f7d4787ca78, jdoubleArray arg_0x7f7d4787cd60, 
  jsize arg_0x7f7d4787a060, jsize arg_0x7f7d4787a300, const jdouble *arg_0x7f7d4787a620);

  jint (*RegisterNatives)(JNIEnv *arg_0x7f7d4787ad58, jclass arg_0x7f7d47879060, const JNINativeMethod *arg_0x7f7d478793d0, 
  jint arg_0x7f7d47879688);
  jint (*UnregisterNatives)(JNIEnv *arg_0x7f7d47879dd8, jclass arg_0x7f7d478780c8);
  jint (*MonitorEnter)(JNIEnv *arg_0x7f7d478787e8, jobject arg_0x7f7d47878a98);
  jint (*MonitorExit)(JNIEnv *arg_0x7f7d478771f8, jobject arg_0x7f7d478774a8);
  jint (*GetJavaVM)(JNIEnv *arg_0x7f7d47877ba8, JavaVM **arg_0x7f7d47875020);

  void (*GetStringRegion)(JNIEnv *arg_0x7f7d47875728, jstring arg_0x7f7d478759d8, jsize arg_0x7f7d47875c78, jsize arg_0x7f7d47874020, jchar *arg_0x7f7d478742f8);
  void (*GetStringUTFRegion)(JNIEnv *arg_0x7f7d47874a20, jstring arg_0x7f7d47874cd0, jsize arg_0x7f7d47873020, jsize arg_0x7f7d478732c0, char *arg_0x7f7d47873560);

  void *(*GetPrimitiveArrayCritical)(JNIEnv *arg_0x7f7d47873cd0, jarray arg_0x7f7d47872020, jboolean *arg_0x7f7d47872318);
  void (*ReleasePrimitiveArrayCritical)(JNIEnv *arg_0x7f7d47872ae8, jarray arg_0x7f7d47872d90, void *arg_0x7f7d47870060, jint arg_0x7f7d478702f8);

  const jchar *(*GetStringCritical)(JNIEnv *arg_0x7f7d47870a88, jstring arg_0x7f7d47870d38, jboolean *arg_0x7f7d4786f060);
  void (*ReleaseStringCritical)(JNIEnv *arg_0x7f7d4786f7e0, jstring arg_0x7f7d4786fa90, const jchar *arg_0x7f7d4786fda0);

  jweak (*NewWeakGlobalRef)(JNIEnv *arg_0x7f7d4786e530, jobject arg_0x7f7d4786e7e0);
  void (*DeleteWeakGlobalRef)(JNIEnv *arg_0x7f7d4786d020, jweak arg_0x7f7d4786d2c0);

  jboolean (*ExceptionCheck)(JNIEnv *arg_0x7f7d4786da18);

  jobject (*NewDirectByteBuffer)(JNIEnv *arg_0x7f7d4786b1f8, void *arg_0x7f7d4786b498, jlong arg_0x7f7d4786b738);
  void *(*GetDirectBufferAddress)(JNIEnv *arg_0x7f7d4786a020, jobject arg_0x7f7d4786a2d0);
  jlong (*GetDirectBufferCapacity)(JNIEnv *arg_0x7f7d4786aa98, jobject arg_0x7f7d4786ad48);


  jobjectRefType (*GetObjectRefType)(JNIEnv *arg_0x7f7d47869548, jobject arg_0x7f7d478697f8);
};







struct _JNIEnv {

  const struct JNINativeInterface *functions;
};
#line 1069
struct JNIInvokeInterface {
  void *reserved0;
  void *reserved1;
  void *reserved2;

  jint (*DestroyJavaVM)(JavaVM *arg_0x7f7d4782d6d0);
  jint (*AttachCurrentThread)(JavaVM *arg_0x7f7d4782de30, JNIEnv **arg_0x7f7d4782c170, void *arg_0x7f7d4782c410);
  jint (*DetachCurrentThread)(JavaVM *arg_0x7f7d4782cb70);
  jint (*GetEnv)(JavaVM *arg_0x7f7d4782a2c8, void **arg_0x7f7d4782a5a0, jint arg_0x7f7d4782a838);
  jint (*AttachCurrentThreadAsDaemon)(JavaVM *arg_0x7f7d47829020, JNIEnv **arg_0x7f7d47829338, void *arg_0x7f7d478295d8);
};




struct _JavaVM {
  const struct JNIInvokeInterface *functions;
};
#line 1101
struct JavaVMAttachArgs {
  jint version;
  const char *name;
  jobject group;
};
typedef struct JavaVMAttachArgs JavaVMAttachArgs;








#line 1112
typedef struct JavaVMOption {
  const char *optionString;
  void *extraInfo;
} JavaVMOption;







#line 1117
typedef struct JavaVMInitArgs {
  jint version;

  jint nOptions;
  JavaVMOption *options;
  jboolean ignoreUnrecognized;
} JavaVMInitArgs;
# 45 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/keycodes.h"
enum __nesc_unnamed4276 {
  AKEYCODE_UNKNOWN = 0, 
  AKEYCODE_SOFT_LEFT = 1, 
  AKEYCODE_SOFT_RIGHT = 2, 
  AKEYCODE_HOME = 3, 
  AKEYCODE_BACK = 4, 
  AKEYCODE_CALL = 5, 
  AKEYCODE_ENDCALL = 6, 
  AKEYCODE_0 = 7, 
  AKEYCODE_1 = 8, 
  AKEYCODE_2 = 9, 
  AKEYCODE_3 = 10, 
  AKEYCODE_4 = 11, 
  AKEYCODE_5 = 12, 
  AKEYCODE_6 = 13, 
  AKEYCODE_7 = 14, 
  AKEYCODE_8 = 15, 
  AKEYCODE_9 = 16, 
  AKEYCODE_STAR = 17, 
  AKEYCODE_POUND = 18, 
  AKEYCODE_DPAD_UP = 19, 
  AKEYCODE_DPAD_DOWN = 20, 
  AKEYCODE_DPAD_LEFT = 21, 
  AKEYCODE_DPAD_RIGHT = 22, 
  AKEYCODE_DPAD_CENTER = 23, 
  AKEYCODE_VOLUME_UP = 24, 
  AKEYCODE_VOLUME_DOWN = 25, 
  AKEYCODE_POWER = 26, 
  AKEYCODE_CAMERA = 27, 
  AKEYCODE_CLEAR = 28, 
  AKEYCODE_A = 29, 
  AKEYCODE_B = 30, 
  AKEYCODE_C = 31, 
  AKEYCODE_D = 32, 
  AKEYCODE_E = 33, 
  AKEYCODE_F = 34, 
  AKEYCODE_G = 35, 
  AKEYCODE_H = 36, 
  AKEYCODE_I = 37, 
  AKEYCODE_J = 38, 
  AKEYCODE_K = 39, 
  AKEYCODE_L = 40, 
  AKEYCODE_M = 41, 
  AKEYCODE_N = 42, 
  AKEYCODE_O = 43, 
  AKEYCODE_P = 44, 
  AKEYCODE_Q = 45, 
  AKEYCODE_R = 46, 
  AKEYCODE_S = 47, 
  AKEYCODE_T = 48, 
  AKEYCODE_U = 49, 
  AKEYCODE_V = 50, 
  AKEYCODE_W = 51, 
  AKEYCODE_X = 52, 
  AKEYCODE_Y = 53, 
  AKEYCODE_Z = 54, 
  AKEYCODE_COMMA = 55, 
  AKEYCODE_PERIOD = 56, 
  AKEYCODE_ALT_LEFT = 57, 
  AKEYCODE_ALT_RIGHT = 58, 
  AKEYCODE_SHIFT_LEFT = 59, 
  AKEYCODE_SHIFT_RIGHT = 60, 
  AKEYCODE_TAB = 61, 
  AKEYCODE_SPACE = 62, 
  AKEYCODE_SYM = 63, 
  AKEYCODE_EXPLORER = 64, 
  AKEYCODE_ENVELOPE = 65, 
  AKEYCODE_ENTER = 66, 
  AKEYCODE_DEL = 67, 
  AKEYCODE_GRAVE = 68, 
  AKEYCODE_MINUS = 69, 
  AKEYCODE_EQUALS = 70, 
  AKEYCODE_LEFT_BRACKET = 71, 
  AKEYCODE_RIGHT_BRACKET = 72, 
  AKEYCODE_BACKSLASH = 73, 
  AKEYCODE_SEMICOLON = 74, 
  AKEYCODE_APOSTROPHE = 75, 
  AKEYCODE_SLASH = 76, 
  AKEYCODE_AT = 77, 
  AKEYCODE_NUM = 78, 
  AKEYCODE_HEADSETHOOK = 79, 
  AKEYCODE_FOCUS = 80, 
  AKEYCODE_PLUS = 81, 
  AKEYCODE_MENU = 82, 
  AKEYCODE_NOTIFICATION = 83, 
  AKEYCODE_SEARCH = 84, 
  AKEYCODE_MEDIA_PLAY_PAUSE = 85, 
  AKEYCODE_MEDIA_STOP = 86, 
  AKEYCODE_MEDIA_NEXT = 87, 
  AKEYCODE_MEDIA_PREVIOUS = 88, 
  AKEYCODE_MEDIA_REWIND = 89, 
  AKEYCODE_MEDIA_FAST_FORWARD = 90, 
  AKEYCODE_MUTE = 91, 
  AKEYCODE_PAGE_UP = 92, 
  AKEYCODE_PAGE_DOWN = 93, 
  AKEYCODE_PICTSYMBOLS = 94, 
  AKEYCODE_SWITCH_CHARSET = 95, 
  AKEYCODE_BUTTON_A = 96, 
  AKEYCODE_BUTTON_B = 97, 
  AKEYCODE_BUTTON_C = 98, 
  AKEYCODE_BUTTON_X = 99, 
  AKEYCODE_BUTTON_Y = 100, 
  AKEYCODE_BUTTON_Z = 101, 
  AKEYCODE_BUTTON_L1 = 102, 
  AKEYCODE_BUTTON_R1 = 103, 
  AKEYCODE_BUTTON_L2 = 104, 
  AKEYCODE_BUTTON_R2 = 105, 
  AKEYCODE_BUTTON_THUMBL = 106, 
  AKEYCODE_BUTTON_THUMBR = 107, 
  AKEYCODE_BUTTON_START = 108, 
  AKEYCODE_BUTTON_SELECT = 109, 
  AKEYCODE_BUTTON_MODE = 110
};
# 56 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/input.h"
enum __nesc_unnamed4277 {

  AKEY_STATE_UNKNOWN = -1, 


  AKEY_STATE_UP = 0, 


  AKEY_STATE_DOWN = 1, 


  AKEY_STATE_VIRTUAL = 2
};




enum __nesc_unnamed4278 {

  AMETA_NONE = 0, 


  AMETA_ALT_ON = 0x02, 


  AMETA_ALT_LEFT_ON = 0x10, 


  AMETA_ALT_RIGHT_ON = 0x20, 


  AMETA_SHIFT_ON = 0x01, 


  AMETA_SHIFT_LEFT_ON = 0x40, 


  AMETA_SHIFT_RIGHT_ON = 0x80, 


  AMETA_SYM_ON = 0x04
};







struct AInputEvent;
typedef struct AInputEvent AInputEvent;




enum __nesc_unnamed4279 {

  AINPUT_EVENT_TYPE_KEY = 1, 


  AINPUT_EVENT_TYPE_MOTION = 2
};




enum __nesc_unnamed4280 {

  AKEY_EVENT_ACTION_DOWN = 0, 


  AKEY_EVENT_ACTION_UP = 1, 





  AKEY_EVENT_ACTION_MULTIPLE = 2
};




enum __nesc_unnamed4281 {

  AKEY_EVENT_FLAG_WOKE_HERE = 0x1, 


  AKEY_EVENT_FLAG_SOFT_KEYBOARD = 0x2, 


  AKEY_EVENT_FLAG_KEEP_TOUCH_MODE = 0x4, 




  AKEY_EVENT_FLAG_FROM_SYSTEM = 0x8, 






  AKEY_EVENT_FLAG_EDITOR_ACTION = 0x10, 









  AKEY_EVENT_FLAG_CANCELED = 0x20, 




  AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY = 0x40, 



  AKEY_EVENT_FLAG_LONG_PRESS = 0x80, 



  AKEY_EVENT_FLAG_CANCELED_LONG_PRESS = 0x100, 





  AKEY_EVENT_FLAG_TRACKING = 0x200
};










enum __nesc_unnamed4282 {


  AMOTION_EVENT_ACTION_MASK = 0xff, 






  AMOTION_EVENT_ACTION_POINTER_INDEX_MASK = 0xff00, 



  AMOTION_EVENT_ACTION_DOWN = 0, 




  AMOTION_EVENT_ACTION_UP = 1, 





  AMOTION_EVENT_ACTION_MOVE = 2, 





  AMOTION_EVENT_ACTION_CANCEL = 3, 




  AMOTION_EVENT_ACTION_OUTSIDE = 4, 




  AMOTION_EVENT_ACTION_POINTER_DOWN = 5, 




  AMOTION_EVENT_ACTION_POINTER_UP = 6
};




enum __nesc_unnamed4283 {









  AMOTION_EVENT_FLAG_WINDOW_IS_OBSCURED = 0x1
};




enum __nesc_unnamed4284 {

  AMOTION_EVENT_EDGE_FLAG_NONE = 0, 


  AMOTION_EVENT_EDGE_FLAG_TOP = 0x01, 


  AMOTION_EVENT_EDGE_FLAG_BOTTOM = 0x02, 


  AMOTION_EVENT_EDGE_FLAG_LEFT = 0x04, 


  AMOTION_EVENT_EDGE_FLAG_RIGHT = 0x08
};







enum __nesc_unnamed4285 {
  AINPUT_SOURCE_CLASS_MASK = 0x000000ff, 

  AINPUT_SOURCE_CLASS_BUTTON = 0x00000001, 
  AINPUT_SOURCE_CLASS_POINTER = 0x00000002, 
  AINPUT_SOURCE_CLASS_NAVIGATION = 0x00000004, 
  AINPUT_SOURCE_CLASS_POSITION = 0x00000008
};

enum __nesc_unnamed4286 {
  AINPUT_SOURCE_UNKNOWN = 0x00000000, 

  AINPUT_SOURCE_KEYBOARD = 0x00000100 | AINPUT_SOURCE_CLASS_BUTTON, 
  AINPUT_SOURCE_DPAD = 0x00000200 | AINPUT_SOURCE_CLASS_BUTTON, 
  AINPUT_SOURCE_TOUCHSCREEN = 0x00001000 | AINPUT_SOURCE_CLASS_POINTER, 
  AINPUT_SOURCE_MOUSE = 0x00002000 | AINPUT_SOURCE_CLASS_POINTER, 
  AINPUT_SOURCE_TRACKBALL = 0x00010000 | AINPUT_SOURCE_CLASS_NAVIGATION, 
  AINPUT_SOURCE_TOUCHPAD = 0x00100000 | AINPUT_SOURCE_CLASS_POSITION, 

  AINPUT_SOURCE_ANY = 0xffffff00
};






enum __nesc_unnamed4287 {
  AINPUT_KEYBOARD_TYPE_NONE = 0, 
  AINPUT_KEYBOARD_TYPE_NON_ALPHABETIC = 1, 
  AINPUT_KEYBOARD_TYPE_ALPHABETIC = 2
};








enum __nesc_unnamed4288 {
  AINPUT_MOTION_RANGE_X = 0, 
  AINPUT_MOTION_RANGE_Y = 1, 
  AINPUT_MOTION_RANGE_PRESSURE = 2, 
  AINPUT_MOTION_RANGE_SIZE = 3, 
  AINPUT_MOTION_RANGE_TOUCH_MAJOR = 4, 
  AINPUT_MOTION_RANGE_TOUCH_MINOR = 5, 
  AINPUT_MOTION_RANGE_TOOL_MAJOR = 6, 
  AINPUT_MOTION_RANGE_TOOL_MINOR = 7, 
  AINPUT_MOTION_RANGE_ORIENTATION = 8
};
#line 640
struct AInputQueue;
typedef struct AInputQueue AInputQueue;
# 35 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/rect.h"
#line 27
typedef struct ARect {



  int32_t left;
  int32_t top;
  int32_t right;
  int32_t bottom;
} ARect;
# 29 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/native_window.h"
enum __nesc_unnamed4289 {
  WINDOW_FORMAT_RGBA_8888 = 1, 
  WINDOW_FORMAT_RGBX_8888 = 2, 
  WINDOW_FORMAT_RGB_565 = 4
};

struct ANativeWindow;
typedef struct ANativeWindow ANativeWindow;
#line 57
#line 38
typedef struct ANativeWindow_Buffer {

  int32_t width;


  int32_t height;



  int32_t stride;


  int32_t format;


  void *bits;


  uint32_t reserved[6];
} ANativeWindow_Buffer;
# 34 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/native_activity.h"
struct ANativeActivityCallbacks;
#line 101
#line 41
typedef struct ANativeActivity {






  struct ANativeActivityCallbacks *callbacks;




  JavaVM *vm;






  JNIEnv *env;
#line 72
  jobject clazz;




  const char *internalDataPath;




  const char *externalDataPath;




  int32_t sdkVersion;






  void *instance;





  AAssetManager *assetManager;
} ANativeActivity;
#line 218
#line 109
typedef struct ANativeActivityCallbacks {




  void (*onStart)(ANativeActivity *activity);





  void (*onResume)(ANativeActivity *activity);










  void *(*onSaveInstanceState)(ANativeActivity *activity, size_t *outSize);





  void (*onPause)(ANativeActivity *activity);





  void (*onStop)(ANativeActivity *activity);





  void (*onDestroy)(ANativeActivity *activity);





  void (*onWindowFocusChanged)(ANativeActivity *activity, int hasFocus);





  void (*onNativeWindowCreated)(ANativeActivity *activity, ANativeWindow *window);






  void (*onNativeWindowResized)(ANativeActivity *activity, ANativeWindow *window);







  void (*onNativeWindowRedrawNeeded)(ANativeActivity *activity, ANativeWindow *window);









  void (*onNativeWindowDestroyed)(ANativeActivity *activity, ANativeWindow *window);





  void (*onInputQueueCreated)(ANativeActivity *activity, AInputQueue *queue);






  void (*onInputQueueDestroyed)(ANativeActivity *activity, AInputQueue *queue);




  void (*onContentRectChanged)(ANativeActivity *activity, const ARect *rect);





  void (*onConfigurationChanged)(ANativeActivity *activity);






  void (*onLowMemory)(ANativeActivity *activity);
} ANativeActivityCallbacks;









typedef void ANativeActivity_createFunc(ANativeActivity *activity, 
void *savedState, size_t savedStateSize);
#line 268
enum __nesc_unnamed4290 {
  ANATIVEACTIVITY_SHOW_SOFT_INPUT_IMPLICIT = 0x0001, 
  ANATIVEACTIVITY_SHOW_SOFT_INPUT_FORCED = 0x0002
};
#line 285
enum __nesc_unnamed4291 {
  ANATIVEACTIVITY_HIDE_SOFT_INPUT_IMPLICIT_ONLY = 0x0001, 
  ANATIVEACTIVITY_HIDE_SOFT_INPUT_NOT_ALWAYS = 0x0002
};
# 84 "/home/mauricio/Android/Sdk/ndk-bundle/sources/android/native_app_glue/android_native_app_glue.h"
struct android_app;





struct android_poll_source {


  int32_t id;


  struct android_app *app;



  void (*process)(struct android_app *app, struct android_poll_source *source);
};









struct android_app {


  void *userData;


  void (*onAppCmd)(struct android_app *app, int32_t cmd);





  int32_t (*onInputEvent)(struct android_app *app, AInputEvent *event);


  ANativeActivity *activity;


  AConfiguration *config;









  void *savedState;
  size_t savedStateSize;


  ALooper *looper;



  AInputQueue *inputQueue;


  ANativeWindow *window;



  ARect contentRect;



  int activityState;



  int destroyRequested;




  pthread_mutex_t mutex;
  pthread_cond_t cond;

  int msgread;
  int msgwrite;

  pthread_t thread;

  struct android_poll_source cmdPollSource;
  struct android_poll_source inputPollSource;

  int running;
  int stateSaved;
  int destroyed;
  int redrawNeeded;
  AInputQueue *pendingInputQueue;
  ANativeWindow *pendingWindow;
  ARect pendingContentRect;
};

enum __nesc_unnamed4292 {







  LOOPER_ID_MAIN = 1, 








  LOOPER_ID_INPUT = 2, 




  LOOPER_ID_USER = 3
};

enum __nesc_unnamed4293 {





  APP_CMD_INPUT_CHANGED, 






  APP_CMD_INIT_WINDOW, 







  APP_CMD_TERM_WINDOW, 





  APP_CMD_WINDOW_RESIZED, 






  APP_CMD_WINDOW_REDRAW_NEEDED, 






  APP_CMD_CONTENT_RECT_CHANGED, 





  APP_CMD_GAINED_FOCUS, 





  APP_CMD_LOST_FOCUS, 




  APP_CMD_CONFIG_CHANGED, 





  APP_CMD_LOW_MEMORY, 




  APP_CMD_START, 




  APP_CMD_RESUME, 








  APP_CMD_SAVE_STATE, 




  APP_CMD_PAUSE, 




  APP_CMD_STOP, 





  APP_CMD_DESTROY
};
#line 348
extern void android_main(struct android_app *app);
# 3 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/androidEvents.h"
void androidInitEvent(struct android_app *state);

void androidCheckEvent();
# 38 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/select.h"
typedef __kernel_fd_set fd_set;
# 23 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/capability.h"
#line 20
typedef struct __user_cap_header_struct {
  __u32 version;
  int pid;
} *cap_user_header_t;





#line 25
typedef struct __user_cap_data_struct {
  __u32 effective;
  __u32 permitted;
  __u32 inheritable;
} *cap_user_data_t;
# 56 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/unistd.h"
extern pid_t getpid(void );
#line 130
extern int close(int arg_0x7f7d4771a598);










extern int fcntl(int arg_0x7f7d47711ac0, int arg_0x7f7d47711d28, ...);








extern unsigned int sleep(unsigned int arg_0x7f7d4770a608);
# 7 "VMData.h"
enum __nesc_unnamed4294 {

  MSG_BUFF_SIZE = 28, 
  BLOCK_SIZE = 22, 
  SET_DATA_SIZE = 18, 
  SENDGR_DATA_SIZE = 16, 
  SEND_DATA_SIZE = 22, 


  CURRENT_MAX_BLOCKS = 220, 







  GENERAL_MAX_BLOCKS = 100
};
#line 47
#line 33
typedef struct progEnv {

  uint16_t Version;
  uint16_t ProgStart;
  uint16_t ProgEnd;
  uint16_t nTracks;
  uint16_t wClocks;
  uint16_t asyncs;
  uint16_t wClock0;
  uint16_t gate0;
  uint16_t inEvts;
  uint16_t async0;
  uint16_t appSize;
  uint8_t persistFlag;
} progEnv_t;
# 4 "VMError.h"
enum __nesc_unnamed4295 {


  I_ERROR_ID = 0, 
  I_ERROR = 1, 



  E_DIVZERO = 10, 
  E_IDXOVF = 11, 
  E_STKOVF = 20, 
  E_NOSETUP = 21
};
# 23 "TerraVM.h"
const uint8_t IS_RangeMask[6][3] = { 
{ 0, 47, 0x00 }, 
{ 48, 63, 0x01 }, 
{ 64, 103, 0x03 }, 
{ 104, 143, 0x07 }, 
{ 144, 191, 0x0f }, 
{ 192, 255, 0x3f } };
#line 66
enum __nesc_unnamed4296 {



  EVT_QUEUE_SIZE = 6, 





  DEFAULT_VARS = 0, 
  STRUC_DEF = 2, 
  VAR_SPACE = 4, 
  EVT_VARS = 6, 
  TMR_DEFS = 8, 
  GR_DEFS = 10, 
  AGG_DEFS = 12, 
  EVT_SPACE = 14, 
  FUNCTION_SPACE = 16, 
  INIT_FUNCTION = 18, 
  MOTE_ID = 20, 
  RESULT = 22, 


  U8 = 0, 
  U16 = 1, 
  U32 = 2, 
  F32 = 3, 
  S8 = 4, 
  S16 = 5, 
  S32 = 6, 


  x8 = 0, 
  x16 = 1, 
  x32 = 2, 


  U32_F = 0, 
  S32_F = 1, 
  F_U32 = 2, 
  F_S32 = 3, 


  op_nop = 0, 
  op_end = 1, 
  op_bnot = 2, 
  op_lnot = 3, 
  op_neg = 4, 
  op_sub = 5, 
  op_add = 6, 
  op_mod = 7, 
  op_mult = 8, 
  op_div = 9, 
  op_bor = 10, 
  op_band = 11, 
  op_lshft = 12, 
  op_rshft = 13, 
  op_bxor = 14, 
  op_eq = 15, 
  op_neq = 16, 
  op_gte = 17, 
  op_lte = 18, 
  op_gt = 19, 
  op_lt = 20, 
  op_lor = 21, 
  op_land = 22, 
  op_popx = 23, 

  op_neg_f = 25, 
  op_sub_f = 26, 
  op_add_f = 27, 
  op_mult_f = 28, 
  op_div_f = 29, 
  op_eq_f = 30, 
  op_neq_f = 31, 
  op_gte_f = 32, 
  op_lte_f = 33, 
  op_gt_f = 34, 
  op_lt_f = 35, 
  op_func = 36, 
  op_outEvt_e = 37, 
  op_outevt_z = 38, 
  op_clken_e = 39, 
  op_clken_v = 40, 
  op_clken_c = 41, 
  op_set_v = 42, 
  op_setarr_vc = 43, 
  op_setarr_vv = 44, 

  op_poparr_v = 48, 
  op_pusharr_v = 50, 
  op_getextdt_e = 52, 
  op_trg = 54, 
  op_exec = 56, 
  op_chkret = 58, 
  op_tkins_z = 60, 

  op_push_c = 64, 
  op_cast = 68, 
  op_memclr = 72, 
  op_ifelse = 76, 
  op_asen = 80, 
  op_tkclr = 84, 
  op_outEvt_c = 88, 
  op_getextdt_v = 92, 
  op_inc = 96, 
  op_dec = 100, 
  op_set_e = 104, 
  op_deref = 112, 
  op_memcpy = 120, 

  op_tkins_max = 136, 
  op_push_v = 144, 
  op_pop = 160, 
  op_outEvt_v = 176, 
  op_set_c = 192
};







#line 187
typedef struct evtData {
  uint8_t evtId;
  uint8_t auxId;
  void *data;
} evtData_t;
# 12 "BasicServices.h"
enum __nesc_unnamed4297 {



  AM_NEWPROGVERSION = 160, 
  AM_NEWPROGBLOCK = 161, 
  AM_REQPROGBLOCK = 162, 
  AM_SETDATAND = 131, 
  AM_REQDATA = 132, 
  AM_PINGMSG = 133, 

  AM_CUSTOM_START = 140, 
  AM_CUSTOM_END = 149, 
  AM_CUSTOM_0 = 140, 
  AM_CUSTOM_1 = 141, 
  AM_CUSTOM_2 = 142, 
  AM_CUSTOM_3 = 143, 
  AM_CUSTOM_4 = 144, 
  AM_CUSTOM_5 = 145, 
  AM_CUSTOM_6 = 146, 
  AM_CUSTOM_7 = 147, 
  AM_CUSTOM_8 = 148, 
  AM_CUSTOM_9 = 149, 




  AM_RESERVED_END = 127, 


  RESEND_DELAY = 20L, 
  SEND_TIMEOUT = 1000L, 
  MAX_SEND_RETRIES = 5, 






  REQUEST_TIMEOUT = 500L, 
  REQUEST_TIMEOUT_BS = 500L, 

  REQUEST_VERY_LONG_TIMEOUT = 600000L, 
  DISSEMINATION_TIMEOUT = 300L, 
#line 66
  IN_QSIZE = 5, 
  OUT_QSIZE = 10, 









  SET_DATA_LIST_SIZE = 5, 


  ST_IDLE = 1, 
  ST_WAIT_PROG_VER = 2, 
  ST_WAIT_PROG_BLK = 3, 
  ST_WAIT_DATA = 4, 
  ST_DSM_PROG = 5, 


  RO_NEW_VERSION = 1, 
  RO_DATA_FULL = 2, 
  RO_DATA_SINGLE = 3, 
  RO_IDLE = 4, 


  REQ_ACK_BIT = 0, 
  REQ_RETRY_BIT = 1
};
#line 134
#line 118
typedef nx_struct newProgVersion {
  nx_uint8_t moteType;
  nx_uint16_t versionId;
  nx_uint16_t blockLen;
  nx_uint16_t blockStart;
  nx_uint16_t startProg;
  nx_uint16_t endProg;
  nx_uint16_t nTracks;
  nx_uint16_t wClocks;
  nx_uint16_t asyncs;
  nx_uint16_t wClock0;
  nx_uint16_t gate0;
  nx_uint16_t inEvts;
  nx_uint16_t async0;
  nx_uint16_t appSize;
  nx_uint8_t persistFlag;
} __attribute__((packed)) newProgVersion_t;






#line 136
typedef nx_struct newProgBlock {
  nx_uint8_t moteType;
  nx_uint16_t versionId;
  nx_uint16_t blockId;
  nx_uint8_t data[BLOCK_SIZE];
} __attribute__((packed)) newProgBlock_t;






#line 143
typedef nx_struct reqProgBlock {
  nx_uint8_t reqOper;
  nx_uint8_t moteType;
  nx_uint16_t versionId;
  nx_uint16_t blockId;
} __attribute__((packed)) reqProgBlock_t;








#line 151
typedef nx_struct setDataND {
  nx_uint16_t versionId;
  nx_uint16_t seq;
  nx_uint16_t targetMote;
  nx_uint8_t nSections;
  nx_int8_t Data[SET_DATA_SIZE];
} __attribute__((packed)) setDataND_t;




#line 159
typedef nx_struct reqData {
  nx_uint16_t versionId;
  nx_uint16_t seq;
} __attribute__((packed)) reqData_t;






#line 164
typedef nx_struct setDataBuffer {
  nx_uint16_t versionId;
  nx_uint16_t seq;
  nx_uint8_t AM_ID;
  nx_uint8_t buffer[MSG_BUFF_SIZE];
} __attribute__((packed)) setDataBuff_t;








#line 171
typedef nx_struct sendBS {

  nx_uint16_t Sender;
  nx_uint16_t seq;

  nx_uint8_t evtId;
  nx_int8_t Data[SEND_DATA_SIZE];
} __attribute__((packed)) sendBS_t;









#line 180
typedef nx_struct GenericData {
  nx_uint8_t AM_ID;
  nx_uint8_t DataSize;
  nx_uint16_t sendToMote;
  nx_uint8_t fromSerial;
  nx_uint8_t reqAck;
  nx_uint8_t RFPower;
  nx_uint8_t Data[MSG_BUFF_SIZE];
} __attribute__((packed)) GenericData_t;



#line 190
typedef nx_struct ctpMsg {
  nx_uint8_t data[MSG_BUFF_SIZE];
} __attribute__((packed)) ctpMsg_t;
# 6 "/home/mauricio/Terra/TerraVM/src/system/AM.h"
typedef nx_uint8_t nx_am_id_t;
typedef nx_uint8_t nx_am_group_t;
typedef nx_uint16_t nx_am_addr_t;

typedef uint8_t am_id_t;
typedef uint8_t am_group_t;
typedef uint16_t am_addr_t;

enum __nesc_unnamed4298 {
  AM_BROADCAST_ADDR = 0xffff
};









enum __nesc_unnamed4299 {
  TOS_AM_GROUP = 0x22, 
  TOS_AM_ADDRESS = 1
};
# 83 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/Serial.h"
typedef uint8_t uart_id_t;



enum __nesc_unnamed4300 {
  HDLC_FLAG_BYTE = 0x7e, 
  HDLC_CTLESC_BYTE = 0x7d
};



enum __nesc_unnamed4301 {
  TOS_SERIAL_ACTIVE_MESSAGE_ID = 0, 
  TOS_SERIAL_CC1000_ID = 1, 
  TOS_SERIAL_802_15_4_ID = 2, 
  TOS_SERIAL_UNKNOWN_ID = 255
};


enum __nesc_unnamed4302 {
  SERIAL_PROTO_ACK = 67, 
  SERIAL_PROTO_PACKET_ACK = 68, 
  SERIAL_PROTO_PACKET_NOACK = 69, 
  SERIAL_PROTO_PACKET_UNKNOWN = 255
};
#line 121
#line 109
typedef struct radio_stats {
  uint8_t version;
  uint8_t flags;
  uint8_t reserved;
  uint8_t platform;
  uint16_t MTU;
  uint16_t radio_crc_fail;
  uint16_t radio_queue_drops;
  uint16_t serial_crc_fail;
  uint16_t serial_tx_fail;
  uint16_t serial_short_packets;
  uint16_t serial_proto_drops;
} radio_stats_t;







#line 123
typedef nx_struct serial_header {
  nx_am_addr_t dest;
  nx_am_addr_t src;
  nx_uint8_t length;
  nx_am_group_t group;
  nx_am_id_t type;
} __attribute__((packed)) serial_header_t;




#line 131
typedef nx_struct serial_packet {
  serial_header_t header;
  nx_uint8_t data[];
} __attribute__((packed)) serial_packet_t;




#line 136
typedef nx_struct serial_metadata {
  nx_uint8_t ack;
  nx_uint16_t ackID;
} __attribute__((packed)) serial_metadata_t;
# 11 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ackMessage.h"
#line 6
typedef nx_struct ackMessage_t {
  nx_uint16_t ackCode;
  nx_am_addr_t src;
  nx_am_addr_t dest;
  nx_uint16_t ackID;
} __attribute__((packed)) ackMessage_t;
# 23 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/platform_message.h"
#line 21
typedef union message_header {
  serial_header_t serial;
} message_header_t;



#line 25
typedef union message_footer {
  nx_uint8_t dummy;
} message_footer_t;

typedef serial_metadata_t message_metadata_t;
# 19 "/home/mauricio/Terra/TerraVM/src/system/message.h"
#line 14
typedef nx_struct message_t {
  nx_uint8_t header[sizeof(message_header_t )];
  nx_uint8_t data[28];
  nx_uint8_t footer[sizeof(message_footer_t )];
  nx_uint8_t metadata[sizeof(message_metadata_t )];
} __attribute__((packed)) message_t;
# 3 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/androidEvents.h"
void androidInitEvent(struct android_app *state);

void androidCheckEvent();
# 89 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/android/log.h"
#line 79
typedef enum android_LogPriority {
  ANDROID_LOG_UNKNOWN = 0, 
  ANDROID_LOG_DEFAULT, 
  ANDROID_LOG_VERBOSE, 
  ANDROID_LOG_DEBUG, 
  ANDROID_LOG_INFO, 
  ANDROID_LOG_WARN, 
  ANDROID_LOG_ERROR, 
  ANDROID_LOG_FATAL, 
  ANDROID_LOG_SILENT
} android_LogPriority;
# 41 "/home/mauricio/Terra/TerraVM/src/system/Timer.h"
typedef struct __nesc_unnamed4303 {
#line 41
  int notUsed;
} 
#line 41
TSecond;
typedef struct __nesc_unnamed4304 {
#line 42
  int notUsed;
} 
#line 42
TMilli;
typedef struct __nesc_unnamed4305 {
#line 43
  int notUsed;
} 
#line 43
T32khz;
typedef struct __nesc_unnamed4306 {
#line 44
  int notUsed;
} 
#line 44
TMicro;
# 65 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/stdio.h"
typedef off_t fpos_t;








struct __sbuf {
  unsigned char *_base;
  int _size;
};
#line 138
#line 106
typedef struct __sFILE {
  unsigned char *_p;
  int _r;
  int _w;
  short _flags;
  short _file;
  struct __sbuf _bf;
  int _lbfsize;


  void *_cookie;
  int (*_close)(void *arg_0x7f7d4709dac0);
  int (*_read)(void *arg_0x7f7d4709c1b8, char *arg_0x7f7d4709c458, int arg_0x7f7d4709c6c0);
  fpos_t (*_seek)(void *arg_0x7f7d4709cd68, fpos_t arg_0x7f7d4709a060, int arg_0x7f7d4709a2c8);
  int (*_write)(void *arg_0x7f7d4709a938, const char *arg_0x7f7d4709ac10, int arg_0x7f7d4709ae78);


  struct __sbuf _ext;

  unsigned char *_up;
  int _ur;


  unsigned char _ubuf[3];
  unsigned char _nbuf[1];


  struct __sbuf _lb;


  int _blksize;
  fpos_t _offset;
} FILE;
#line 219
FILE *fopen(const char *arg_0x7f7d4708e9a8, const char *arg_0x7f7d4708ec80);



size_t fread(void *arg_0x7f7d4708a858, size_t arg_0x7f7d4708ab00, size_t arg_0x7f7d4708ada8, FILE *arg_0x7f7d470890c8);







size_t fwrite(const void *arg_0x7f7d47082c50, size_t arg_0x7f7d47080020, size_t arg_0x7f7d470802c8, FILE *arg_0x7f7d47080598);









void perror(const char *arg_0x7f7d4707dd18);










int sprintf(char *arg_0x7f7d47074968, const char *arg_0x7f7d47074c40, ...);
int sscanf(const char *arg_0x7f7d470725d8, const char *arg_0x7f7d470728b0, ...);
# 117 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/asm-generic/fcntl.h"
struct flock {
  short l_type;
  short l_whence;
  off_t l_start;
  off_t l_len;
  pid_t l_pid;
};
#line 138
struct flock64 {
  short l_type;
  short l_whence;
  loff_t l_start;
  loff_t l_len;
  pid_t l_pid;
};
# 49 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/fcntl.h"
extern int fcntl(int fd, int command, ...);
# 18 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/socket.h"
struct __kernel_sockaddr_storage {
  unsigned short ss_family;

  char __data[128 - sizeof(unsigned short )];
} 
__attribute((aligned(__alignof__(struct sockaddr *)))) ;
# 18 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/uio.h"
struct iovec {

  void *iov_base;
  __kernel_size_t iov_len;
};
# 33 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/socket.h"
typedef unsigned short sa_family_t;

struct sockaddr {
  sa_family_t sa_family;
  char sa_data[14];
};

struct linger {
  int l_onoff;
  int l_linger;
};



struct msghdr {
  void *msg_name;
  int msg_namelen;
  struct iovec *msg_iov;
  __kernel_size_t msg_iovlen;
  void *msg_control;
  __kernel_size_t msg_controllen;
  unsigned msg_flags;
};

struct cmsghdr {
  __kernel_size_t cmsg_len;
  int cmsg_level;
  int cmsg_type;
};
#line 105
struct ucred {
  __u32 pid;
  __u32 uid;
  __u32 gid;
};
# 18 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/in.h"
enum __nesc_unnamed4307 {
  IPPROTO_IP = 0, 
  IPPROTO_ICMP = 1, 
  IPPROTO_IGMP = 2, 
  IPPROTO_IPIP = 4, 
  IPPROTO_TCP = 6, 
  IPPROTO_EGP = 8, 
  IPPROTO_PUP = 12, 
  IPPROTO_UDP = 17, 
  IPPROTO_IDP = 22, 
  IPPROTO_DCCP = 33, 
  IPPROTO_RSVP = 46, 
  IPPROTO_GRE = 47, 

  IPPROTO_IPV6 = 41, 

  IPPROTO_ESP = 50, 
  IPPROTO_AH = 51, 
  IPPROTO_PIM = 103, 

  IPPROTO_COMP = 108, 
  IPPROTO_SCTP = 132, 

  IPPROTO_RAW = 255, 
  IPPROTO_MAX
};

struct in_addr {
  __u32 s_addr;
};
#line 98
struct ip_mreq {

  struct in_addr imr_multiaddr;
  struct in_addr imr_interface;
};

struct ip_mreqn {

  struct in_addr imr_multiaddr;
  struct in_addr imr_address;
  int imr_ifindex;
};

struct ip_mreq_source {
  __u32 imr_multiaddr;
  __u32 imr_interface;
  __u32 imr_sourceaddr;
};

struct ip_msfilter {
  __u32 imsf_multiaddr;
  __u32 imsf_interface;
  __u32 imsf_fmode;
  __u32 imsf_numsrc;
  __u32 imsf_slist[1];
};



struct group_req {

  __u32 gr_interface;
  struct __kernel_sockaddr_storage gr_group;
};

struct group_source_req {

  __u32 gsr_interface;
  struct __kernel_sockaddr_storage gsr_group;
  struct __kernel_sockaddr_storage gsr_source;
};

struct group_filter {

  __u32 gf_interface;
  struct __kernel_sockaddr_storage gf_group;
  __u32 gf_fmode;
  __u32 gf_numsrc;
  struct __kernel_sockaddr_storage gf_slist[1];
};



struct in_pktinfo {

  int ipi_ifindex;
  struct in_addr ipi_spec_dst;
  struct in_addr ipi_addr;
};


struct sockaddr_in {
  sa_family_t sin_family;
  unsigned short int sin_port;
  struct in_addr sin_addr;

  unsigned char __pad
  [
#line 164
  16 - sizeof(short int ) - 
  sizeof(unsigned short int ) - sizeof(struct in_addr )];
};
# 17 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/in6.h"
struct in6_addr {

  union __nesc_unnamed4308 {

    __u8 u6_addr8[16];
    __u16 u6_addr16[8];
    __u32 u6_addr32[4];
  } in6_u;
};






struct sockaddr_in6 {
  unsigned short int sin6_family;
  __u16 sin6_port;
  __u32 sin6_flowinfo;
  struct in6_addr sin6_addr;
  __u32 sin6_scope_id;
};

struct ipv6_mreq {

  struct in6_addr ipv6mr_multiaddr;

  int ipv6mr_ifindex;
};



struct in6_flowlabel_req {

  struct in6_addr flr_dst;
  __u32 flr_label;
  __u8 flr_action;
  __u8 flr_share;
  __u16 flr_flags;
  __u16 flr_expires;
  __u16 flr_linger;
  __u32 __flr_pad;
};
# 21 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/linux/ipv6.h"
struct in6_pktinfo {
  struct in6_addr ipi6_addr;
  int ipi6_ifindex;
};

struct ip6_mtuinfo {
  struct sockaddr_in6 ip6m_addr;
  __u32 ip6m_mtu;
};

struct in6_ifreq {
  struct in6_addr ifr6_addr;
  __u32 ifr6_prefixlen;
  int ifr6_ifindex;
};





struct ipv6_rt_hdr {
  __u8 nexthdr;
  __u8 hdrlen;
  __u8 type;
  __u8 segments_left;
};


struct ipv6_opt_hdr {
  __u8 nexthdr;
  __u8 hdrlen;
} 
__attribute((packed)) ;




struct rt0_hdr {
  struct ipv6_rt_hdr rt_hdr;
  __u32 reserved;
  struct in6_addr addr[0];
};



struct rt2_hdr {
  struct ipv6_rt_hdr rt_hdr;
  __u32 reserved;
  struct in6_addr addr;
};



struct ipv6_destopt_hao {
  __u8 type;
  __u8 length;
  struct in6_addr addr;
} __attribute((packed)) ;

struct ipv6hdr {

  __u8 priority : 4, 
  version : 4;






  __u8 flow_lbl[3];

  __be16 payload_len;
  __u8 nexthdr;
  __u8 hop_limit;

  struct in6_addr saddr;
  struct in6_addr daddr;
};

enum __nesc_unnamed4309 {
  DEVCONF_FORWARDING = 0, 
  DEVCONF_HOPLIMIT, 
  DEVCONF_MTU6, 
  DEVCONF_ACCEPT_RA, 
  DEVCONF_ACCEPT_REDIRECTS, 
  DEVCONF_AUTOCONF, 
  DEVCONF_DAD_TRANSMITS, 
  DEVCONF_RTR_SOLICITS, 
  DEVCONF_RTR_SOLICIT_INTERVAL, 
  DEVCONF_RTR_SOLICIT_DELAY, 
  DEVCONF_USE_TEMPADDR, 
  DEVCONF_TEMP_VALID_LFT, 
  DEVCONF_TEMP_PREFERED_LFT, 
  DEVCONF_REGEN_MAX_RETRY, 
  DEVCONF_MAX_DESYNC_FACTOR, 
  DEVCONF_MAX_ADDRESSES, 
  DEVCONF_FORCE_MLD_VERSION, 
  DEVCONF_ACCEPT_RA_DEFRTR, 
  DEVCONF_ACCEPT_RA_PINFO, 
  DEVCONF_ACCEPT_RA_RTR_PREF, 
  DEVCONF_RTR_PROBE_INTERVAL, 
  DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN, 
  DEVCONF_PROXY_NDP, 
  DEVCONF_OPTIMISTIC_DAD, 
  DEVCONF_ACCEPT_SOURCE_ROUTE, 
  DEVCONF_MC_FORWARDING, 
  DEVCONF_DISABLE_IPV6, 
  DEVCONF_ACCEPT_DAD, 
  DEVCONF_FORCE_TLLAO, 
  DEVCONF_MAX
};
# 46 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/netinet/in.h"
struct in6_addr;
struct in6_addr;
# 37 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/arpa/inet.h"
typedef uint32_t in_addr_t;

extern uint32_t inet_addr(const char *arg_0x7f7d46fe84a0);
# 51 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/sys/socket.h"
enum __nesc_unnamed4310 {
  SHUT_RD = 0, 

  SHUT_WR, 

  SHUT_RDWR
};



typedef int socklen_t;

extern int socket(int arg_0x7f7d46fdf2c8, int arg_0x7f7d46fdf530, int arg_0x7f7d46fdf798);
extern int bind(int arg_0x7f7d46fdd020, const struct sockaddr *arg_0x7f7d46fdd3b0, int arg_0x7f7d46fdd618);







extern int setsockopt(int arg_0x7f7d46fd40c8, int arg_0x7f7d46fd4330, int arg_0x7f7d46fd4598, const void *arg_0x7f7d46fd4870, socklen_t arg_0x7f7d46fd4b38);







extern ssize_t sendto(int arg_0x7f7d46fcc6a0, const void *arg_0x7f7d46fcc978, size_t arg_0x7f7d46fccc20, int arg_0x7f7d46fca020, const struct sockaddr *arg_0x7f7d46fca3b0, socklen_t arg_0x7f7d46fca678);
extern ssize_t recvfrom(int arg_0x7f7d46fc9020, void *arg_0x7f7d46fc92c0, size_t arg_0x7f7d46fc9568, unsigned int arg_0x7f7d46fc9808, const struct sockaddr *arg_0x7f7d46fc9b98, socklen_t *arg_0x7f7d46fc8020);
# 84 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/netdb.h"
struct hostent {
  char *h_name;
  char **h_aliases;
  int h_addrtype;
  int h_length;
  char **h_addr_list;
};


struct netent {
  char *n_name;
  char **n_aliases;
  int n_addrtype;
  uint32_t n_net;
};

struct servent {
  char *s_name;
  char **s_aliases;
  int s_port;
  char *s_proto;
};

struct protoent {
  char *p_name;
  char **p_aliases;
  int p_proto;
};

struct addrinfo {
  int ai_flags;
  int ai_family;
  int ai_socktype;
  int ai_protocol;
  socklen_t ai_addrlen;
  char *ai_canonname;
  struct sockaddr *ai_addr;
  struct addrinfo *ai_next;
};
#line 204
struct hostent;
struct hostent;

struct hostent;
struct hostent;
struct netent;
struct netent;
struct protoent;
struct protoent;
struct servent;
struct servent;
struct servent;



int getnameinfo(const struct sockaddr *arg_0x7f7d46fada40, socklen_t arg_0x7f7d46fadd08, char *arg_0x7f7d46fac020, size_t arg_0x7f7d46fac2c8, char *arg_0x7f7d46fac568, size_t arg_0x7f7d46fac810, int arg_0x7f7d46faca78);

const char *gai_strerror(int arg_0x7f7d46faac28);
# 29 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ifaddrs.h"
struct ifaddrs {
  struct ifaddrs *ifa_next;
  char *ifa_name;
  unsigned int ifa_flags;
  struct sockaddr *ifa_addr;
  struct sockaddr *ifa_netmask;
  struct sockaddr *ifa_dstaddr;
  void *ifa_data;
};
#line 50
extern int getifaddrs(struct ifaddrs **ifap);
# 44 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/errno.h"
extern volatile int *__errno(void );
# 11 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/setTimer.h"
extern void setSignal(int signum, __sighandler_t handler);
extern void setTimer(int which, const struct itimerval *new_value, struct itimerval *old_value);
# 9 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustom.h"
enum __nesc_unnamed4311 {



  O_CUSTOM_A = 20, 
  O_CUSTOM = 23, 
  O_SCREENCOLOR = 24, 

  O_SEND = 40, 
  O_SEND_ACK = 41, 




  I_CUSTOM_A_ID = 12, 
  I_CUSTOM_A = 13, 
  I_CUSTOM = 15, 

  I_SEND_DONE_ID = 40, 
  I_SEND_DONE = 41, 
  I_SEND_DONE_ACK_ID = 42, 
  I_SEND_DONE_ACK = 43, 
  I_RECEIVE_ID = 44, 
  I_RECEIVE = 45, 
  I_Q_READY = 46, 
  I_TOUCH = 47, 


  F_GETNODEID = 0, 
  F_RANDOM = 1, 
  F_GETMEM = 2, 
  F_GETTIME = 3, 

  F_QPUT = 10, 
  F_QGET = 11, 
  F_QSIZE = 12, 
  F_QCLEAR = 13, 



  TID_SENSOR_DONE = 0 << 5, 
  TID_TIMER_TRIGGER = 1 << 5, 
  TID_MSG_DONE = 2 << 5, 
  TID_MSG_REC = 3 << 5, 


  SENSOR_COUNT = 0
};







#line 60
typedef nx_struct qData {
  nx_uint8_t id;
  nx_uint8_t data[SEND_DATA_SIZE];
  nx_uint8_t len;
} __attribute__((packed)) qData_t;




#line 66
typedef nx_struct touchData {
  nx_uint16_t x;
  nx_uint16_t y;
} __attribute__((packed)) touchData_t;

void androidTouchEvent(uint16_t posX, uint16_t posY);
# 14 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/usrMsg.h"
enum __nesc_unnamed4312 {
  USRMSG_QSIZE = 10, 
  AM_USRMSG = 145
};







#line 20
typedef nx_struct usrMsg {
  nx_uint8_t type;
  nx_uint16_t source;
  nx_uint16_t target;
  nx_uint8_t data[SEND_DATA_SIZE];
} __attribute__((packed)) usrMsg_t;
typedef evtData_t TerraVMC__evtQ__t;
typedef TMilli BasicServicesP__SendDataFullTimer__precision_tag;
typedef TMilli BasicServicesP__TimerAsync__precision_tag;
typedef TMilli BasicServicesP__ProgReqTimer__precision_tag;
typedef TMilli BasicServicesP__TimerVM__precision_tag;
typedef TMilli BasicServicesP__sendTimer__precision_tag;
typedef TMilli UDPActiveMessageP__sendDoneTimer__precision_tag;
typedef TMilli UDPActiveMessageP__timerDelay__precision_tag;
enum HilTimerMilliC____nesc_unnamed4313 {
  HilTimerMilliC__TIMER_COUNT = 8U
};
typedef TMilli SingleTimerMilliP__TimerFrom__precision_tag;
typedef TMilli /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__precision_tag;
typedef /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__precision_tag /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__precision_tag;
typedef /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__precision_tag /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__precision_tag;
typedef GenericData_t /*BasicServicesC.inQueue*/dataQueueC__0__dataType;
typedef /*BasicServicesC.inQueue*/dataQueueC__0__dataType /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType;
typedef GenericData_t /*BasicServicesC.outQueue*/dataQueueC__1__dataType;
typedef /*BasicServicesC.outQueue*/dataQueueC__1__dataType /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType;
typedef uint16_t RandomMlcgC__SeedInit__parameter;
typedef evtData_t /*TerraVMAppC.evtQ*/QueueC__0__queue_t;
typedef /*TerraVMAppC.evtQ*/QueueC__0__queue_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__t;
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void TerraVMC__procEvent__runTask(void );
# 24 "VMCustom.nc"
static uint32_t TerraVMC__VMCustom__getTime(void );
#line 21
static void *TerraVMC__VMCustom__getRealAddr(uint16_t Maddr);
#line 17
static void TerraVMC__VMCustom__push(uint32_t val);
#line 16
static uint32_t TerraVMC__VMCustom__pop(void );

static void TerraVMC__VMCustom__queueEvt(uint8_t evtId, uint8_t auxId, void *data);
static int32_t TerraVMC__VMCustom__getMVal(uint16_t Maddr, uint8_t tp);
# 19 "BSTimer.nc"
static void TerraVMC__BSTimerAsync__fired(void );
# 20 "BSUpload.nc"
static void TerraVMC__BSUpload__stop(void );


static void TerraVMC__BSUpload__setEnv(newProgVersion_t *data);
#line 35
static void TerraVMC__BSUpload__loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]);






static uint16_t TerraVMC__BSUpload__progRestore(void );
#line 38
static uint8_t *TerraVMC__BSUpload__getSection(uint16_t Addr);
#line 32
static void TerraVMC__BSUpload__resetMemory(void );
#line 29
static void TerraVMC__BSUpload__start(bool resetFlag);
#line 26
static void TerraVMC__BSUpload__getEnv(newProgVersion_t *data);
# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
static void TerraVMC__BSBoot__booted(void );
# 19 "BSTimer.nc"
static void TerraVMC__BSTimerVM__fired(void );
# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
static error_t PlatformP__Init__init(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t SchedulerBasicP__TaskBasic__postTask(
# 59 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
uint8_t arg_0x7f7d477717d8);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void SchedulerBasicP__TaskBasic__default__runTask(
# 59 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
uint8_t arg_0x7f7d477717d8);
# 57 "/home/mauricio/Terra/TerraVM/src/interfaces/Scheduler.nc"
static void SchedulerBasicP__Scheduler__init(void );
#line 72
static void SchedulerBasicP__Scheduler__taskLoop(void );
#line 65
static bool SchedulerBasicP__Scheduler__runNextTask(void );
# 76 "/home/mauricio/Terra/TerraVM/src/interfaces/McuSleep.nc"
static void McuSleepC__McuSleep__sleep(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void BasicServicesP__ProgReqTimerTask__runTask(void );
# 9 "BSRadio.nc"
static error_t BasicServicesP__BSRadio__send(uint8_t am_id, uint16_t target, void *dataMsg, uint8_t dataSize, uint8_t reqAck);
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__SendDataFullTimer__fired(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void BasicServicesP__sendNextMsg__runTask(void );
# 110 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
static void BasicServicesP__RadioSender__sendDone(
# 34 "BasicServicesP.nc"
am_id_t arg_0x7f7d472828d8, 
# 103 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
message_t * msg, 






error_t error);
# 113 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
static void BasicServicesP__RadioControl__startDone(error_t error);
#line 138
static void BasicServicesP__RadioControl__stopDone(error_t error);
# 17 "BSTimer.nc"
static bool BasicServicesP__BSTimerAsync__isRunning(void );
#line 15
static void BasicServicesP__BSTimerAsync__startOneShot(uint32_t dt);
# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Receive.nc"
static 
#line 74
message_t * 



BasicServicesP__RadioReceiver__receive(
# 35 "BasicServicesP.nc"
am_id_t arg_0x7f7d47280500, 
# 71 "/home/mauricio/Terra/TerraVM/src/interfaces/Receive.nc"
message_t * msg, 
void * payload, 





uint8_t len);
# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static void BasicServicesP__outQ__dataReady(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void BasicServicesP__procInputEvent__runTask(void );
# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
static void BasicServicesP__TOSBoot__booted(void );
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__TimerAsync__fired(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void BasicServicesP__sendMessage__runTask(void );
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__ProgReqTimer__fired(void );
#line 83
static void BasicServicesP__TimerVM__fired(void );
# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static void BasicServicesP__inQ__dataReady(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void BasicServicesP__forceRadioDone__runTask(void );
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__sendTimer__fired(void );
# 16 "BSTimer.nc"
static uint32_t BasicServicesP__BSTimerVM__getNow(void );
#line 15
static void BasicServicesP__BSTimerVM__startOneShot(uint32_t dt);
# 104 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
static error_t UDPActiveMessageP__SplitControl__start(void );
# 2 "/home/mauricio/Terra/TerraVM/src/interfaces/AMAux.nc"
static void UDPActiveMessageP__AMAux__setPower(message_t *p_msg, uint8_t power);
# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Packet.nc"
static uint8_t UDPActiveMessageP__Packet__payloadLength(
#line 74
message_t * msg);
#line 126
static 
#line 123
void * 


UDPActiveMessageP__Packet__getPayload(
#line 121
message_t * msg, 




uint8_t len);
#line 106
static uint8_t UDPActiveMessageP__Packet__maxPayloadLength(void );
# 80 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
static error_t UDPActiveMessageP__AMSend__send(
# 7 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
am_id_t arg_0x7f7d46f9fc50, 
# 80 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
am_addr_t addr, 
#line 71
message_t * msg, 








uint8_t len);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void UDPActiveMessageP__receiveTask__runTask(void );
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void UDPActiveMessageP__sendDoneTimer__fired(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void UDPActiveMessageP__stop_done__runTask(void );
# 59 "/home/mauricio/Terra/TerraVM/src/interfaces/PacketAcknowledgements.nc"
static error_t UDPActiveMessageP__PacketAcknowledgements__requestAck(
#line 53
message_t * msg);
#line 71
static error_t UDPActiveMessageP__PacketAcknowledgements__noAck(
#line 65
message_t * msg);
#line 85
static bool UDPActiveMessageP__PacketAcknowledgements__wasAcked(
#line 80
message_t * msg);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void UDPActiveMessageP__send_doneAck__runTask(void );
#line 75
static void UDPActiveMessageP__send_done__runTask(void );
# 88 "/home/mauricio/Terra/TerraVM/src/interfaces/AMPacket.nc"
static am_addr_t UDPActiveMessageP__AMPacket__source(
#line 84
message_t * amsg);
#line 68
static am_addr_t UDPActiveMessageP__AMPacket__address(void );









static am_addr_t UDPActiveMessageP__AMPacket__destination(
#line 74
message_t * amsg);
#line 121
static void UDPActiveMessageP__AMPacket__setSource(
#line 117
message_t * amsg, 



am_addr_t addr);
#line 103
static void UDPActiveMessageP__AMPacket__setDestination(
#line 99
message_t * amsg, 



am_addr_t addr);
#line 147
static am_id_t UDPActiveMessageP__AMPacket__type(
#line 143
message_t * amsg);
#line 162
static void UDPActiveMessageP__AMPacket__setType(
#line 158
message_t * amsg, 



am_id_t t);
#line 136
static bool UDPActiveMessageP__AMPacket__isForMe(
#line 133
message_t * amsg);
#line 187
static void UDPActiveMessageP__AMPacket__setGroup(
#line 184
message_t * amsg, 


am_group_t grp);
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void UDPActiveMessageP__timerDelay__fired(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void UDPActiveMessageP__start_done__runTask(void );
# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
static error_t SingleTimerMilliP__SoftwareInit__init(void );
# 136 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static uint32_t SingleTimerMilliP__TimerFrom__getNow(void );
#line 129
static void SingleTimerMilliP__TimerFrom__startOneShotAt(uint32_t t0, uint32_t dt);
#line 78
static void SingleTimerMilliP__TimerFrom__stop(void );
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void SingleTimerMilliP__tarefaTimer__runTask(void );
#line 75
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__runTask(void );
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__fired(void );
#line 136
static uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getNow(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__default__fired(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
# 151 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getdt(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
# 92 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static bool /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998, 
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
uint32_t dt);




static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
# 94 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
static void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__resetRange(uint16_t from, uint16_t to);
#line 50
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__get(uint16_t bitnum);





static void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__set(uint16_t bitnum);
#line 87
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__isAllBitSet(void );
#line 38
static void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clearAll(void );
#line 62
static void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clear(uint16_t bitnum);
#line 50
static bool /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__get(uint16_t bitnum);





static void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__set(uint16_t bitnum);
# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__get(void *Data);

static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__read(void *Data);
#line 8
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__put(void *Data);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__runTask(void );
# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__get(void *Data);

static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__read(void *Data);
#line 8
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__put(void *Data);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__runTask(void );
# 52 "/home/mauricio/Terra/TerraVM/src/interfaces/Random.nc"
static uint16_t RandomMlcgC__Random__rand16(void );
#line 46
static uint32_t RandomMlcgC__Random__rand32(void );
# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
static error_t RandomMlcgC__Init__init(void );
# 27 "ProgStorage.nc"
static error_t ProgStorageP__ProgStorage__restore(uint8_t *bytecode, uint16_t len);
#line 12
static error_t ProgStorageP__ProgStorage__save(progEnv_t *env, uint8_t *bytecode, uint16_t len);






static error_t ProgStorageP__ProgStorage__getEnv(progEnv_t *env);
# 56 "/home/mauricio/Terra/TerraVM/src/interfaces/InternalFlash.nc"
static error_t RPI_InternalFlashP__IntFlash__read(void *addr, 
#line 50
void * buf, 





uint16_t size);
#line 68
static error_t RPI_InternalFlashP__IntFlash__write(void *addr, 
#line 63
void * buf, 




uint16_t size);
# 13 "VMCustom.nc"
static void VMCustomP__VM__procOutEvt(uint8_t id, uint32_t value);
static void VMCustomP__VM__callFunction(uint8_t id);
static void VMCustomP__VM__reset(void );
# 12 "BSRadio.nc"
static void VMCustomP__BSRadio__receive(uint8_t am_id, message_t *msg, void *payload, uint8_t len);
#line 11
static void VMCustomP__BSRadio__sendDoneAck(uint8_t am_id, message_t *msg, void *dataMsg, error_t error, bool wasAcked);
#line 10
static void VMCustomP__BSRadio__sendDone(uint8_t am_id, message_t *msg, void *dataMsg, error_t error);
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void VMCustomP__BCRadio_receive__runTask(void );
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Queue.nc"
static 
#line 71
/*TerraVMAppC.evtQ*/QueueC__0__Queue__t  

/*TerraVMAppC.evtQ*/QueueC__0__Queue__head(void );
#line 90
static error_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__enqueue(
#line 86
/*TerraVMAppC.evtQ*/QueueC__0__Queue__t  newVal);
#line 65
static uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__maxSize(void );
#line 81
static 
#line 79
/*TerraVMAppC.evtQ*/QueueC__0__Queue__t  

/*TerraVMAppC.evtQ*/QueueC__0__Queue__dequeue(void );
#line 50
static bool /*TerraVMAppC.evtQ*/QueueC__0__Queue__empty(void );







static uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__size(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t TerraVMC__procEvent__postTask(void );
# 13 "VMCustom.nc"
static void TerraVMC__VMCustom__procOutEvt(uint8_t id, uint32_t value);
static void TerraVMC__VMCustom__callFunction(uint8_t id);
static void TerraVMC__VMCustom__reset(void );
# 27 "ProgStorage.nc"
static error_t TerraVMC__ProgStorage__restore(uint8_t *bytecode, uint16_t len);
#line 12
static error_t TerraVMC__ProgStorage__save(progEnv_t *env, uint8_t *bytecode, uint16_t len);






static error_t TerraVMC__ProgStorage__getEnv(progEnv_t *env);
# 17 "BSTimer.nc"
static bool TerraVMC__BSTimerAsync__isRunning(void );
#line 15
static void TerraVMC__BSTimerAsync__startOneShot(uint32_t dt);
# 90 "/home/mauricio/Terra/TerraVM/src/interfaces/Queue.nc"
static error_t TerraVMC__evtQ__enqueue(
#line 86
TerraVMC__evtQ__t  newVal);
#line 81
static 
#line 79
TerraVMC__evtQ__t  

TerraVMC__evtQ__dequeue(void );
#line 58
static uint8_t TerraVMC__evtQ__size(void );
# 16 "BSTimer.nc"
static uint32_t TerraVMC__BSTimerVM__getNow(void );
#line 15
static void TerraVMC__BSTimerVM__startOneShot(uint32_t dt);
# 71 "TerraVMC.nc"
enum TerraVMC____nesc_unnamed4314 {
#line 71
  TerraVMC__procEvent = 0U
};
#line 71
typedef int TerraVMC____nesc_sillytask_procEvent[TerraVMC__procEvent];
#line 31
uint32_t TerraVMC__old;

nx_uint16_t TerraVMC__MoteID;

nx_uint8_t TerraVMC__CEU_data[BLOCK_SIZE * CURRENT_MAX_BLOCKS];

uint16_t TerraVMC__PC;

bool TerraVMC__haltedFlag = TRUE;

bool TerraVMC__procFlag = FALSE;

nx_uint8_t TerraVMC__ExtDataSysError;

bool TerraVMC__progRestored = FALSE;


progEnv_t TerraVMC__envData;
#line 62
nx_uint8_t *TerraVMC__MEM;


uint16_t TerraVMC__currStack = BLOCK_SIZE * CURRENT_MAX_BLOCKS - 1 - 4;






static inline void TerraVMC__Decoder(uint8_t Opcode, uint8_t Modifier);
static inline void TerraVMC__ceu_boot(void );
static void TerraVMC__push(uint32_t value);
static uint32_t TerraVMC__pop(void );
static void TerraVMC__pushf(float value);
static float TerraVMC__popf(void );


static inline void TerraVMC__ceu_out_wclock(uint32_t ms);





static inline void TerraVMC__BSBoot__booted(void );










static uint8_t TerraVMC__getOpCode(uint8_t *Opcode, uint8_t *Modifier);
#line 113
static inline uint16_t TerraVMC__getLblAddr(uint16_t lbl);









static inline void TerraVMC__TViewer(char *cmd, uint16_t p1, uint16_t p2);






static void TerraVMC__evtError(uint8_t ecode);
#line 149
static uint8_t TerraVMC__getPar8(uint8_t p_len);





static uint16_t TerraVMC__getPar16(uint8_t p_len);
#line 169
static uint32_t TerraVMC__getPar32(uint8_t p_len);
#line 184
static uint8_t TerraVMC__getBits(uint8_t data, uint8_t stBit, uint8_t endBit);





static inline uint8_t TerraVMC__getBitsPow(uint8_t data, uint8_t stBit, uint8_t endBit);


static uint32_t TerraVMC__unit2val(uint32_t val, uint8_t unit);









static void TerraVMC__push(uint32_t value);
#line 216
static void TerraVMC__pushf(float value);
#line 230
static uint32_t TerraVMC__pop(void );



static float TerraVMC__popf(void );




static uint32_t TerraVMC__getMVal(uint16_t Maddr, uint8_t type);
#line 251
static inline float TerraVMC__getMValf(uint16_t Maddr);



static void TerraVMC__setMVal(uint32_t buffer, uint16_t Maddr, uint8_t fromTp, uint8_t toTp);
#line 298
static inline uint16_t TerraVMC__getEvtCeuId(uint8_t EvtId);
#line 356
#line 353
typedef nx_struct TerraVMC____nesc_unnamed4315 {
  nx_int32_t togo;
  nx_uint16_t lbl;
} __attribute__((packed)) TerraVMC__tceu_wclock;





#line 358
typedef nx_struct TerraVMC____nesc_unnamed4316 {
  nx_uint8_t stack;
  nx_uint8_t tree;
  nx_uint16_t lbl;
} __attribute__((packed)) TerraVMC__tceu_trk;

enum TerraVMC____nesc_unnamed4317 {
  TerraVMC__Inactive = 0, 
  TerraVMC__Init = 1
};


static int TerraVMC__ceu_go(int *ret);
#line 383
#line 373
typedef struct TerraVMC____nesc_unnamed4318 {
  int tracks_n;
  u8 stack;
  void *ext_data;
  int ext_int;
  int wclk_late;
  TerraVMC__tceu_wclock *wclk_cur;
  int async_cur;
  TerraVMC__tceu_trk *p_tracks;
  nx_uint8_t *p_mem;
} TerraVMC__tceu;



TerraVMC__tceu TerraVMC__CEU_ = { 
0, 
0x01, 
(void *)0, 
0, 
0, 
(void *)0, 
0, 
(void *)0, 
(void *)0 };




static int TerraVMC__ceu_track_cmp(TerraVMC__tceu_trk *trk1, TerraVMC__tceu_trk *trk2);
#line 415
static void TerraVMC__ceu_track_ins(u8 stack, u8 tree, int chk, uint16_t lbl);
#line 450
static int TerraVMC__ceu_track_rem(TerraVMC__tceu_trk *trk, u8 N);
#line 480
static inline void TerraVMC__ceu_track_clr(uint16_t l1, uint16_t l2);










static void TerraVMC__ceu_spawn(nx_uint16_t *lbl);







static void TerraVMC__ceu_trigger(uint16_t off, uint8_t auxId);
#line 530
static int TerraVMC__ceu_wclock_lt(TerraVMC__tceu_wclock *tmr);










static void TerraVMC__ceu_wclock_enable(int gte, s32 us, uint16_t lbl);
#line 558
static inline void TerraVMC__ceu_async_enable(int gte, uint16_t lbl);







static inline int TerraVMC__ceu_go_init(int *ret);
#line 580
static inline int TerraVMC__ceu_go_event(int *ret, int id, uint8_t auxId, void *data);
#line 596
static inline int TerraVMC__ceu_go_async(int *ret, int *pending);
#line 632
static int TerraVMC__ceu_go_wclock(int *ret, s32 dt, s32 *nxt);
#line 689
static inline void TerraVMC__execTrail(uint16_t lbl);
#line 711
static int TerraVMC__ceu_go(int *ret);
#line 766
static inline void TerraVMC__ceu_boot(void );









static inline void TerraVMC__f_nop(uint8_t Modifier);

static inline void TerraVMC__f_end(uint8_t Modifier);




static inline void TerraVMC__f_bnot(uint8_t Modifier);






static inline void TerraVMC__f_lnot(uint8_t Modifier);






static inline void TerraVMC__f_neg(uint8_t Modifier);






static inline void TerraVMC__f_sub(uint8_t Modifier);








static inline void TerraVMC__f_add(uint8_t Modifier);








static inline void TerraVMC__f_mod(uint8_t Modifier);









static inline void TerraVMC__f_mult(uint8_t Modifier);








static inline void TerraVMC__f_div(uint8_t Modifier);









static inline void TerraVMC__f_bor(uint8_t Modifier);







static inline void TerraVMC__f_band(uint8_t Modifier);







static inline void TerraVMC__f_lshft(uint8_t Modifier);







static inline void TerraVMC__f_rshft(uint8_t Modifier);







static inline void TerraVMC__f_bxor(uint8_t Modifier);







static inline void TerraVMC__f_eq(uint8_t Modifier);








static inline void TerraVMC__f_neq(uint8_t Modifier);







static inline void TerraVMC__f_gte(uint8_t Modifier);







static inline void TerraVMC__f_lte(uint8_t Modifier);







static inline void TerraVMC__f_gt(uint8_t Modifier);







static inline void TerraVMC__f_lt(uint8_t Modifier);







static inline void TerraVMC__f_lor(uint8_t Modifier);







static inline void TerraVMC__f_land(uint8_t Modifier);








static inline void TerraVMC__f_neg_f(uint8_t Modifier);







static inline void TerraVMC__f_sub_f(uint8_t Modifier);







static inline void TerraVMC__f_add_f(uint8_t Modifier);







static inline void TerraVMC__f_mult_f(uint8_t Modifier);







static inline void TerraVMC__f_div_f(uint8_t Modifier);








static inline void TerraVMC__f_eq_f(uint8_t Modifier);








static inline void TerraVMC__f_neq_f(uint8_t Modifier);







static inline void TerraVMC__f_gte_f(uint8_t Modifier);







static inline void TerraVMC__f_lte_f(uint8_t Modifier);







static inline void TerraVMC__f_gt_f(uint8_t Modifier);







static inline void TerraVMC__f_lt_f(uint8_t Modifier);








static inline void TerraVMC__f_func(uint8_t Modifier);







static inline void TerraVMC__f_outevt_e(uint8_t Modifier);









static inline void TerraVMC__f_outevt_z(uint8_t Modifier);






static inline void TerraVMC__f_clken_e(uint8_t Modifier);
#line 1089
static inline void TerraVMC__f_clken_v(uint8_t Modifier);
#line 1109
static inline void TerraVMC__f_clken_c(uint8_t Modifier);
#line 1127
static inline void TerraVMC__f_set_v(uint8_t Modifier);
#line 1150
static inline void TerraVMC__f_setarr_vc(uint8_t Modifier);
#line 1185
static inline void TerraVMC__f_setarr_vv(uint8_t Modifier);
#line 1227
static inline void TerraVMC__f_poparr_v(uint8_t Modifier);
#line 1262
static inline void TerraVMC__f_pusharr_v(uint8_t Modifier);
#line 1290
static inline void TerraVMC__f_getextdt_e(uint8_t Modifier);










static inline void TerraVMC__f_trg(uint8_t Modifier);









static inline void TerraVMC__f_exec(uint8_t Modifier);









static inline void TerraVMC__f_chkret(uint8_t Modifier);









static inline void TerraVMC__f_push_c(uint8_t Modifier);








static inline void TerraVMC__f_cast(uint8_t Modifier);
#line 1354
static inline void TerraVMC__f_memclr(uint8_t Modifier);
#line 1367
static inline void TerraVMC__f_ifelse(uint8_t Modifier);
#line 1379
static inline void TerraVMC__f_asen(uint8_t Modifier);
#line 1391
static inline void TerraVMC__f_tkclr(uint8_t Modifier);
#line 1403
static inline void TerraVMC__f_outevt_c(uint8_t Modifier);










static inline void TerraVMC__f_getextdt_v(uint8_t Modifier);
#line 1426
static inline void TerraVMC__f_inc(uint8_t Modifier);








static inline void TerraVMC__f_dec(uint8_t Modifier);









static inline void TerraVMC__f_set_e(uint8_t Modifier);
#line 1462
static inline void TerraVMC__f_deref(uint8_t Modifier);
#line 1479
static inline void TerraVMC__f_memcpy(uint8_t Modifier);
#line 1492
static inline void TerraVMC__f_tkins_z(uint8_t Modifier);
#line 1505
static inline void TerraVMC__f_tkins_max(uint8_t Modifier);










static inline void TerraVMC__f_push_v(uint8_t Modifier);
#line 1533
static inline void TerraVMC__f_pop(uint8_t Modifier);
#line 1552
static inline void TerraVMC__f_popx(uint8_t Modifier);




static inline void TerraVMC__f_outevt_v(uint8_t Modifier);
#line 1570
static inline void TerraVMC__f_set_c(uint8_t Modifier);
#line 1591
static inline void TerraVMC__Decoder(uint8_t Opcode, uint8_t Modifier);
#line 1685
static void TerraVMC__VMCustom__queueEvt(uint8_t evtId, uint8_t auxId, void *data);
#line 1702
static inline void TerraVMC__update_wclk_late(void );










static inline void TerraVMC__procEvent__runTask(void );
#line 1740
static inline int32_t TerraVMC__VMCustom__getMVal(uint16_t Maddr, uint8_t tp);






static void *TerraVMC__VMCustom__getRealAddr(uint16_t Maddr);





static inline uint32_t TerraVMC__VMCustom__pop(void );


static inline void TerraVMC__VMCustom__push(uint32_t value);







static inline uint32_t TerraVMC__VMCustom__getTime(void );




static inline void TerraVMC__BSTimerVM__fired(void );









static inline bool TerraVMC__hasAsync(void );










static inline void TerraVMC__BSTimerAsync__fired(void );
#line 1802
static inline void TerraVMC__BSUpload__stop(void );





static inline void TerraVMC__BSUpload__setEnv(newProgVersion_t *data);
#line 1828
static inline void TerraVMC__BSUpload__getEnv(newProgVersion_t *data);
#line 1847
static void TerraVMC__BSUpload__start(bool resetFlag);
#line 1872
static inline uint8_t *TerraVMC__BSUpload__getSection(uint16_t Addr);



static void TerraVMC__BSUpload__resetMemory(void );
#line 1890
static inline void TerraVMC__BSUpload__loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]);




static inline uint16_t TerraVMC__BSUpload__progRestore(void );
# 8 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/PlatformP.nc"
static inline error_t PlatformP__Init__init(void );
# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
static error_t RealMainP__SoftwareInit__init(void );
# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
static void RealMainP__Boot__booted(void );
# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
static error_t RealMainP__PlatformInit__init(void );
# 57 "/home/mauricio/Terra/TerraVM/src/interfaces/Scheduler.nc"
static void RealMainP__Scheduler__init(void );
#line 72
static void RealMainP__Scheduler__taskLoop(void );
#line 65
static bool RealMainP__Scheduler__runNextTask(void );
# 69 "/home/mauricio/Terra/TerraVM/src/system/RealMainP.nc"
void android_main(struct android_app *state)   ;
# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void SchedulerBasicP__TaskBasic__runTask(
# 59 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
uint8_t arg_0x7f7d477717d8);
# 76 "/home/mauricio/Terra/TerraVM/src/interfaces/McuSleep.nc"
static void SchedulerBasicP__McuSleep__sleep(void );
# 64 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
enum SchedulerBasicP____nesc_unnamed4319 {

  SchedulerBasicP__NUM_TASKS = 16U, 
  SchedulerBasicP__NO_TASK = 255
};

uint8_t SchedulerBasicP__m_head;
uint8_t SchedulerBasicP__m_tail;
uint8_t SchedulerBasicP__m_next[SchedulerBasicP__NUM_TASKS];








static __inline uint8_t SchedulerBasicP__popTask(void );
#line 100
static inline bool SchedulerBasicP__isWaiting(uint8_t id);




static inline bool SchedulerBasicP__pushTask(uint8_t id);
#line 127
static inline void SchedulerBasicP__Scheduler__init(void );









static bool SchedulerBasicP__Scheduler__runNextTask(void );
#line 152
static inline void SchedulerBasicP__Scheduler__taskLoop(void );
#line 176
static error_t SchedulerBasicP__TaskBasic__postTask(uint8_t id);




static void SchedulerBasicP__TaskBasic__default__runTask(uint8_t id);
# 11 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/McuSleepC.nc"
static inline void McuSleepC__McuSleep__sleep(void );
# 38 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
static void BasicServicesP__BMaux__clearAll(void );
#line 62
static void BasicServicesP__BMaux__clear(uint16_t bitnum);
#line 50
static bool BasicServicesP__BMaux__get(uint16_t bitnum);





static void BasicServicesP__BMaux__set(uint16_t bitnum);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t BasicServicesP__ProgReqTimerTask__postTask(void );
# 12 "BSRadio.nc"
static void BasicServicesP__BSRadio__receive(uint8_t am_id, message_t *msg, void *payload, uint8_t len);
#line 11
static void BasicServicesP__BSRadio__sendDoneAck(uint8_t am_id, message_t *msg, void *dataMsg, error_t error, bool wasAcked);
#line 10
static void BasicServicesP__BSRadio__sendDone(uint8_t am_id, message_t *msg, void *dataMsg, error_t error);
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__SendDataFullTimer__startOneShot(uint32_t dt);
# 88 "/home/mauricio/Terra/TerraVM/src/interfaces/AMPacket.nc"
static am_addr_t BasicServicesP__RadioAMPacket__source(
#line 84
message_t * amsg);
#line 147
static am_id_t BasicServicesP__RadioAMPacket__type(
#line 143
message_t * amsg);
# 2 "/home/mauricio/Terra/TerraVM/src/interfaces/AMAux.nc"
static void BasicServicesP__AMAux__setPower(message_t *p_msg, uint8_t power);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t BasicServicesP__sendNextMsg__postTask(void );
# 80 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
static error_t BasicServicesP__RadioSender__send(
# 34 "BasicServicesP.nc"
am_id_t arg_0x7f7d472828d8, 
# 80 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
am_addr_t addr, 
#line 71
message_t * msg, 








uint8_t len);
# 104 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
static error_t BasicServicesP__RadioControl__start(void );
# 19 "BSTimer.nc"
static void BasicServicesP__BSTimerAsync__fired(void );
# 126 "/home/mauricio/Terra/TerraVM/src/interfaces/Packet.nc"
static 
#line 123
void * 


BasicServicesP__RadioPacket__getPayload(
#line 121
message_t * msg, 




uint8_t len);
#line 106
static uint8_t BasicServicesP__RadioPacket__maxPayloadLength(void );
# 46 "/home/mauricio/Terra/TerraVM/src/interfaces/Random.nc"
static uint32_t BasicServicesP__Random__rand32(void );
# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static error_t BasicServicesP__outQ__get(void *Data);

static error_t BasicServicesP__outQ__read(void *Data);
#line 8
static error_t BasicServicesP__outQ__put(void *Data);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t BasicServicesP__procInputEvent__postTask(void );
# 151 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static uint32_t BasicServicesP__TimerAsync__getdt(void );
#line 92
static bool BasicServicesP__TimerAsync__isRunning(void );
#line 73
static void BasicServicesP__TimerAsync__startOneShot(uint32_t dt);




static void BasicServicesP__TimerAsync__stop(void );
# 59 "/home/mauricio/Terra/TerraVM/src/interfaces/PacketAcknowledgements.nc"
static error_t BasicServicesP__RadioAck__requestAck(
#line 53
message_t * msg);
#line 71
static error_t BasicServicesP__RadioAck__noAck(
#line 65
message_t * msg);
#line 85
static bool BasicServicesP__RadioAck__wasAcked(
#line 80
message_t * msg);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t BasicServicesP__sendMessage__postTask(void );
# 20 "BSUpload.nc"
static void BasicServicesP__BSUpload__stop(void );


static void BasicServicesP__BSUpload__setEnv(newProgVersion_t *data);
#line 35
static void BasicServicesP__BSUpload__loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]);






static uint16_t BasicServicesP__BSUpload__progRestore(void );
#line 38
static uint8_t *BasicServicesP__BSUpload__getSection(uint16_t Addr);
#line 32
static void BasicServicesP__BSUpload__resetMemory(void );
#line 29
static void BasicServicesP__BSUpload__start(bool resetFlag);
#line 26
static void BasicServicesP__BSUpload__getEnv(newProgVersion_t *data);
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__ProgReqTimer__startOneShot(uint32_t dt);




static void BasicServicesP__ProgReqTimer__stop(void );
# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
static void BasicServicesP__BSBoot__booted(void );
# 136 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static uint32_t BasicServicesP__TimerVM__getNow(void );
#line 151
static uint32_t BasicServicesP__TimerVM__getdt(void );
#line 92
static bool BasicServicesP__TimerVM__isRunning(void );
#line 73
static void BasicServicesP__TimerVM__startOneShot(uint32_t dt);




static void BasicServicesP__TimerVM__stop(void );
# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static error_t BasicServicesP__inQ__get(void *Data);

static error_t BasicServicesP__inQ__read(void *Data);
#line 8
static error_t BasicServicesP__inQ__put(void *Data);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t BasicServicesP__forceRadioDone__postTask(void );
# 94 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
static void BasicServicesP__BM__resetRange(uint16_t from, uint16_t to);
#line 50
static bool BasicServicesP__BM__get(uint16_t bitnum);





static void BasicServicesP__BM__set(uint16_t bitnum);
#line 87
static bool BasicServicesP__BM__isAllBitSet(void );
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void BasicServicesP__sendTimer__startOneShot(uint32_t dt);
# 19 "BSTimer.nc"
static void BasicServicesP__BSTimerVM__fired(void );
# 179 "BasicServicesP.nc"
enum BasicServicesP____nesc_unnamed4320 {
#line 179
  BasicServicesP__ProgReqTimerTask = 1U
};
#line 179
typedef int BasicServicesP____nesc_sillytask_ProgReqTimerTask[BasicServicesP__ProgReqTimerTask];
#line 1123
enum BasicServicesP____nesc_unnamed4321 {
#line 1123
  BasicServicesP__procInputEvent = 2U
};
#line 1123
typedef int BasicServicesP____nesc_sillytask_procInputEvent[BasicServicesP__procInputEvent];
#line 1160
enum BasicServicesP____nesc_unnamed4322 {
#line 1160
  BasicServicesP__forceRadioDone = 3U
};
#line 1160
typedef int BasicServicesP____nesc_sillytask_forceRadioDone[BasicServicesP__forceRadioDone];
#line 1232
enum BasicServicesP____nesc_unnamed4323 {
#line 1232
  BasicServicesP__sendMessage = 4U
};
#line 1232
typedef int BasicServicesP____nesc_sillytask_sendMessage[BasicServicesP__sendMessage];
#line 1284
enum BasicServicesP____nesc_unnamed4324 {
#line 1284
  BasicServicesP__sendNextMsg = 5U
};
#line 1284
typedef int BasicServicesP____nesc_sillytask_sendNextMsg[BasicServicesP__sendNextMsg];
#line 103
uint8_t BasicServicesP__TERRA_MOTE_TYPE = 1;


nx_uint16_t BasicServicesP__MoteID;
bool BasicServicesP__firstInic = TRUE;
uint32_t BasicServicesP__reSendDelay;

GenericData_t BasicServicesP__tempInputInQ;
GenericData_t BasicServicesP__tempInputOutQ;
GenericData_t BasicServicesP__tempOutputInQ;
GenericData_t BasicServicesP__tempOutputOutQ;
GenericData_t BasicServicesP__lastNewProgVersion;
uint16_t BasicServicesP__lastRequestBlock;
message_t BasicServicesP__sendBuff;










uint8_t BasicServicesP__sendCounter;


uint8_t BasicServicesP__userRFPowerIdx;


uint8_t BasicServicesP__ReqState = ST_IDLE;


nx_uint16_t BasicServicesP__ProgVersion;
nx_uint16_t BasicServicesP__ProgMoteSource;
nx_uint16_t BasicServicesP__ProgBlockStart;
nx_uint16_t BasicServicesP__ProgBlockLen;
uint8_t BasicServicesP__loadingProgramFlag = FALSE;

uint8_t BasicServicesP__ProgTimeOutCounter = 0;
uint16_t BasicServicesP__DsmBlockCount = 0;
nx_uint16_t BasicServicesP__lastRecNewProgVersion;
uint16_t BasicServicesP__lastRecParentId = 0;



nx_uint16_t BasicServicesP__NewDataSeq;
nx_uint16_t BasicServicesP__maxSeenDataSeq;

nx_uint16_t BasicServicesP__NewDataMoteSource;


uint16_t BasicServicesP__disseminatorRoot = 0;


int32_t BasicServicesP__lastBigAppVersion = -1L;


uint16_t BasicServicesP__lastRecNewProgBlock_versionId = 0;
#line 175
static void BasicServicesP__sendReqProgBlock(reqProgBlock_t *Data);
static inline void BasicServicesP__sendNewProgVersion(newProgVersion_t *Data);
static void BasicServicesP__sendNewProgBlock(newProgBlock_t *Data);





static inline void BasicServicesP__TViewer(char *cmd, uint16_t p1, uint16_t p2);
#line 195
static inline void BasicServicesP__inicCtlData(void );
#line 215
static inline void BasicServicesP__TOSBoot__booted(void );
#line 244
static inline uint32_t BasicServicesP__getRequestTimeout(void );




static inline void BasicServicesP__RadioControl__startDone(error_t error);
#line 299
static inline void BasicServicesP__RadioControl__stopDone(error_t error);
#line 314
static inline uint32_t BasicServicesP__BSTimerVM__getNow(void );
static void BasicServicesP__BSTimerVM__startOneShot(uint32_t dt);






static inline void BasicServicesP__TimerVM__fired(void );








static void BasicServicesP__BSTimerAsync__startOneShot(uint32_t dt);




static inline bool BasicServicesP__BSTimerAsync__isRunning(void );

static inline void BasicServicesP__TimerAsync__fired(void );
#line 351
static inline uint16_t BasicServicesP__getNextEmptyBlock(void );
#line 462
static inline void BasicServicesP__recNewProgVersionNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial);
#line 544
static inline void BasicServicesP__recNewProgBlockNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial);
#line 600
static inline void BasicServicesP__recReqProgBlockNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial);
#line 632
static inline void BasicServicesP__recSetDataNDNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial);
#line 656
static inline void BasicServicesP__recCustomMsgNet_receive(message_t *msg, void *payload, uint8_t len);









static inline void BasicServicesP__recReqDataNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial);
#line 680
static inline message_t *BasicServicesP__RadioReceiver__receive(am_id_t id, message_t *msg, void *payload, uint8_t len);
#line 788
static inline void BasicServicesP__procNewProgVersion(newProgVersion_t *Data);
#line 822
static inline void BasicServicesP__procNewProgBlock(newProgBlock_t *Data);
#line 854
static inline void BasicServicesP__procRecReqProgBlock(reqProgBlock_t *Data);
#line 900
static inline void BasicServicesP__ProgReqTimerTask__runTask(void );
#line 990
static inline void BasicServicesP__ProgReqTimer__fired(void );




static inline void BasicServicesP__SendDataFullTimer__fired(void );
#line 1123
static inline void BasicServicesP__procInputEvent__runTask(void );
#line 1151
static inline void BasicServicesP__inQ__dataReady(void );








static inline void BasicServicesP__forceRadioDone__runTask(void );





static inline uint8_t BasicServicesP__isOtherNet(uint16_t addr);






static inline error_t BasicServicesP__RadioSender_send(uint8_t am_id, uint16_t target, message_t *msg, uint8_t len, uint8_t fromSerial);
#line 1204
static void BasicServicesP__sendRadioN(void );
#line 1232
static inline void BasicServicesP__sendMessage__runTask(void );
#line 1274
static inline void BasicServicesP__outQ__dataReady(void );









static inline void BasicServicesP__sendNextMsg__runTask(void );









static inline void BasicServicesP__sendTimer__fired(void );
#line 1306
static void BasicServicesP__RadioSender_sendDone(am_id_t id, message_t *msg, error_t error);
#line 1351
static inline void BasicServicesP__RadioSender__sendDone(am_id_t id, message_t *msg, error_t error);
#line 1402
static inline void BasicServicesP__sendNewProgVersion(newProgVersion_t *Data);
#line 1419
static void BasicServicesP__sendNewProgBlock(newProgBlock_t *Data);
#line 1436
static void BasicServicesP__sendReqProgBlock(reqProgBlock_t *Data);
#line 1487
static inline error_t BasicServicesP__BSRadio__send(uint8_t am_id, uint16_t target, void *dataMsg, uint8_t dataSize, uint8_t reqAck);
# 113 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
static void UDPActiveMessageP__SplitControl__startDone(error_t error);
#line 138
static void UDPActiveMessageP__SplitControl__stopDone(error_t error);
# 110 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
static void UDPActiveMessageP__AMSend__sendDone(
# 7 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
am_id_t arg_0x7f7d46f9fc50, 
# 103 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
message_t * msg, 






error_t error);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t UDPActiveMessageP__receiveTask__postTask(void );
# 92 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static bool UDPActiveMessageP__sendDoneTimer__isRunning(void );
#line 73
static void UDPActiveMessageP__sendDoneTimer__startOneShot(uint32_t dt);




static void UDPActiveMessageP__sendDoneTimer__stop(void );
# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Receive.nc"
static 
#line 74
message_t * 



UDPActiveMessageP__Receive__receive(
# 8 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
am_id_t arg_0x7f7d46f9ed68, 
# 71 "/home/mauricio/Terra/TerraVM/src/interfaces/Receive.nc"
message_t * msg, 
void * payload, 





uint8_t len);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t UDPActiveMessageP__send_doneAck__postTask(void );
#line 67
static error_t UDPActiveMessageP__send_done__postTask(void );
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void UDPActiveMessageP__timerDelay__startOneShot(uint32_t dt);
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t UDPActiveMessageP__start_done__postTask(void );
# 81 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
enum UDPActiveMessageP____nesc_unnamed4325 {
#line 81
  UDPActiveMessageP__send_doneAck = 6U
};
#line 81
typedef int UDPActiveMessageP____nesc_sillytask_send_doneAck[UDPActiveMessageP__send_doneAck];




enum UDPActiveMessageP____nesc_unnamed4326 {
#line 86
  UDPActiveMessageP__send_done = 7U
};
#line 86
typedef int UDPActiveMessageP____nesc_sillytask_send_done[UDPActiveMessageP__send_done];




enum UDPActiveMessageP____nesc_unnamed4327 {
#line 91
  UDPActiveMessageP__receiveTask = 8U
};
#line 91
typedef int UDPActiveMessageP____nesc_sillytask_receiveTask[UDPActiveMessageP__receiveTask];
#line 166
enum UDPActiveMessageP____nesc_unnamed4328 {
#line 166
  UDPActiveMessageP__start_done = 9U
};
#line 166
typedef int UDPActiveMessageP____nesc_sillytask_start_done[UDPActiveMessageP__start_done];


enum UDPActiveMessageP____nesc_unnamed4329 {
#line 169
  UDPActiveMessageP__stop_done = 10U
};
#line 169
typedef int UDPActiveMessageP____nesc_sillytask_stop_done[UDPActiveMessageP__stop_done];
#line 24
int UDPActiveMessageP__socket_sender;
int UDPActiveMessageP__socket_receiver;

int UDPActiveMessageP__counter = 0;
message_t *UDPActiveMessageP__lastSendMessage;
message_t UDPActiveMessageP__lastReceiveMessage;
struct sockaddr_in UDPActiveMessageP__addrSender;

static inline serial_header_t * UDPActiveMessageP__getHeader(message_t * msg);



static inline serial_metadata_t *UDPActiveMessageP__getMetadata(message_t *msg);



static inline uint16_t UDPActiveMessageP__getID_fromIP(void );
#line 81
static inline void UDPActiveMessageP__send_doneAck__runTask(void );




static inline void UDPActiveMessageP__send_done__runTask(void );




static inline void UDPActiveMessageP__receiveTask__runTask(void );



static inline void UDPActiveMessageP__UDP_HandleReceiver(int signum);
#line 149
static inline void UDPActiveMessageP__timerDelay__fired(void );
#line 166
static inline void UDPActiveMessageP__start_done__runTask(void );


static inline void UDPActiveMessageP__stop_done__runTask(void );



static error_t UDPActiveMessageP__SplitControl__start(void );
#line 293
static inline void UDPActiveMessageP__sendDoneTimer__fired(void );





static inline error_t UDPActiveMessageP__AMSend__send(am_id_t id, am_addr_t am_addr, message_t *msg, uint8_t len);
#line 336
static inline bool UDPActiveMessageP__AMPacket__isForMe(message_t *amsg);




static inline void UDPActiveMessageP__AMPacket__setSource(message_t *amsg, am_addr_t addr);




static inline void UDPActiveMessageP__AMPacket__setType(message_t *amsg, am_id_t t);




static am_id_t UDPActiveMessageP__AMPacket__type(message_t *amsg);




static am_addr_t UDPActiveMessageP__AMPacket__destination(message_t *amsg);




static inline am_addr_t UDPActiveMessageP__AMPacket__address(void );



static inline void UDPActiveMessageP__AMPacket__setDestination(message_t *amsg, am_addr_t addr);




static am_addr_t UDPActiveMessageP__AMPacket__source(message_t *amsg);




static inline void UDPActiveMessageP__AMPacket__setGroup(message_t *amsg, am_group_t grp);
#line 393
static uint8_t UDPActiveMessageP__Packet__payloadLength(message_t *msg);




static void *UDPActiveMessageP__Packet__getPayload(message_t *msg, uint8_t len);








static inline uint8_t UDPActiveMessageP__Packet__maxPayloadLength(void );
#line 426
static bool UDPActiveMessageP__PacketAcknowledgements__wasAcked(message_t *msg);




static inline error_t UDPActiveMessageP__PacketAcknowledgements__requestAck(message_t *msg);





static inline error_t UDPActiveMessageP__PacketAcknowledgements__noAck(message_t *msg);
#line 467
static inline void UDPActiveMessageP__AMAux__setPower(message_t *p_msg, uint8_t power);
# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static void SingleTimerMilliP__TimerFrom__fired(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t SingleTimerMilliP__tarefaTimer__postTask(void );
# 18 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
enum SingleTimerMilliP____nesc_unnamed4330 {
#line 18
  SingleTimerMilliP__tarefaTimer = 11U
};
#line 18
typedef int SingleTimerMilliP____nesc_sillytask_tarefaTimer[SingleTimerMilliP__tarefaTimer];
#line 10
bool SingleTimerMilliP__isRunning;
uint32_t SingleTimerMilliP__now;
struct itimerval SingleTimerMilliP__timer;


struct timeval SingleTimerMilliP__t_initial = { 0 };
struct timeval SingleTimerMilliP__t_current = { 0 };



static inline void SingleTimerMilliP__tarefaTimer__runTask(void );



static inline void SingleTimerMilliP__sigalrm_handler(int signum);
#line 47
static inline void SingleTimerMilliP__TimerFrom__stop(void );
#line 66
static inline void SingleTimerMilliP__TimerFrom__startOneShotAt(uint32_t t0, uint32_t dt);
#line 79
static uint32_t SingleTimerMilliP__TimerFrom__getNow(void );
#line 109
static inline error_t SingleTimerMilliP__SoftwareInit__init(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__postTask(void );
# 136 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
static uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow(void );
#line 129
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__startOneShotAt(uint32_t t0, uint32_t dt);
#line 78
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__stop(void );




static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__fired(
# 48 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
uint8_t arg_0x7f7d46e78998);
#line 71
enum /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0____nesc_unnamed4331 {
#line 71
  VirtualizeTimerC__0__updateFromTimer = 12U
};
#line 71
typedef int /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0____nesc_sillytask_updateFromTimer[/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer];
#line 53
enum /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0____nesc_unnamed4332 {

  VirtualizeTimerC__0__NUM_TIMERS = 8, 
  VirtualizeTimerC__0__END_OF_LIST = 255
};








#line 59
typedef struct /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0____nesc_unnamed4333 {

  uint32_t t0;
  uint32_t dt;
  bool isoneshot : 1;
  bool isrunning : 1;
  bool _reserved : 6;
} /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer_t;

/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__NUM_TIMERS];




static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__fireTimers(uint32_t now);
#line 100
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__runTask(void );
#line 139
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__fired(void );




static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__startTimer(uint8_t num, uint32_t t0, uint32_t dt, bool isoneshot);
#line 159
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(uint8_t num, uint32_t dt);




static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(uint8_t num);




static inline bool /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(uint8_t num);
#line 189
static inline uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getNow(uint8_t num);









static inline uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getdt(uint8_t num);




static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__default__fired(uint8_t num);
# 44 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
typedef uint8_t /*BasicServicesC.Bitmap*/vmBitVectorC__0__int_type;

enum /*BasicServicesC.Bitmap*/vmBitVectorC__0____nesc_unnamed4334 {

  vmBitVectorC__0__ELEMENT_SIZE = 8 * sizeof(/*BasicServicesC.Bitmap*/vmBitVectorC__0__int_type ), 
  vmBitVectorC__0__ARRAY_SIZE = (220 + /*BasicServicesC.Bitmap*/vmBitVectorC__0__ELEMENT_SIZE - 1) / /*BasicServicesC.Bitmap*/vmBitVectorC__0__ELEMENT_SIZE
};

/*BasicServicesC.Bitmap*/vmBitVectorC__0__int_type /*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[/*BasicServicesC.Bitmap*/vmBitVectorC__0__ARRAY_SIZE];

static inline uint16_t /*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(uint16_t bitnum);




static inline uint16_t /*BasicServicesC.Bitmap*/vmBitVectorC__0__getMask(uint16_t bitnum);
#line 84
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__get(uint16_t bitnum);







static inline void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__set(uint16_t bitnum);
#line 120
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__isAllBitSet(void );







static inline void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__resetRange(uint16_t from, uint16_t to);
#line 44
typedef uint8_t /*BasicServicesC.Bitmap2*/vmBitVectorC__1__int_type;

enum /*BasicServicesC.Bitmap2*/vmBitVectorC__1____nesc_unnamed4335 {

  vmBitVectorC__1__ELEMENT_SIZE = 8 * sizeof(/*BasicServicesC.Bitmap2*/vmBitVectorC__1__int_type ), 
  vmBitVectorC__1__ARRAY_SIZE = (100 + /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ELEMENT_SIZE - 1) / /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ELEMENT_SIZE
};

/*BasicServicesC.Bitmap2*/vmBitVectorC__1__int_type /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__ARRAY_SIZE];

static inline uint16_t /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(uint16_t bitnum);




static inline uint16_t /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(uint16_t bitnum);










static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clearAll(void );
#line 84
static bool /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__get(uint16_t bitnum);







static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__set(uint16_t bitnum);




static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clear(uint16_t bitnum);
# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static void /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__dataReady(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__postTask(void );
# 14 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
enum /*BasicServicesC.inQueue.dQueue*/dataQueueP__0____nesc_unnamed4336 {
#line 14
  dataQueueP__0__dataReady = 13U
};
#line 14
typedef int /*BasicServicesC.inQueue.dQueue*/dataQueueP__0____nesc_sillytask_dataReady[/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady];
#line 7
bool /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ = TRUE;


/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qData[5];
uint8_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead = 0;
#line 11
uint8_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qTail = 0;
#line 11
uint8_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize = 0;


static inline void /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__runTask(void );




static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__put(void *Data);
#line 35
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__get(void *Data);
#line 58
static inline error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__read(void *Data);
# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
static void /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__dataReady(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__postTask(void );
# 14 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
enum /*BasicServicesC.outQueue.dQueue*/dataQueueP__1____nesc_unnamed4337 {
#line 14
  dataQueueP__1__dataReady = 14U
};
#line 14
typedef int /*BasicServicesC.outQueue.dQueue*/dataQueueP__1____nesc_sillytask_dataReady[/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady];
#line 7
bool /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ = TRUE;


/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qData[10];
uint8_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead = 0;
#line 11
uint8_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qTail = 0;
#line 11
uint8_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize = 0;


static inline void /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__runTask(void );




static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__put(void *Data);
#line 35
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__get(void *Data);
#line 58
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__read(void *Data);
# 52 "/home/mauricio/Terra/TerraVM/src/system/RandomMlcgC.nc"
uint32_t RandomMlcgC__seed;


static inline error_t RandomMlcgC__Init__init(void );
#line 69
static uint32_t RandomMlcgC__Random__rand32(void );
#line 89
static inline uint16_t RandomMlcgC__Random__rand16(void );
# 56 "/home/mauricio/Terra/TerraVM/src/interfaces/InternalFlash.nc"
static error_t ProgStorageP__InternalFlash__read(void *addr, 
#line 50
void * buf, 





uint16_t size);
#line 68
static error_t ProgStorageP__InternalFlash__write(void *addr, 
#line 63
void * buf, 




uint16_t size);
# 13 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ProgStorageP.nc"
#line 10
typedef struct ProgStorageP__progStorage {
  progEnv_t env;
  uint8_t bytecode[4096 - sizeof(progEnv_t )];
} ProgStorageP__progStorage_t;

ProgStorageP__progStorage_t ProgStorageP__data;

static inline error_t ProgStorageP__ProgStorage__save(progEnv_t *env, uint8_t *bytecode, uint16_t len);








static inline error_t ProgStorageP__ProgStorage__getEnv(progEnv_t *env);










static inline error_t ProgStorageP__ProgStorage__restore(uint8_t *bytecode, uint16_t len);
# 6 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/RPI_InternalFlashP.nc"
static inline FILE *RPI_InternalFlashP__getFD(char *mode);





static error_t RPI_InternalFlashP__IntFlash__read(void *addr, void *buf, uint16_t size);










static inline error_t RPI_InternalFlashP__IntFlash__write(void *addr, void *buf, uint16_t size);
# 24 "VMCustom.nc"
static uint32_t VMCustomP__VM__getTime(void );
#line 21
static void *VMCustomP__VM__getRealAddr(uint16_t Maddr);
#line 17
static void VMCustomP__VM__push(uint32_t val);
#line 16
static uint32_t VMCustomP__VM__pop(void );

static void VMCustomP__VM__queueEvt(uint8_t evtId, uint8_t auxId, void *data);
static int32_t VMCustomP__VM__getMVal(uint16_t Maddr, uint8_t tp);
# 9 "BSRadio.nc"
static error_t VMCustomP__BSRadio__send(uint8_t am_id, uint16_t target, void *dataMsg, uint8_t dataSize, uint8_t reqAck);
# 52 "/home/mauricio/Terra/TerraVM/src/interfaces/Random.nc"
static uint16_t VMCustomP__Random__rand16(void );
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static error_t VMCustomP__BCRadio_receive__postTask(void );
# 194 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
enum VMCustomP____nesc_unnamed4338 {
#line 194
  VMCustomP__BCRadio_receive = 15U
};
#line 194
typedef int VMCustomP____nesc_sillytask_BCRadio_receive[VMCustomP__BCRadio_receive];
#line 19
nx_uint8_t VMCustomP__ExtDataCustomA;
usrMsg_t VMCustomP__ExtDataRadioReceived;
nx_uint8_t VMCustomP__ExtDataSendDoneError;
nx_uint8_t VMCustomP__ExtDataWasAcked;






touchData_t VMCustomP__ExtDataTouch;
#line 42
static void VMCustomP__proc_send_x(uint16_t id, uint16_t addr, uint8_t ack);









static inline void VMCustomP__proc_send(uint16_t id, uint32_t addr);


static inline void VMCustomP__proc_send_ack(uint16_t id, uint32_t addr);




static inline void VMCustomP__proc_req_custom_a(uint16_t id, uint32_t value);









static inline void VMCustomP__proc_req_custom(uint16_t id, uint32_t value);






static inline void VMCustomP__proc_req_screencolor(uint16_t id, uint32_t value);






static inline void VMCustomP__func_getNodeId(uint16_t id);






static inline void VMCustomP__func_random(uint16_t id);






static inline void VMCustomP__func_getMem(uint16_t id);







static inline void VMCustomP__func_getTime(uint16_t id);
#line 155
static void VMCustomP__VM__procOutEvt(uint8_t id, uint32_t value);
#line 168
static inline void VMCustomP__VM__callFunction(uint8_t id);
#line 185
static inline void VMCustomP__VM__reset(void );








static inline void VMCustomP__BCRadio_receive__runTask(void );




static inline void VMCustomP__BSRadio__receive(uint8_t am_id, message_t *msg, void *payload, uint8_t len);









static void VMCustomP__BSRadio__sendDone(uint8_t am_id, message_t *msg, void *dataMsg, error_t error);









static void VMCustomP__BSRadio__sendDoneAck(uint8_t am_id, message_t *msg, void *dataMsg, error_t error, bool wasAcked);
#line 247
void androidTouchEvent(uint16_t posX, uint16_t posY)   ;
# 48 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
/*TerraVMAppC.evtQ*/QueueC__0__queue_t  /*TerraVMAppC.evtQ*/QueueC__0__queue[6];
uint8_t /*TerraVMAppC.evtQ*/QueueC__0__head = 0;
uint8_t /*TerraVMAppC.evtQ*/QueueC__0__tail = 0;
uint8_t /*TerraVMAppC.evtQ*/QueueC__0__size = 0;

static inline bool /*TerraVMAppC.evtQ*/QueueC__0__Queue__empty(void );



static inline uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__size(void );



static inline uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__maxSize(void );



static inline /*TerraVMAppC.evtQ*/QueueC__0__queue_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__head(void );



static inline void /*TerraVMAppC.evtQ*/QueueC__0__printQueue(void );
#line 85
static /*TerraVMAppC.evtQ*/QueueC__0__queue_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__dequeue(void );
#line 97
static error_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__enqueue(/*TerraVMAppC.evtQ*/QueueC__0__queue_t newVal);
# 10 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
__inline  __nesc_atomic_t __nesc_atomic_start(void )
#line 10
{
  return 0;
}

__inline  void __nesc_atomic_end(__nesc_atomic_t x)
#line 14
{
}

# 127 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
static inline void SchedulerBasicP__Scheduler__init(void )
{
  /* atomic removed: atomic calls only */
  {
    memset((void *)SchedulerBasicP__m_next, SchedulerBasicP__NO_TASK, sizeof SchedulerBasicP__m_next);
    SchedulerBasicP__m_head = SchedulerBasicP__NO_TASK;
    SchedulerBasicP__m_tail = SchedulerBasicP__NO_TASK;
  }
}

# 57 "/home/mauricio/Terra/TerraVM/src/interfaces/Scheduler.nc"
inline static void RealMainP__Scheduler__init(void ){
#line 57
  SchedulerBasicP__Scheduler__init();
#line 57
}
#line 57
# 8 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/PlatformP.nc"
static inline error_t PlatformP__Init__init(void )
#line 8
{
  return SUCCESS;
}

# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
inline static error_t RealMainP__PlatformInit__init(void ){
#line 62
  unsigned char __nesc_result;
#line 62

#line 62
  __nesc_result = PlatformP__Init__init();
#line 62

#line 62
  return __nesc_result;
#line 62
}
#line 62
# 65 "/home/mauricio/Terra/TerraVM/src/interfaces/Scheduler.nc"
inline static bool RealMainP__Scheduler__runNextTask(void ){
#line 65
  unsigned char __nesc_result;
#line 65

#line 65
  __nesc_result = SchedulerBasicP__Scheduler__runNextTask();
#line 65

#line 65
  return __nesc_result;
#line 65
}
#line 65
# 281 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  uint8_t __nesc_ntoh_uint8(const void * source)
#line 281
{
  const uint8_t *base = source;

#line 283
  return base[0];
}

# 18 "VMCustom.nc"
inline static void VMCustomP__VM__queueEvt(uint8_t evtId, uint8_t auxId, void *data){
#line 18
  TerraVMC__VMCustom__queueEvt(evtId, auxId, data);
#line 18
}
#line 18
# 194 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__BCRadio_receive__runTask(void )
#line 194
{
  VMCustomP__VM__queueEvt(I_RECEIVE_ID, __nesc_ntoh_uint8(VMCustomP__ExtDataRadioReceived.type.nxdata), &VMCustomP__ExtDataRadioReceived);
  VMCustomP__VM__queueEvt(I_RECEIVE, 0, &VMCustomP__ExtDataRadioReceived);
}

# 90 "/home/mauricio/Terra/TerraVM/src/interfaces/Queue.nc"
inline static error_t TerraVMC__evtQ__enqueue(TerraVMC__evtQ__t  newVal){
#line 90
  unsigned char __nesc_result;
#line 90

#line 90
  __nesc_result = /*TerraVMAppC.evtQ*/QueueC__0__Queue__enqueue(newVal);
#line 90

#line 90
  return __nesc_result;
#line 90
}
#line 90
# 61 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
static inline uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__maxSize(void )
#line 61
{
  return 6;
}





static inline void /*TerraVMAppC.evtQ*/QueueC__0__printQueue(void )
#line 69
{
}

# 100 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
static inline bool SchedulerBasicP__isWaiting(uint8_t id)
{
  return SchedulerBasicP__m_next[id] != SchedulerBasicP__NO_TASK || SchedulerBasicP__m_tail == id;
}

static inline bool SchedulerBasicP__pushTask(uint8_t id)
{
  if (!SchedulerBasicP__isWaiting(id)) 
    {
      if (SchedulerBasicP__m_head == SchedulerBasicP__NO_TASK) 
        {
          SchedulerBasicP__m_head = id;
          SchedulerBasicP__m_tail = id;
        }
      else 
        {
          SchedulerBasicP__m_next[SchedulerBasicP__m_tail] = id;
          SchedulerBasicP__m_tail = id;
        }
      return TRUE;
    }
  else 
    {
      return FALSE;
    }
}

# 136 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow(void ){
#line 136
  unsigned int __nesc_result;
#line 136

#line 136
  __nesc_result = SingleTimerMilliP__TimerFrom__getNow();
#line 136

#line 136
  return __nesc_result;
#line 136
}
#line 136
# 159 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(uint8_t num, uint32_t dt)
{
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__startTimer(num, /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow(), dt, TRUE);
}

# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void BasicServicesP__sendTimer__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(4U, dt);
#line 73
}
#line 73
# 1274 "BasicServicesP.nc"
static inline void BasicServicesP__outQ__dataReady(void )
#line 1274
{
  dbgIx("terra", "BS::outQ.dataReady().\n");
  BasicServicesP__sendCounter = 0;
  BasicServicesP__sendTimer__startOneShot(BasicServicesP__reSendDelay);
}

# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static void /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__dataReady(void ){
#line 15
  BasicServicesP__outQ__dataReady();
#line 15
}
#line 15
# 14 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static inline void /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__runTask(void )
#line 14
{
  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize > 0) {
    /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__dataReady();
    }
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
inline static error_t BasicServicesP__procInputEvent__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(BasicServicesP__procInputEvent);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 1151 "BasicServicesP.nc"
static inline void BasicServicesP__inQ__dataReady(void )
#line 1151
{
  dbgIx("terra", "BS::inQ.dataReady().\n");
  BasicServicesP__procInputEvent__postTask();
}

# 15 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static void /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__dataReady(void ){
#line 15
  BasicServicesP__inQ__dataReady();
#line 15
}
#line 15
# 14 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static inline void /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__runTask(void )
#line 14
{
  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize > 0) {
    /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__dataReady();
    }
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t SingleTimerMilliP__tarefaTimer__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(SingleTimerMilliP__tarefaTimer);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 24 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
static inline void SingleTimerMilliP__sigalrm_handler(int signum)
{





  if (SingleTimerMilliP__isRunning) {
#line 31
    SingleTimerMilliP__tarefaTimer__postTask();
    }
}

#line 66
static inline void SingleTimerMilliP__TimerFrom__startOneShotAt(uint32_t t0, uint32_t dt)
#line 66
{
  uint32_t t1;

#line 68
  SingleTimerMilliP__isRunning = TRUE;

  t1 = t0 + dt - SingleTimerMilliP__TimerFrom__getNow();

  SingleTimerMilliP__timer.it_value.tv_sec = t1 / 1000;
  SingleTimerMilliP__timer.it_value.tv_usec = t1 % 1000 * 1000;

  setSignal(14, &SingleTimerMilliP__sigalrm_handler);
  setTimer(0, &SingleTimerMilliP__timer, (void *)0);
}

# 129 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__startOneShotAt(uint32_t t0, uint32_t dt){
#line 129
  SingleTimerMilliP__TimerFrom__startOneShotAt(t0, dt);
#line 129
}
#line 129
# 47 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
static inline void SingleTimerMilliP__TimerFrom__stop(void )
#line 47
{








  SingleTimerMilliP__isRunning = FALSE;
}

# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__stop(void ){
#line 78
  SingleTimerMilliP__TimerFrom__stop();
#line 78
}
#line 78
# 100 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__runTask(void )
{




  uint32_t now = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow();
  int32_t min_remaining = (1UL << 31) - 1;
  bool min_remaining_isset = FALSE;
  uint16_t num;

  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__stop();

  for (num = 0; num < /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__NUM_TIMERS; num++) 
    {
      /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer_t *timer = &/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num];

      if (timer->isrunning) 
        {
          uint32_t elapsed = now - timer->t0;
          int32_t remaining = timer->dt - elapsed;

          if (remaining < min_remaining) 
            {
              min_remaining = remaining;
              min_remaining_isset = TRUE;
            }
        }
    }

  if (min_remaining_isset) 
    {
      if (min_remaining <= 0) {
        /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__fireTimers(now);
        }
      else {
#line 135
        /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__startOneShotAt(now, min_remaining);
        }
    }
}

# 315 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  uint16_t __nesc_hton_uint16(void * target, uint16_t value)
#line 315
{
  uint8_t *base = target;

#line 317
  base[1] = value;
  base[0] = value >> 8;
  return value;
}

# 32 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline serial_header_t * UDPActiveMessageP__getHeader(message_t * msg)
#line 32
{
  return (serial_header_t * )((uint8_t *)msg + (unsigned long )& ((message_t *)0)->data - sizeof(serial_header_t ));
}

# 1351 "BasicServicesP.nc"
static inline void BasicServicesP__RadioSender__sendDone(am_id_t id, message_t *msg, error_t error)
#line 1351
{
#line 1378
  BasicServicesP__RadioSender_sendDone(id, msg, error);
}

# 110 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
inline static void UDPActiveMessageP__AMSend__sendDone(am_id_t arg_0x7f7d46f9fc50, message_t * msg, error_t error){
#line 110
  BasicServicesP__RadioSender__sendDone(arg_0x7f7d46f9fc50, msg, error);
#line 110
}
#line 110
# 36 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline serial_metadata_t *UDPActiveMessageP__getMetadata(message_t *msg)
#line 36
{
  return (serial_metadata_t *)msg->metadata;
}

#line 293
static inline void UDPActiveMessageP__sendDoneTimer__fired(void )
#line 293
{
  __nesc_hton_uint16(UDPActiveMessageP__getMetadata(UDPActiveMessageP__lastSendMessage)->ackID.nxdata, FALSE);
  dbgIx("UDP", "UDP::AMSend - Ack time-out\n");
  UDPActiveMessageP__AMSend__sendDone(__nesc_ntoh_uint8(UDPActiveMessageP__getHeader(UDPActiveMessageP__lastSendMessage)->type.nxdata), UDPActiveMessageP__lastSendMessage, SUCCESS);
}

# 310 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  uint16_t __nesc_ntoh_uint16(const void * source)
#line 310
{
  const uint8_t *base = source;

#line 312
  return ((uint16_t )base[0] << 8) | base[1];
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t UDPActiveMessageP__receiveTask__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(UDPActiveMessageP__receiveTask);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 149 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__timerDelay__fired(void )
#line 149
{
  ackMessage_t ackMsg;

  __nesc_hton_uint16(ackMsg.ackCode.nxdata, 0xFFFE);
  __nesc_hton_uint16(ackMsg.src.nxdata, TOS_NODE_ID);
  __nesc_hton_uint16(ackMsg.dest.nxdata, __nesc_ntoh_uint16(UDPActiveMessageP__getHeader(&UDPActiveMessageP__lastReceiveMessage)->src.nxdata));
  __nesc_hton_uint16(ackMsg.ackID.nxdata, __nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(&UDPActiveMessageP__lastReceiveMessage)->ackID.nxdata));
  dbgIx("UDP", "Sendind an AckID=%d\n", __nesc_ntoh_uint16(ackMsg.ackID.nxdata));

  sendto(UDPActiveMessageP__socket_sender, &ackMsg, sizeof(message_t ), 0, (struct sockaddr *)&UDPActiveMessageP__addrSender, sizeof(struct sockaddr_in ));


  UDPActiveMessageP__receiveTask__postTask();
}

# 189 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getNow(uint8_t num)
{
  return /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow();
}

# 136 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static uint32_t BasicServicesP__TimerVM__getNow(void ){
#line 136
  unsigned int __nesc_result;
#line 136

#line 136
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getNow(2U);
#line 136

#line 136
  return __nesc_result;
#line 136
}
#line 136
# 314 "BasicServicesP.nc"
static inline uint32_t BasicServicesP__BSTimerVM__getNow(void )
#line 314
{
#line 314
  return BasicServicesP__TimerVM__getNow();
}

# 16 "BSTimer.nc"
inline static uint32_t TerraVMC__BSTimerVM__getNow(void ){
#line 16
  unsigned int __nesc_result;
#line 16

#line 16
  __nesc_result = BasicServicesP__BSTimerVM__getNow();
#line 16

#line 16
  return __nesc_result;
#line 16
}
#line 16
# 1769 "TerraVMC.nc"
static inline void TerraVMC__BSTimerVM__fired(void )
{
  u32 now = (u32 )TerraVMC__BSTimerVM__getNow();
  s32 dt = now - TerraVMC__old;

#line 1773
  TerraVMC__old = now;
  dbgIx("terra", "VM::BSTimerVM.fired(): dt=%d\n", dt);
  TerraVMC__ceu_go_wclock((void *)0, dt, (void *)0);
}

# 19 "BSTimer.nc"
inline static void BasicServicesP__BSTimerVM__fired(void ){
#line 19
  TerraVMC__BSTimerVM__fired();
#line 19
}
#line 19
# 322 "BasicServicesP.nc"
static inline void BasicServicesP__TimerVM__fired(void )
#line 322
{
  BasicServicesP__BSTimerVM__fired();
}

# 596 "TerraVMC.nc"
static inline int TerraVMC__ceu_go_async(int *ret, int *pending)
{
  int i;
#line 598
  int s = 0;
  uint16_t *ASY0 = (uint16_t *)((&TerraVMC__CEU_)->p_mem + TerraVMC__envData.async0);

#line 600
  dbgIx("terra", "CEU::ceu_go_async(): ret=%d, pending=%d, async0=%d,asyncs=%d, async_cur=%d, ASY0[0]=%d\n", 
  ret == (void *)0 ? 0 : *ret, pending == (void *)0 ? 0 : *pending, TerraVMC__envData.async0, TerraVMC__envData.asyncs, (&TerraVMC__CEU_)->async_cur, ASY0[0]);

  for (i = 0; i < TerraVMC__envData.asyncs; i++) {
      int idx = ((&TerraVMC__CEU_)->async_cur + i) % TerraVMC__envData.asyncs;

#line 605
      if (ASY0[idx] != TerraVMC__Inactive) {

          TerraVMC__ceu_track_ins(0x01, 0xFF, 0, ASY0[idx]);
          ASY0[idx] = TerraVMC__Inactive;
          (&TerraVMC__CEU_)->async_cur = (idx + 1) % TerraVMC__envData.asyncs;

          (&TerraVMC__CEU_)->wclk_late--;
          s = TerraVMC__ceu_go(ret);
          break;
        }
    }

  if (pending != (void *)0) 
    {
      *pending = 0;
      for (i = 0; i < TerraVMC__envData.asyncs; i++) {
          if (ASY0[i] != TerraVMC__Inactive) {
              *pending = 1;
              break;
            }
        }
    }

  return s;
}

# 15 "BSTimer.nc"
inline static void TerraVMC__BSTimerAsync__startOneShot(uint32_t dt){
#line 15
  BasicServicesP__BSTimerAsync__startOneShot(dt);
#line 15
}
#line 15
# 1779 "TerraVMC.nc"
static inline bool TerraVMC__hasAsync(void )
#line 1779
{
  uint8_t i;
  uint16_t *ASY0 = (uint16_t *)((&TerraVMC__CEU_)->p_mem + TerraVMC__envData.async0);

#line 1782
  for (i = 0; i < TerraVMC__envData.asyncs; i++) {
      if (ASY0[i] != TerraVMC__Inactive) {
          return TRUE;
        }
    }
  return FALSE;
}

static inline void TerraVMC__BSTimerAsync__fired(void )
{
  dbgIx("terra", "VM::BSTimerAsync.fired()\n");
  if (TerraVMC__hasAsync()) {
#line 1793
    TerraVMC__BSTimerAsync__startOneShot(2);
    }
#line 1794
  TerraVMC__ceu_go_async((void *)0, (void *)0);
}

# 19 "BSTimer.nc"
inline static void BasicServicesP__BSTimerAsync__fired(void ){
#line 19
  TerraVMC__BSTimerAsync__fired();
#line 19
}
#line 19
# 338 "BasicServicesP.nc"
static inline void BasicServicesP__TimerAsync__fired(void )
#line 338
{
#line 338
  BasicServicesP__BSTimerAsync__fired();
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t BasicServicesP__sendNextMsg__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(BasicServicesP__sendNextMsg);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 1294 "BasicServicesP.nc"
static inline void BasicServicesP__sendTimer__fired(void )
#line 1294
{
  dbgIx("terra", "BS::sendTimer.fired(): \n");
  BasicServicesP__sendNextMsg__postTask();
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t BasicServicesP__ProgReqTimerTask__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(BasicServicesP__ProgReqTimerTask);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 990 "BasicServicesP.nc"
static inline void BasicServicesP__ProgReqTimer__fired(void )
#line 990
{
  BasicServicesP__ProgReqTimerTask__postTask();
}

# 286 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  uint8_t __nesc_hton_uint8(void * target, uint8_t value)
#line 286
{
  uint8_t *base = target;

#line 288
  base[0] = value;
  return value;
}

# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void BasicServicesP__SendDataFullTimer__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(6U, dt);
#line 73
}
#line 73
# 1872 "TerraVMC.nc"
static inline uint8_t *TerraVMC__BSUpload__getSection(uint16_t Addr)
#line 1872
{
  return (uint8_t *)&TerraVMC__CEU_data[Addr];
}

# 38 "BSUpload.nc"
inline static uint8_t *BasicServicesP__BSUpload__getSection(uint16_t Addr){
#line 38
  unsigned char *__nesc_result;
#line 38

#line 38
  __nesc_result = TerraVMC__BSUpload__getSection(Addr);
#line 38

#line 38
  return __nesc_result;
#line 38
}
#line 38
# 50 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static bool BasicServicesP__BM__get(uint16_t bitnum){
#line 50
  unsigned char __nesc_result;
#line 50

#line 50
  __nesc_result = /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__get(bitnum);
#line 50

#line 50
  return __nesc_result;
#line 50
}
#line 50
# 995 "BasicServicesP.nc"
static inline void BasicServicesP__SendDataFullTimer__fired(void )
#line 995
{
  newProgBlock_t xBlock;

#line 997
  dbgIx("terra", "BS::SendDataFullTimer.fired().\n");

  if (BasicServicesP__BM__get(BasicServicesP__DsmBlockCount + __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata))) {
      uint8_t *mem;
      uint16_t i;

#line 1002
      __nesc_hton_uint8(xBlock.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
      __nesc_hton_uint16(xBlock.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
      __nesc_hton_uint16(xBlock.blockId.nxdata, (uint16_t )(BasicServicesP__DsmBlockCount + __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata)));
      mem = BasicServicesP__BSUpload__getSection((BasicServicesP__DsmBlockCount + __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata)) * BLOCK_SIZE);
      for (i = 0; i < BLOCK_SIZE; i++) __nesc_hton_uint8(xBlock.data[i].nxdata, __nesc_ntoh_uint8((* (nx_uint8_t *)(mem + i)).nxdata));
      BasicServicesP__sendNewProgBlock(&xBlock);
    }
  BasicServicesP__DsmBlockCount++;
  if (BasicServicesP__DsmBlockCount < __nesc_ntoh_uint16(BasicServicesP__ProgBlockLen.nxdata)) {

      BasicServicesP__SendDataFullTimer__startOneShot(DISSEMINATION_TIMEOUT);
    }
  else 
#line 1013
    {
      BasicServicesP__ReqState = ST_IDLE;
    }
}

# 204 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__default__fired(uint8_t num)
{
}

# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__fired(uint8_t arg_0x7f7d46e78998){
#line 83
  switch (arg_0x7f7d46e78998) {
#line 83
    case 0U:
#line 83
      UDPActiveMessageP__sendDoneTimer__fired();
#line 83
      break;
#line 83
    case 1U:
#line 83
      UDPActiveMessageP__timerDelay__fired();
#line 83
      break;
#line 83
    case 2U:
#line 83
      BasicServicesP__TimerVM__fired();
#line 83
      break;
#line 83
    case 3U:
#line 83
      BasicServicesP__TimerAsync__fired();
#line 83
      break;
#line 83
    case 4U:
#line 83
      BasicServicesP__sendTimer__fired();
#line 83
      break;
#line 83
    case 5U:
#line 83
      BasicServicesP__ProgReqTimer__fired();
#line 83
      break;
#line 83
    case 6U:
#line 83
      BasicServicesP__SendDataFullTimer__fired();
#line 83
      break;
#line 83
    default:
#line 83
      /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__default__fired(arg_0x7f7d46e78998);
#line 83
      break;
#line 83
    }
#line 83
}
#line 83
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 199 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline uint32_t /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getdt(uint8_t num)
{
  return /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num].dt;
}

# 151 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static uint32_t BasicServicesP__TimerAsync__getdt(void ){
#line 151
  unsigned int __nesc_result;
#line 151

#line 151
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getdt(3U);
#line 151

#line 151
  return __nesc_result;
#line 151
}
#line 151
# 164 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(uint8_t num)
{
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num].isrunning = FALSE;
}

# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void BasicServicesP__TimerAsync__stop(void ){
#line 78
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(3U);
#line 78
}
#line 78
#line 73
inline static void BasicServicesP__TimerAsync__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(3U, dt);
#line 73
}
#line 73
# 190 "TerraVMC.nc"
static inline uint8_t TerraVMC__getBitsPow(uint8_t data, uint8_t stBit, uint8_t endBit)
#line 190
{
#line 190
  return 1 << TerraVMC__getBits(data, stBit, endBit);
}

#line 1570
static inline void TerraVMC__f_set_c(uint8_t Modifier)
#line 1570
{
  uint8_t v1_len;
#line 1571
  uint8_t p1_1len;
#line 1571
  uint8_t p2_len;
#line 1571
  uint8_t tp1;
  uint16_t Maddr;
  uint32_t Const;

#line 1574
  tp1 = TerraVMC__getBits(Modifier, 0, 2);
  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);
  p1_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  p2_len = (uint8_t )(TerraVMC__getBits(Modifier, 4, 5) + 1);
  Maddr = TerraVMC__getPar16(p1_1len);
  Const = TerraVMC__getPar32(p2_len);
  dbgIx("terra", "VM::f_set_c(%02x): v1_len=%d, p1_1len=%d, p2_len=%d, Maddr=%d, Const=%d\n", Modifier, v1_len, p1_1len, p2_len, Maddr, Const);
  if (tp1 == F32) {
      float buffer = * (float *)&Const;

#line 1583
      TerraVMC__setMVal(* (uint32_t *)&buffer, Maddr, F32, tp1);
    }
  else 
#line 1584
    {
      TerraVMC__setMVal(Const, Maddr, S32, tp1);
    }
}

# 13 "VMCustom.nc"
inline static void TerraVMC__VMCustom__procOutEvt(uint8_t id, uint32_t value){
#line 13
  VMCustomP__VM__procOutEvt(id, value);
#line 13
}
#line 13
# 1557 "TerraVMC.nc"
static inline void TerraVMC__f_outevt_v(uint8_t Modifier)
#line 1557
{
  uint8_t p2_1len;
#line 1558
  uint8_t Cevt;

  uint16_t Maddr;

#line 1561
  p2_1len = TerraVMC__getBitsPow(Modifier, 3, 3);


  Cevt = TerraVMC__getPar8(1);
  Maddr = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_outevt_v(%02x): Cevt=%d, Maddr=%d\n", Modifier, Cevt, Maddr);
  TerraVMC__VMCustom__procOutEvt(Cevt, Maddr);
}

#line 1533
static inline void TerraVMC__f_pop(uint8_t Modifier)
#line 1533
{
  uint8_t tp1;
#line 1534
  uint8_t p1_1len;

  uint16_t Maddr;

#line 1537
  p1_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  tp1 = TerraVMC__getBits(Modifier, 0, 2);

  Maddr = TerraVMC__getPar16(p1_1len);
  if (tp1 == F32) {
      float Value = TerraVMC__popf();

#line 1543
      dbgIx("terra", "VM::f_pop(%02x): tp1=%d, Maddr=%d, value=%f, \n", Modifier, tp1, Maddr, Value);
      TerraVMC__setMVal(* (uint32_t *)&Value, Maddr, F32, tp1);
    }
  else 
#line 1545
    {
      int32_t Value = TerraVMC__pop();

#line 1547
      dbgIx("terra", "VM::f_pop(%02x): tp1=%d, Maddr=%d, value=%d, \n", Modifier, tp1, Maddr, Value);
      TerraVMC__setMVal(Value, Maddr, S32, tp1);
    }
}

# 20 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
static __inline  float __nesc_ntoh_afloat(const void * source)
#line 20
{
  float f;

#line 22
  memcpy(&f, source, sizeof(float ));
  return f;
}

# 251 "TerraVMC.nc"
static inline float TerraVMC__getMValf(uint16_t Maddr)
#line 251
{
  return (float )__nesc_ntoh_afloat((* (nx_float *)(TerraVMC__MEM + Maddr)).nxdata);
}

#line 1516
static inline void TerraVMC__f_push_v(uint8_t Modifier)
#line 1516
{
  uint8_t tp1;
#line 1517
  uint8_t p1_1len;

  uint16_t Maddr;

#line 1520
  p1_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  tp1 = TerraVMC__getBits(Modifier, 0, 2);

  Maddr = TerraVMC__getPar16(p1_1len);
  if (tp1 == F32) {
      dbgIx("terra", "VM::f_push_v(%02x): tp1=%d, Maddr=%d, value=%f, \n", Modifier, tp1, Maddr, TerraVMC__getMValf(Maddr));
      TerraVMC__pushf(TerraVMC__getMValf(Maddr));
    }
  else 
#line 1527
    {
      dbgIx("terra", "VM::f_push_v(%02x): tp1=%d, Maddr=%d, value=%d, \n", Modifier, tp1, Maddr, TerraVMC__getMVal(Maddr, tp1));
      TerraVMC__push(TerraVMC__getMVal(Maddr, tp1));
    }
}

#line 1505
static inline void TerraVMC__f_tkins_max(uint8_t Modifier)
#line 1505
{
  uint8_t stack;
#line 1506
  uint8_t p1_1len;
  uint16_t lbl;

#line 1508
  stack = (uint8_t )((&TerraVMC__CEU_)->stack + TerraVMC__getBits(Modifier, 1, 2));
  p1_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  lbl = TerraVMC__getPar16(p1_1len);
  dbgIx("terra", "VM::f_tkins_max(%02x): stack=%d, lbl=%d, \n", Modifier, stack, lbl);
  dbgIx("VMDBG", "VM:: enable track for label %d\n", lbl);
  TerraVMC__ceu_track_ins(stack, 255, 0, lbl);
}

#line 1479
static inline void TerraVMC__f_memcpy(uint8_t Modifier)
#line 1479
{
  uint8_t p1_1len;
#line 1480
  uint8_t p2_1len;
#line 1480
  uint8_t p3_1len;
  uint16_t size;
#line 1481
  uint16_t MaddrFrom;
#line 1481
  uint16_t MaddrTo;

#line 1482
  p1_1len = TerraVMC__getBitsPow(Modifier, 2, 2);
  p2_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p3_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  size = TerraVMC__getPar16(p1_1len);
  MaddrFrom = TerraVMC__getPar16(p2_1len);
  MaddrTo = TerraVMC__getPar16(p3_1len);
  dbgIx("terra", "VM::f_memcpy(%02x): size=%d, p1_1len=%d, p2_1len=%d, p3_1len=%d, AddrTo=%d, AddrFrom=%d \n", Modifier, size, p1_1len, p2_1len, p3_1len, MaddrTo, MaddrFrom);
  memcpy((void *)(TerraVMC__MEM + MaddrTo), (void *)(TerraVMC__MEM + MaddrFrom), size);
}

#line 1462
static inline void TerraVMC__f_deref(uint8_t Modifier)
#line 1462
{
  uint16_t MAddr;
  uint8_t type;

#line 1465
  type = TerraVMC__getBits(Modifier, 0, 2);
  MAddr = (uint16_t )TerraVMC__pop();
  dbgIx("terra", "VM::f_deref(%02x): type=%d, MAddr=%d, ", Modifier, type, MAddr);
  switch (type) {
      case U8: dbgIx("terra", "type= 'u8' , value=%d\n", (uint8_t )TerraVMC__getMVal(MAddr, type));
#line 1469
      TerraVMC__push((uint8_t )TerraVMC__getMVal(MAddr, type));
#line 1469
      break;
      case U16: dbgIx("terra", "type='u16' , value=%d\n", (uint16_t )TerraVMC__getMVal(MAddr, type));
#line 1470
      TerraVMC__push((uint16_t )TerraVMC__getMVal(MAddr, type));
#line 1470
      break;
      case U32: dbgIx("terra", "type='u32' , value=%d\n", (uint32_t )TerraVMC__getMVal(MAddr, type));
#line 1471
      TerraVMC__push((uint32_t )TerraVMC__getMVal(MAddr, type));
#line 1471
      break;
      case F32: dbgIx("terra", "type='f32' , value=%f\n", TerraVMC__getMValf(MAddr));
#line 1472
      TerraVMC__pushf(TerraVMC__getMValf(MAddr));
#line 1472
      break;
      case S8: dbgIx("terra", "type= 's8' , value=%d\n", (int8_t )TerraVMC__getMVal(MAddr, type));
#line 1473
      TerraVMC__push((int8_t )TerraVMC__getMVal(MAddr, type));
#line 1473
      break;
      case S16: dbgIx("terra", "type='s16' , value=%d\n", (int16_t )TerraVMC__getMVal(MAddr, type));
#line 1474
      TerraVMC__push((int16_t )TerraVMC__getMVal(MAddr, type));
#line 1474
      break;
      case S32: dbgIx("terra", "type='s32' , value=%d\n", (int32_t )TerraVMC__getMVal(MAddr, type));
#line 1475
      TerraVMC__push((int32_t )TerraVMC__getMVal(MAddr, type));
#line 1475
      break;
    }
}

#line 1445
static inline void TerraVMC__f_set_e(uint8_t Modifier)
#line 1445
{
  uint8_t v1_len;
#line 1446
  uint8_t tp1;
  uint16_t Maddr1;

#line 1448
  tp1 = TerraVMC__getBits(Modifier, 0, 2);
  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);
  Maddr1 = (uint16_t )TerraVMC__pop();
  if (tp1 == F32) {
      float Value = TerraVMC__popf();

#line 1453
      TerraVMC__setMVal(* (uint32_t *)&Value, Maddr1, F32, tp1);
      dbgIx("terra", "VM::f_set_e(%02x): v1_len=%d, Maddr1=%d, Value=%f, ValuePos=%d\n", Modifier, v1_len, Maddr1, Value, TerraVMC__getMValf(Maddr1));
    }
  else 
#line 1455
    {
      uint32_t Value = TerraVMC__pop();

#line 1457
      TerraVMC__setMVal(Value, Maddr1, S32, tp1);
      dbgIx("terra", "VM::f_set_e(%02x): v1_len=%d, Maddr1=%d, Value=%d, ValuePos=%d\n", Modifier, v1_len, Maddr1, Value, TerraVMC__getMVal(Maddr1, v1_len));
    }
}

#line 1435
static inline void TerraVMC__f_dec(uint8_t Modifier)
#line 1435
{
  uint8_t v1_len;
#line 1436
  uint8_t tp1;
  uint16_t Maddr;

#line 1438
  tp1 = TerraVMC__getBits(Modifier, 0, 1);
  v1_len = 1 << tp1;
  Maddr = (uint16_t )TerraVMC__pop();
  dbgIx("terra", "VM::f_dec(%02x): v1_len=%d, Maddr=%d, value-1=%d, \n", Modifier, v1_len, Maddr, TerraVMC__getMVal(Maddr, tp1) - 1);
  TerraVMC__setMVal(TerraVMC__getMVal(Maddr, tp1) - 1, Maddr, tp1, tp1);
}

#line 1426
static inline void TerraVMC__f_inc(uint8_t Modifier)
#line 1426
{
  uint8_t v1_len;
#line 1427
  uint8_t tp1;
  uint16_t Maddr;

#line 1429
  tp1 = TerraVMC__getBits(Modifier, 0, 1);
  v1_len = 1 << tp1;
  Maddr = (uint16_t )TerraVMC__pop();
  dbgIx("terra", "VM::f_inc(%02x): v1_len=%d, Maddr=%d, value+1=%d, \n", Modifier, v1_len, Maddr, TerraVMC__getMVal(Maddr, tp1) + 1);
  TerraVMC__setMVal(TerraVMC__getMVal(Maddr, tp1) + 1, Maddr, tp1, tp1);
}

#line 1414
static inline void TerraVMC__f_getextdt_v(uint8_t Modifier)
#line 1414
{
  uint8_t p1_1len;
#line 1415
  uint8_t p2_1len;
  uint16_t Maddr;
#line 1416
  uint16_t size;

#line 1417
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Maddr = TerraVMC__getPar16(p1_1len);
  size = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_getextdt_v(%02x): Maddr=%d, len=%d\n", Modifier, Maddr, size);
  dbgIx("VMDBG", "VM:: reading input event data.\n");
  memcpy(TerraVMC__MEM + Maddr, (&TerraVMC__CEU_)->ext_data, size);
}

#line 1403
static inline void TerraVMC__f_outevt_c(uint8_t Modifier)
#line 1403
{
  uint8_t Clen;
  uint8_t Cevt;
  uint32_t Const;

#line 1407
  Clen = (uint8_t )(TerraVMC__getBits(Modifier, 0, 1) + 1);
  Cevt = TerraVMC__getPar8(1);
  Const = TerraVMC__getPar32(Clen);
  dbgIx("terra", "VM::f_outevt_c(%02x): Cevt=%d, Clen=%d, Const=%d\n", Modifier, Cevt, Clen, Const);
  TerraVMC__VMCustom__procOutEvt(Cevt, Const);
}

#line 480
static inline void TerraVMC__ceu_track_clr(uint16_t l1, uint16_t l2)
#line 480
{
  int i;

#line 482
  for (i = 1; i <= (&TerraVMC__CEU_)->tracks_n; i++) {
      TerraVMC__tceu_trk *trk = (&TerraVMC__CEU_)->p_tracks + i;

#line 484
      if (__nesc_ntoh_uint16(trk->lbl.nxdata) >= l1 && __nesc_ntoh_uint16(trk->lbl.nxdata) <= l2) {
          TerraVMC__ceu_track_rem((void *)0, i);
          i--;
        }
    }
}

#line 1391
static inline void TerraVMC__f_tkclr(uint8_t Modifier)
#line 1391
{
  uint8_t p1_1len;
#line 1392
  uint8_t p2_1len;
  uint16_t lbl1;
#line 1393
  uint16_t lbl2;

#line 1394
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  lbl1 = TerraVMC__getPar16(p1_1len);
  lbl2 = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_tkclr(%02x): lbl1=%d, lbl2=%d\n", Modifier, lbl1, lbl2);
  dbgIx("VMDBG", "VM:: clear tracks for label %d to label %d\n", lbl1, lbl2);
  TerraVMC__ceu_track_clr(lbl1, lbl2);
}

# 169 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline bool /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(uint8_t num)
{
  return /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num].isrunning;
}

# 92 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static bool BasicServicesP__TimerAsync__isRunning(void ){
#line 92
  unsigned char __nesc_result;
#line 92

#line 92
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(3U);
#line 92

#line 92
  return __nesc_result;
#line 92
}
#line 92
# 336 "BasicServicesP.nc"
static inline bool BasicServicesP__BSTimerAsync__isRunning(void )
#line 336
{
#line 336
  return BasicServicesP__TimerAsync__isRunning();
}

# 17 "BSTimer.nc"
inline static bool TerraVMC__BSTimerAsync__isRunning(void ){
#line 17
  unsigned char __nesc_result;
#line 17

#line 17
  __nesc_result = BasicServicesP__BSTimerAsync__isRunning();
#line 17

#line 17
  return __nesc_result;
#line 17
}
#line 17
# 558 "TerraVMC.nc"
static inline void TerraVMC__ceu_async_enable(int gte, uint16_t lbl)
#line 558
{
  ((uint16_t *)((&TerraVMC__CEU_)->p_mem + TerraVMC__envData.async0))[gte] = lbl;
  if (!TerraVMC__BSTimerAsync__isRunning()) {
    TerraVMC__BSTimerAsync__startOneShot(2);
    }
}

#line 1379
static inline void TerraVMC__f_asen(uint8_t Modifier)
#line 1379
{
  uint8_t p1_1len;
#line 1380
  uint8_t p2_1len;
  uint16_t gate;
#line 1381
  uint16_t lbl;

#line 1382
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  gate = TerraVMC__getPar16(p1_1len);
  lbl = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_asen(%02x): gate=%d, lbl=%d\n", Modifier, gate, lbl);
  dbgIx("VMDBG", "VM:: async enable: gate=%d; label=%d.\n", gate, lbl);
  TerraVMC__ceu_async_enable(gate, lbl);
}

#line 113
static inline uint16_t TerraVMC__getLblAddr(uint16_t lbl)
#line 113
{
  dbgIx("terra", "VM::getLblAddr(%d):\n", lbl);
  return lbl;
}

#line 1367
static inline void TerraVMC__f_ifelse(uint8_t Modifier)
#line 1367
{
  uint8_t p1_1len;
#line 1368
  uint8_t p2_1len;
  uint16_t lbl1;
#line 1369
  uint16_t lbl2;

#line 1370
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  lbl1 = TerraVMC__getPar16(p1_1len);
  lbl2 = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_ifelse(%02x): lbl1=%d, lbl2=%d\n", Modifier, lbl1, lbl2);
  dbgIx("VMDBG", "VM:: if/else: TRUE label=%d; FALSE label=%d.\n", lbl1, lbl2);
  if (TerraVMC__pop()) {
#line 1376
    TerraVMC__PC = TerraVMC__getLblAddr(lbl1);
    }
  else {
#line 1376
    TerraVMC__PC = TerraVMC__getLblAddr(lbl2);
    }
}

#line 1354
static inline void TerraVMC__f_memclr(uint8_t Modifier)
#line 1354
{
  uint8_t p1_1len;
#line 1355
  uint8_t p2_1len;
  uint16_t Maddr;
#line 1356
  uint16_t size;

#line 1357
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Maddr = TerraVMC__getPar16(p1_1len);
  size = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_memclr(%02x): Maddr=%d, size=%d\n", Modifier, Maddr, size);
  dbgIx("VMDBG", "VM:: clear clock/gate entry.\n");

  {
#line 1364
    int x;

#line 1364
    for (x = 0; x < size; x++) * (uint8_t *)(TerraVMC__MEM + Maddr + x) = 0;
  }
}

#line 1340
static inline void TerraVMC__f_cast(uint8_t Modifier)
#line 1340
{
  uint32_t stacki;
  float stackf;
  uint8_t mode;

#line 1344
  mode = TerraVMC__getBits(Modifier, 0, 1);
  dbgIx("terra", "VM::f_cast(%02x): mode=%d, ", Modifier, mode);
  switch (mode) {
      case U32_F: stacki = TerraVMC__pop();
#line 1347
      dbgIx("terra", "mode='U32_F', stack=%d, cast=%f\n", stacki, (f32 )* (u32 *)&stacki);
#line 1347
      TerraVMC__pushf((f32 )* (u32 *)&stacki);
#line 1347
      break;
      case S32_F: stacki = TerraVMC__pop();
#line 1348
      dbgIx("terra", "mode='S32_F', stack=%d, cast=%f\n", stacki, (f32 )* (s32 *)&stacki);
#line 1348
      TerraVMC__pushf((f32 )* (s32 *)&stacki);
#line 1348
      break;
      case F_U32: stackf = TerraVMC__popf();
#line 1349
      dbgIx("terra", "mode='F_U32', stack=%f, cast=%d\n", stackf, (u32 )* (f32 *)&stackf);
#line 1349
      TerraVMC__push((u32 )* (f32 *)&stackf);
#line 1349
      break;
      case F_S32: stackf = TerraVMC__popf();
#line 1350
      dbgIx("terra", "mode='F_S32', stack=%f, cast=%d\n", stackf, (s32 )* (f32 *)&stackf);
#line 1350
      TerraVMC__push((u32 )* (f32 *)&stackf);
#line 1350
      break;
    }
}

#line 1331
static inline void TerraVMC__f_push_c(uint8_t Modifier)
#line 1331
{
  uint8_t p1_len;
  uint32_t Const;

#line 1334
  p1_len = (uint8_t )(TerraVMC__getBits(Modifier, 0, 1) + 1);
  Const = TerraVMC__getPar32(p1_len);
  dbgIx("terra", "VM::f_push_c(%02x): p1_len=%d, Const=%d, \n", Modifier, p1_len, Const);
  TerraVMC__push(Const);
}

#line 1492
static inline void TerraVMC__f_tkins_z(uint8_t Modifier)
#line 1492
{
  uint8_t tree;
#line 1493
  uint8_t chk;
#line 1493
  uint8_t p2_1len;
#line 1493
  uint8_t par1;
  uint16_t lbl;

#line 1495
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  par1 = TerraVMC__getPar8(1);
  chk = TerraVMC__getBits(par1, 7, 7);
  tree = TerraVMC__getBits(par1, 0, 6);
  lbl = TerraVMC__getPar16(p2_1len);
  dbgIx("terra", "VM::f_tkins_z(%02x): tree=%d, chk=%d, p2_1len=%d, lbl=%d, \n", Modifier, tree, chk, p2_1len, lbl);
  dbgIx("VMDBG", "VM:: enable track for label %d\n", lbl);
  TerraVMC__ceu_track_ins(0, tree, chk, lbl);
}

#line 1321
static inline void TerraVMC__f_chkret(uint8_t Modifier)
#line 1321
{
  uint8_t p1_1len;
  uint16_t Maddr;

#line 1324
  p1_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Maddr = TerraVMC__getPar16(p1_1len);
  dbgIx("terra", "VM::f_chkret(%02x): p1_1len=%d, MAddr=%d value=%d, \n", Modifier, p1_1len, Maddr, * (uint8_t *)(TerraVMC__MEM + Maddr));
  dbgIx("VMDBG", "VM:: test end of PAR.\n");
  if (* (uint8_t *)(TerraVMC__MEM + Maddr) > 0) {
#line 1328
    TerraVMC__PC = TerraVMC__PC + 1;
    }
}

#line 1311
static inline void TerraVMC__f_exec(uint8_t Modifier)
#line 1311
{
  uint8_t p1_1len;
  uint16_t Const;

#line 1314
  p1_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Const = TerraVMC__getPar16(p1_1len);
  dbgIx("terra", "VM::f_exec(%02x): p1_1len=%d, Const=%d\n", Modifier, p1_1len, Const);
  dbgIx("VMDBG", "VM:: executing trail: label=%d.\n", Const);
  TerraVMC__PC = TerraVMC__getLblAddr(Const);
}

#line 1301
static inline void TerraVMC__f_trg(uint8_t Modifier)
#line 1301
{
  uint8_t p1_1len;
  uint16_t gtAddr;

#line 1304
  p1_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  gtAddr = TerraVMC__getPar16(p1_1len);
  dbgIx("terra", "VM::f_trg(%02x): p1_1len=%d, gtAddr=%d, \n", Modifier, p1_1len, gtAddr);
  dbgIx("VMDBG", "VM:: trigger event gate=%d, auxId=0\n", gtAddr);
  TerraVMC__ceu_trigger(gtAddr, 0);
}

#line 1290
static inline void TerraVMC__f_getextdt_e(uint8_t Modifier)
#line 1290
{
  uint8_t p1_1len;
  uint16_t Maddr;
#line 1292
  uint16_t len;

#line 1293
  p1_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Maddr = (uint16_t )TerraVMC__pop();
  len = TerraVMC__getPar16(p1_1len);
  dbgIx("terra", "VM::f_getextdt_e(%02x): Maddr=%d, len=%d\n", Modifier, Maddr, len);
  dbgIx("VMDBG", "VM:: reading input event data.\n");
  memcpy(TerraVMC__MEM + Maddr, (&TerraVMC__CEU_)->ext_data, len);
}

#line 1262
static inline void TerraVMC__f_pusharr_v(uint8_t Modifier)
#line 1262
{
  uint8_t v1_len;
#line 1263
  uint8_t p1_1len;
#line 1263
  uint8_t v2_len;
#line 1263
  uint8_t p2_1len;
#line 1263
  uint8_t p3_1len;
#line 1263
  uint8_t Aux;
#line 1263
  uint8_t tp1;
#line 1263
  uint8_t tp2;
  uint16_t Maddr;
#line 1264
  uint16_t Vidx;
#line 1264
  uint16_t Max;

  p3_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Aux = TerraVMC__getPar8(1);
  p1_1len = TerraVMC__getBitsPow(Aux, 7, 7);
  tp1 = TerraVMC__getBits(Aux, 4, 6);
  p2_1len = TerraVMC__getBitsPow(Aux, 3, 3);
  tp2 = TerraVMC__getBits(Aux, 0, 2);

  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);
  v2_len = tp2 == F32 ? 4 : 1 << (tp2 & 0x3);

  Maddr = TerraVMC__getPar16(p1_1len);
  Vidx = TerraVMC__getPar16(p2_1len);
  Max = TerraVMC__getPar16(p3_1len);

  if (TerraVMC__getMVal(Vidx, tp2) >= Max) {
    TerraVMC__evtError(E_IDXOVF);
    }
  else 
#line 1282
    {
      dbgIx("terra", "VM::f_pusharr_v(%02x):Maddr=%d, Vidx=%d, Max=%d, IDX OVERFLOW=%s idx=%d, v1_len=%d\n", Modifier, Maddr, Vidx, Max, 
      TerraVMC__getMVal(Vidx, tp2) > Max ? "TRUE" : "FALSE", TerraVMC__getMVal(Vidx, v2_len), v1_len);
      TerraVMC__push(Maddr + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len);
    }
}

#line 1227
static inline void TerraVMC__f_poparr_v(uint8_t Modifier)
#line 1227
{
  uint8_t v1_len;
#line 1228
  uint8_t p1_1len;
#line 1228
  uint8_t p2_1len;
#line 1228
  uint8_t p3_1len;
#line 1228
  uint8_t Aux;
#line 1228
  uint8_t tp1;
#line 1228
  uint8_t tp2;

  uint16_t Maddr;
#line 1230
  uint16_t Vidx;
#line 1230
  uint16_t Max;

  p3_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  Aux = TerraVMC__getPar8(1);
  p1_1len = TerraVMC__getBitsPow(Aux, 7, 7);
  tp1 = TerraVMC__getBits(Aux, 4, 6);
  p2_1len = TerraVMC__getBitsPow(Aux, 3, 3);
  tp2 = TerraVMC__getBits(Aux, 0, 2);

  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);


  Maddr = TerraVMC__getPar16(p1_1len);
  Vidx = TerraVMC__getPar16(p2_1len);
  Max = TerraVMC__getPar16(p3_1len);
  if (TerraVMC__getMVal(Vidx, tp2) >= Max) {
    TerraVMC__evtError(E_IDXOVF);
    }
  else 
#line 1247
    {
      if (tp1 == F32) {
          float v2 = TerraVMC__popf();

#line 1250
          dbgIx("terra", "VM::f_poparr_v(%02x):Maddr=%d, Vidx=%d, Max=%d, Value=%f, IDX OVERFLOW=%s idx=%d\n", 
          Modifier, Maddr, Vidx, Max, v2, TerraVMC__getMVal(Vidx, tp2) > Max ? "TRUE" : "FALSE", TerraVMC__getMVal(Vidx, tp2));
          TerraVMC__setMVal(* (uint32_t *)&v2, Maddr + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, F32, tp1);
        }
      else 
#line 1253
        {
          int32_t v2 = TerraVMC__pop();

#line 1255
          dbgIx("terra", "VM::f_poparr_v(%02x):Maddr=%d, Vidx=%d, Max=%d, Value=%d, IDX OVERFLOW=%s idx=%d\n", 
          Modifier, Maddr, Vidx, Max, v2, TerraVMC__getMVal(Vidx, tp2) > Max ? "TRUE" : "FALSE", TerraVMC__getMVal(Vidx, tp2));
          TerraVMC__setMVal(v2, Maddr + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, S32, tp1);
        }
    }
}

#line 1185
static inline void TerraVMC__f_setarr_vv(uint8_t Modifier)
#line 1185
{
  uint8_t v1_len;
#line 1186
  uint8_t p1_1len;
#line 1186
  uint8_t p2_1len;
#line 1186
  uint8_t p3_1len;
#line 1186
  uint8_t p4_1len;
#line 1186
  uint8_t Aux;
#line 1186
  uint8_t tp1;
#line 1186
  uint8_t tp2;
#line 1186
  uint8_t tp4;

  uint16_t Maddr1;
#line 1188
  uint16_t Vidx;
#line 1188
  uint16_t Max;
#line 1188
  uint16_t Maddr2;

#line 1189
  Modifier = TerraVMC__getPar8(1);
  Aux = TerraVMC__getPar8(1);

  p1_1len = TerraVMC__getBitsPow(Modifier, 7, 7);
  tp1 = TerraVMC__getBits(Modifier, 4, 6);
  p2_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  tp2 = TerraVMC__getBits(Modifier, 0, 2);

  p3_1len = TerraVMC__getBitsPow(Aux, 4, 4);
  p4_1len = TerraVMC__getBitsPow(Aux, 3, 3);
  tp4 = TerraVMC__getBits(Aux, 0, 2);

  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);



  Maddr1 = TerraVMC__getPar16(p1_1len);
  Vidx = TerraVMC__getPar16(p2_1len);
  Max = TerraVMC__getPar16(p3_1len);
  Maddr2 = TerraVMC__getPar16(p4_1len);

  dbgIx("terra", "VM::f_setarr_vv(%02x):Maddr1=%d, Vidx=%d, Max=%d, Madr2=%d, IDX OVERFLOW=%s idx=%d\n", 
  Modifier, Maddr1, Vidx, Max, Maddr2, TerraVMC__getMVal(Vidx, tp2) > Max ? "TRUE" : "FALSE", TerraVMC__getMVal(Vidx, tp2));
  if (TerraVMC__getMVal(Vidx, tp2) >= Max) {
    TerraVMC__evtError(E_IDXOVF);
    }
  else 
#line 1214
    {
      if (tp4 == F32) {
          float buffer = TerraVMC__getMValf(Maddr2);

#line 1217
          TerraVMC__setMVal(* (uint32_t *)&buffer, Maddr1 + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, tp4, tp1);
        }
      else 
#line 1218
        {
          uint32_t buffer = TerraVMC__getMVal(Maddr2, tp4);

#line 1220
          TerraVMC__setMVal(buffer, Maddr1 + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, tp4, tp1);
        }
    }
}

#line 1150
static inline void TerraVMC__f_setarr_vc(uint8_t Modifier)
#line 1150
{
  uint8_t v1_len;
#line 1151
  uint8_t p1_1len;
#line 1151
  uint8_t p2_1len;
#line 1151
  uint8_t p3_1len;
#line 1151
  uint8_t p4_len;
#line 1151
  uint8_t Aux;
#line 1151
  uint8_t tp1;
#line 1151
  uint8_t tp2;

  uint16_t Maddr;
#line 1153
  uint16_t Vidx;
#line 1153
  uint16_t Max;
  uint32_t Const;

#line 1155
  Modifier = TerraVMC__getPar8(1);
  Aux = TerraVMC__getPar8(1);

  p1_1len = TerraVMC__getBitsPow(Modifier, 7, 7);
  tp1 = TerraVMC__getBits(Modifier, 4, 6);
  p2_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  tp2 = TerraVMC__getBits(Modifier, 0, 2);
  p3_1len = TerraVMC__getBitsPow(Aux, 2, 2);
  p4_len = (uint8_t )(TerraVMC__getBits(Aux, 0, 1) + 1);
  v1_len = tp1 == F32 ? 4 : 1 << (tp1 & 0x3);


  Maddr = TerraVMC__getPar16(p1_1len);
  Vidx = TerraVMC__getPar16(p2_1len);
  Max = TerraVMC__getPar16(p3_1len);
  Const = TerraVMC__getPar32(p4_len);
  dbgIx("terra", "VM::f_setarr_vc(%02x):Maddr=%d, Vidx=%d, Max=%d, Const=%d, IDX OVERFLOW=%s idx=%d\n", 
  Modifier, Maddr, Vidx, Max, Const, TerraVMC__getMVal(Vidx, tp2) > Max ? "TRUE" : "FALSE", TerraVMC__getMVal(Vidx, tp2));
  if (TerraVMC__getMVal(Vidx, tp2) >= Max) {
    TerraVMC__evtError(E_IDXOVF);
    }
  else 
#line 1175
    {
      if (tp1 == F32) {
          float buffer = (float )Const;

#line 1178
          TerraVMC__setMVal(* (uint32_t *)&buffer, Maddr + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, tp2, tp1);
        }
      else 
#line 1179
        {
          TerraVMC__setMVal(Const, Maddr + TerraVMC__getMVal(Vidx, tp2) % Max * v1_len, tp2, tp1);
        }
    }
}

#line 1127
static inline void TerraVMC__f_set_v(uint8_t Modifier)
#line 1127
{
  uint8_t p1_1len;
#line 1128
  uint8_t p2_1len;
  uint8_t tp1;
#line 1129
  uint8_t tp2;
  uint16_t Maddr1;
#line 1130
  uint16_t Maddr2;

#line 1131
  Modifier = TerraVMC__getPar8(1);
  p1_1len = TerraVMC__getBitsPow(Modifier, 7, 7);
  tp1 = TerraVMC__getBits(Modifier, 4, 6);
  p2_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  tp2 = TerraVMC__getBits(Modifier, 0, 2);
  Maddr1 = TerraVMC__getPar16(p1_1len);
  Maddr2 = TerraVMC__getPar16(p2_1len);


  if (tp2 == F32) {
      float buffer = TerraVMC__getMValf(Maddr2);

#line 1142
      TerraVMC__setMVal(* (uint32_t *)&buffer, Maddr1, tp2, tp1);
      dbgIx("terra", "VM::f_set_v(%02x): tp1=%d, tp2=%d, p1_1len=%d, p2_1len=%d, Maddr1=%d, Maddr2=%d, value=%f\n", Modifier, tp1, tp2, p1_1len, p2_1len, Maddr1, Maddr2, buffer);
    }
  else 
#line 1144
    {
      uint32_t buffer = TerraVMC__getMVal(Maddr2, tp2);

#line 1146
      TerraVMC__setMVal(buffer, Maddr1, tp2, tp1);
      dbgIx("terra", "VM::f_set_v(%02x): tp1=%d, tp2=%d, p1_1len=%d, p2_1len=%d, Maddr1=%d, Maddr2=%d, value=%d\n", Modifier, tp1, tp2, p1_1len, p2_1len, Maddr1, Maddr2, buffer);
    }
}

#line 1109
static inline void TerraVMC__f_clken_c(uint8_t Modifier)
#line 1109
{
  uint8_t p1_1len;
#line 1110
  uint8_t p2_len;
#line 1110
  uint8_t p3_1len;
  uint16_t gate;
#line 1111
  uint16_t lbl;
  uint32_t Ctime;

#line 1113
  Modifier = TerraVMC__getPar8(1);
  p1_1len = TerraVMC__getBitsPow(Modifier, 3, 3);
  p2_len = (uint8_t )(TerraVMC__getBits(Modifier, 1, 2) + 1);
  p3_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  gate = TerraVMC__getPar16(p1_1len);
  Ctime = TerraVMC__getPar32(p2_len);
  lbl = TerraVMC__getPar16(p3_1len);
  dbgIx("terra", "VM::f_clken_c(%02x): p1_1len=%d, p2_len=%d, p3_1len=%d, gate=%d, Ctime=%d, lbl=%d\n", Modifier, p1_1len, p2_len, p3_1len, gate, Ctime, lbl);
  dbgIx("VMDBG", "VM:: await timer %ld for label %d\n", (s32 )Ctime, lbl);
  TerraVMC__ceu_wclock_enable(gate, (s32 )Ctime, lbl);
}

#line 1089
static inline void TerraVMC__f_clken_v(uint8_t Modifier)
#line 1089
{
  uint8_t p1_1len;
#line 1090
  uint8_t p2_1len;
#line 1090
  uint8_t p3_1len;
#line 1090
  uint8_t unit;
#line 1090
  uint8_t timeTp;
  uint16_t gate;
#line 1091
  uint16_t lbl;
#line 1091
  uint16_t VtimeAddr;
  uint32_t Time = 0;

#line 1093
  Modifier = TerraVMC__getPar8(1);
  unit = TerraVMC__getBits(Modifier, 5, 7);
  timeTp = TerraVMC__getBits(Modifier, 3, 4);
  p1_1len = TerraVMC__getBitsPow(Modifier, 2, 2);
  p2_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p3_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  gate = TerraVMC__getPar16(p1_1len);
  VtimeAddr = TerraVMC__getPar16(p2_1len);
  lbl = TerraVMC__getPar16(p3_1len);
  Time = TerraVMC__getMVal(VtimeAddr, timeTp);
  dbgIx("terra", "VM::f_clken_v(%02x): p1_1len=%d, type=%d, gate=%d, unit=%d, VtimeAddr=%d, Time=%d, lbl=%d, Time(ms)=%d\n", 
  Modifier, p1_1len, timeTp, gate, unit, VtimeAddr, Time, lbl, (s32 )TerraVMC__unit2val(Time, unit));
  dbgIx("VMDBG", "VM:: await timer %ld for label %d\n", (s32 )TerraVMC__unit2val(Time, unit), lbl);
  TerraVMC__ceu_wclock_enable(gate, (s32 )TerraVMC__unit2val(Time, unit), lbl);
}

#line 1073
static inline void TerraVMC__f_clken_e(uint8_t Modifier)
#line 1073
{
  uint8_t p1_1len;
#line 1074
  uint8_t p2_1len;
#line 1074
  uint8_t unit;
  uint16_t gate;
#line 1075
  uint16_t lbl;
  uint32_t Time = 0;

#line 1077
  Modifier = TerraVMC__getPar8(1);
  p1_1len = TerraVMC__getBitsPow(Modifier, 1, 1);
  p2_1len = TerraVMC__getBitsPow(Modifier, 0, 0);
  unit = TerraVMC__getBits(Modifier, 4, 6);
  gate = TerraVMC__getPar16(p1_1len);
  lbl = TerraVMC__getPar16(p2_1len);
  Time = TerraVMC__pop();
  dbgIx("terra", "VM::f_clken_e(%02x): p1_1len=%d, p2_1len=%d, gate=%d, unit=%d, Time=%d, lbl=%d\n", 
  Modifier, p1_1len, p2_1len, gate, unit, Time, lbl);
  dbgIx("VMDBG", "VM:: await timer %ld for label %d\n", (s32 )TerraVMC__unit2val(Time, unit), lbl);
  TerraVMC__ceu_wclock_enable(gate, (s32 )TerraVMC__unit2val(Time, unit), lbl);
}

#line 1066
static inline void TerraVMC__f_outevt_z(uint8_t Modifier)
#line 1066
{
  uint8_t Cevt;

#line 1068
  Cevt = TerraVMC__getPar8(1);
  dbgIx("terra", "VM::f_outevt_z(%02x): Evt=%d, \n", Modifier, Cevt);
  TerraVMC__VMCustom__procOutEvt(Cevt, 0);
}

#line 1056
static inline void TerraVMC__f_outevt_e(uint8_t Modifier)
#line 1056
{
  uint8_t Cevt;
  uint32_t value;

#line 1059
  value = TerraVMC__pop();
  Cevt = TerraVMC__getPar8(1);
  dbgIx("terra", "VM::f_outevt_e(%02x): Cevt=%d\n", Modifier, Cevt);
  dbgIx("VMDBG", "VM:: emitting output event %d\n", Cevt);
  TerraVMC__VMCustom__procOutEvt(Cevt, value);
}

#line 1756
static inline void TerraVMC__VMCustom__push(uint32_t value)
#line 1756
{
  TerraVMC__push(value);
}

# 17 "VMCustom.nc"
inline static void VMCustomP__VM__push(uint32_t val){
#line 17
  TerraVMC__VMCustom__push(val);
#line 17
}
#line 17
# 1764 "TerraVMC.nc"
static inline uint32_t TerraVMC__VMCustom__getTime(void )
#line 1764
{
  return TerraVMC__BSTimerVM__getNow();
}

# 24 "VMCustom.nc"
inline static uint32_t VMCustomP__VM__getTime(void ){
#line 24
  unsigned int __nesc_result;
#line 24

#line 24
  __nesc_result = TerraVMC__VMCustom__getTime();
#line 24

#line 24
  return __nesc_result;
#line 24
}
#line 24
# 106 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__func_getTime(uint16_t id)
#line 106
{
  uint32_t val;

#line 108
  val = VMCustomP__VM__getTime();
  dbgIx("terra", "Custom::func_getTime(): func id=%d, val=%d(%0x)\n", id, val, val);
  VMCustomP__VM__push(val);
}

# 1740 "TerraVMC.nc"
static inline int32_t TerraVMC__VMCustom__getMVal(uint16_t Maddr, uint8_t tp)
#line 1740
{
  return TerraVMC__getMVal(Maddr, tp);
}

# 19 "VMCustom.nc"
inline static int32_t VMCustomP__VM__getMVal(uint16_t Maddr, uint8_t tp){
#line 19
  int __nesc_result;
#line 19

#line 19
  __nesc_result = TerraVMC__VMCustom__getMVal(Maddr, tp);
#line 19

#line 19
  return __nesc_result;
#line 19
}
#line 19
# 1753 "TerraVMC.nc"
static inline uint32_t TerraVMC__VMCustom__pop(void )
#line 1753
{
  return TerraVMC__pop();
}

# 16 "VMCustom.nc"
inline static uint32_t VMCustomP__VM__pop(void ){
#line 16
  unsigned int __nesc_result;
#line 16

#line 16
  __nesc_result = TerraVMC__VMCustom__pop();
#line 16

#line 16
  return __nesc_result;
#line 16
}
#line 16
# 98 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__func_getMem(uint16_t id)
#line 98
{
  uint8_t val;
  uint16_t Maddr;

#line 101
  Maddr = (uint16_t )VMCustomP__VM__pop();
  val = (uint8_t )VMCustomP__VM__getMVal(Maddr, 0);
  dbgIx("terra", "Custom::func_getMem(): func id=%d, addr=%d, val=%d(%0x)\n", id, Maddr, val, val);
  VMCustomP__VM__push(val);
}

# 89 "/home/mauricio/Terra/TerraVM/src/system/RandomMlcgC.nc"
static inline uint16_t RandomMlcgC__Random__rand16(void )
#line 89
{
  return (uint16_t )RandomMlcgC__Random__rand32();
}

# 52 "/home/mauricio/Terra/TerraVM/src/interfaces/Random.nc"
inline static uint16_t VMCustomP__Random__rand16(void ){
#line 52
  unsigned short __nesc_result;
#line 52

#line 52
  __nesc_result = RandomMlcgC__Random__rand16();
#line 52

#line 52
  return __nesc_result;
#line 52
}
#line 52
# 91 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__func_random(uint16_t id)
#line 91
{
  uint16_t stat;

  stat = VMCustomP__Random__rand16();
  dbgIx("terra", "Custom::func_random(): func id=%d, Random=%d\n", id, stat);
  VMCustomP__VM__push(stat);
}

#line 84
static inline void VMCustomP__func_getNodeId(uint16_t id)
#line 84
{
  uint16_t stat;

  stat = TOS_NODE_ID;
  dbgIx("terra", "Custom::func_getNodeId(): func id=%d, NodeId=%d\n", id, stat);
  VMCustomP__VM__push(stat);
}

#line 168
static inline void VMCustomP__VM__callFunction(uint8_t id)
#line 168
{
  dbgIx("terra", "Custom::VM.callFunction(%d)\n", id);
  switch (id) {
      case F_GETNODEID: VMCustomP__func_getNodeId(id);
#line 171
      break;
      case F_RANDOM: VMCustomP__func_random(id);
#line 172
      break;
      case F_GETMEM: VMCustomP__func_getMem(id);
#line 173
      break;
      case F_GETTIME: VMCustomP__func_getTime(id);
#line 174
      break;
    }
}

# 14 "VMCustom.nc"
inline static void TerraVMC__VMCustom__callFunction(uint8_t id){
#line 14
  VMCustomP__VM__callFunction(id);
#line 14
}
#line 14
# 1048 "TerraVMC.nc"
static inline void TerraVMC__f_func(uint8_t Modifier)
#line 1048
{
  uint8_t fID;

#line 1050
  fID = TerraVMC__getPar8(1);
  dbgIx("terra", "VM::f_func(%02x): fID=%d\n", Modifier, fID);
  dbgIx("VMDBG", "VM:: call function %d\n", fID);
  TerraVMC__VMCustom__callFunction(fID);
}

#line 1039
static inline void TerraVMC__f_lt_f(uint8_t Modifier)
#line 1039
{
  float v1;
#line 1040
  float v2;

#line 1041
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_lt_f(%02x): (v1=%f < v2=%f) = %s\n", Modifier, v1, v2, v1 < v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM:: less-than test: (%f < %f) = %s \n", v1, v2, v1 < v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 < v2);
}

#line 1031
static inline void TerraVMC__f_gt_f(uint8_t Modifier)
#line 1031
{
  float v1;
#line 1032
  float v2;

#line 1033
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_gt_f(%02x): (v1=%f > v2=%f) = %s\n", Modifier, v1, v2, v1 > v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM::  greater-than test: (%f > %f) = %s \n", v1, v2, v1 > v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 > v2);
}

#line 1023
static inline void TerraVMC__f_lte_f(uint8_t Modifier)
#line 1023
{
  float v1;
#line 1024
  float v2;

#line 1025
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_lte_f(%02x): (v1=%f <= v2=%f) = %s\n", Modifier, v1, v2, v1 <= v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM:: less-than-equal test: (%f <= %f) = %s \n", v1, v2, v1 <= v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 <= v2);
}

#line 1015
static inline void TerraVMC__f_gte_f(uint8_t Modifier)
#line 1015
{
  float v1;
#line 1016
  float v2;

#line 1017
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_gte_f(%02x): (v1=%f >= v2=%f) = %s\n", Modifier, v1, v2, v1 >= v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM::  greater-than-equal test: (%f >= %f) = %s \n", v1, v2, v1 >= v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 >= v2);
}

#line 1007
static inline void TerraVMC__f_neq_f(uint8_t Modifier)
#line 1007
{
  float v1;
#line 1008
  float v2;

#line 1009
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_neq_f(%02x): (v1=%f != v2=%f) = %s\n", Modifier, v1, v2, v1 != v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM:: inequality test: (%f != %f) = %s \n", v1, v2, v1 != v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 != v2);
}

#line 998
static inline void TerraVMC__f_eq_f(uint8_t Modifier)
#line 998
{
  float v1;
#line 999
  float v2;

#line 1000
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_eq_f(%02x): (v1=%f == v2=%f) = %s\n", Modifier, v1, v2, v1 == v2 ? "TRUE" : "FALSE");
  dbgIx("VMDBG", "VM:: equality test: (%f == %f) = %s \n", v1, v2, v1 == v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 == v2);
}

#line 989
static inline void TerraVMC__f_div_f(uint8_t Modifier)
#line 989
{
  float v1;
#line 990
  float v2;

#line 991
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_div_f(%02x): v1=%f, v2=%f, div=%f\n", Modifier, v1, v2, v1 / v2);
  dbgIx("VMDBG", "VM:: div operation: (%f / %f) = %f \n", v1, v2, v1 / v2);
  TerraVMC__pushf(v1 / v2);
}

#line 981
static inline void TerraVMC__f_mult_f(uint8_t Modifier)
#line 981
{
  float v1;
#line 982
  float v2;

#line 983
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_mult_f(%02x): v1=%f, v2=%f, mult=%f\n", Modifier, v1, v2, v1 * v2);
  dbgIx("VMDBG", "VM:: mult operation: (%f * %f) = %f \n", v1, v2, v1 * v2);
  TerraVMC__pushf(v1 * v2);
}

#line 973
static inline void TerraVMC__f_add_f(uint8_t Modifier)
#line 973
{
  float v1;
#line 974
  float v2;

#line 975
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_add(%02x): v1=%f, v2=%f, add=%f\n", Modifier, v1, v2, v1 + v2);
  dbgIx("VMDBG", "VM:: add operation: (%f + %f) = %f \n", v1, v2, v1 + v2);
  TerraVMC__pushf(v1 + v2);
}

#line 965
static inline void TerraVMC__f_sub_f(uint8_t Modifier)
#line 965
{
  float v1;
#line 966
  float v2;

#line 967
  v1 = TerraVMC__popf();
  v2 = TerraVMC__popf();
  dbgIx("terra", "VM::f_sub(%02x): v1=%f, v2=%f, sub=%f\n", Modifier, v1, v2, v1 - v2);
  dbgIx("VMDBG", "VM:: sub operation: (%f - %f) = %f \n", v1, v2, v1 - v2);
  TerraVMC__pushf(v1 - v2);
}

#line 957
static inline void TerraVMC__f_neg_f(uint8_t Modifier)
#line 957
{
  float v1;

#line 959
  v1 = TerraVMC__popf();
  dbgIx("terra", "VM::f_neg_f(%02x): -(v1=%f) =%f\n", Modifier, v1, -1 * v1);
  dbgIx("VMDBG", "VM:: negative float operation: (-%f) = %f \n", v1, -1 * v1);
  v1 = -1 * v1;
  TerraVMC__pushf(v1);
}

#line 1552
static inline void TerraVMC__f_popx(uint8_t Modifier)
#line 1552
{
  TerraVMC__pop();
  dbgIx("terra", "VM::f_popx(%02x):\n", Modifier);
}

#line 948
static inline void TerraVMC__f_land(uint8_t Modifier)
#line 948
{
  int32_t v1;
#line 949
  int32_t v2;

#line 950
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_land(%02x): (v1=%d && v2=%d) = %d\n", Modifier, v1, v2, v1 && v2);
  dbgIx("VMDBG", "VM:: logical AND operation: (%d && %d) = %s \n", v1, v2, v1 && v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 && v2);
}

#line 940
static inline void TerraVMC__f_lor(uint8_t Modifier)
#line 940
{
  int32_t v1;
#line 941
  int32_t v2;

#line 942
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_lor(%02x): (v1=%d || v2=%d) = %d\n", Modifier, v1, v2, v1 || v2);
  dbgIx("VMDBG", "VM:: logical OR operation: (%d || %d) = %s \n", v1, v2, v1 || v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 || v2);
}

#line 932
static inline void TerraVMC__f_lt(uint8_t Modifier)
#line 932
{
  int32_t v1;
#line 933
  int32_t v2;

#line 934
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_lt(%02x): (v1=%d < v2=%d) = %d\n", Modifier, v1, v2, v1 < v2);
  dbgIx("VMDBG", "VM:: less-than test: (%d < %d) = %s \n", v1, v2, v1 < v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 < v2);
}

#line 924
static inline void TerraVMC__f_gt(uint8_t Modifier)
#line 924
{
  int32_t v1;
#line 925
  int32_t v2;

#line 926
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_gt(%02x): (v1=%d > v2=%d) = %d\n", Modifier, v1, v2, v1 > v2);
  dbgIx("VMDBG", "VM::  greater-than test: (%d > %d) = %s \n", v1, v2, v1 > v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 > v2);
}

#line 916
static inline void TerraVMC__f_lte(uint8_t Modifier)
#line 916
{
  int32_t v1;
#line 917
  int32_t v2;

#line 918
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_lte(%02x): (v1=%d <= v2=%d) = %d\n", Modifier, v1, v2, v1 <= v2);
  dbgIx("VMDBG", "VM:: less-than-equal test: (%d <= %d) = %s \n", v1, v2, v1 <= v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 <= v2);
}

#line 908
static inline void TerraVMC__f_gte(uint8_t Modifier)
#line 908
{
  int32_t v1;
#line 909
  int32_t v2;

#line 910
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_gte(%02x): (v1=%d >= v2=%d) = %d\n", Modifier, v1, v2, v1 >= v2);
  dbgIx("VMDBG", "VM::  greater-than-equal test: (%d >= %d) = %s \n", v1, v2, v1 >= v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 >= v2);
}

#line 900
static inline void TerraVMC__f_neq(uint8_t Modifier)
#line 900
{
  int32_t v1;
#line 901
  int32_t v2;

#line 902
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_neq(%02x): (v1=%d != v2=%d) = %d\n", Modifier, v1, v2, v1 != v2);
  dbgIx("VMDBG", "VM:: inequality test: (%d != %d) = %s \n", v1, v2, v1 != v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 != v2);
}

#line 891
static inline void TerraVMC__f_eq(uint8_t Modifier)
#line 891
{
  int32_t v1;
#line 892
  int32_t v2;

#line 893
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_eq(%02x): (v1=%d == v2=%d) = %d\n", Modifier, v1, v2, v1 == v2);
  dbgIx("VMDBG", "VM:: equality test: (%d == %d) = %s \n", v1, v2, v1 == v2 ? "TRUE" : "FALSE");
  TerraVMC__push(v1 == v2);
}

#line 883
static inline void TerraVMC__f_bxor(uint8_t Modifier)
#line 883
{
  int32_t v1;
#line 884
  int32_t v2;

#line 885
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_bxor(%02x): (v1=%d ^ v2=%d) = %d)\n", Modifier, v1, v2, v1 ^ v2);
  dbgIx("VMDBG", "VM:: binary XOR operation: (0x%x ^ 0x%x) = 0x%x \n", v1, v2, v1 ^ v2);
  TerraVMC__push(v1 ^ v2);
}

#line 875
static inline void TerraVMC__f_rshft(uint8_t Modifier)
#line 875
{
  int32_t v1;
#line 876
  int32_t v2;

#line 877
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_rshft(%02x): (v1=%d >> v2=%d) = %d\n", Modifier, v1, v2, v1 >> v2);
  dbgIx("VMDBG", "VM:: right shift operation: (0x%x >> %d) = 0x%x \n", v1, v2, v1 >> v2);
  TerraVMC__push(v1 >> v2);
}

#line 867
static inline void TerraVMC__f_lshft(uint8_t Modifier)
#line 867
{
  int32_t v1;
#line 868
  int32_t v2;

#line 869
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_lshft(%02x): (v1=%d << v2=%d) = %d\n", Modifier, v1, v2, v1 << v2);
  dbgIx("VMDBG", "VM:: left shift operation: (0x%x << %d) = 0x%x \n", v1, v2, v1 << v2);
  TerraVMC__push(v1 << v2);
}

#line 859
static inline void TerraVMC__f_band(uint8_t Modifier)
#line 859
{
  int32_t v1;
#line 860
  int32_t v2;

#line 861
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_band(%02x): (v1=%d & v2=%d) = %d\n", Modifier, v1, v2, v1 & v2);
  dbgIx("VMDBG", "VM:: binary AND operation: (0x%x & 0x%x) = 0x%x \n", v1, v2, v1 & v2);
  TerraVMC__push(v1 & v2);
}

#line 851
static inline void TerraVMC__f_bor(uint8_t Modifier)
#line 851
{
  int32_t v1;
#line 852
  int32_t v2;

#line 853
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_bor(%02x): (v1=%d | v2=%d) = %d\n", Modifier, v1, v2, v1 | v2);
  dbgIx("VMDBG", "VM:: binary OR operation: (0x%x | 0x%x) = 0x%x \n", v1, v2, v1 | v2);
  TerraVMC__push(v1 | v2);
}

#line 841
static inline void TerraVMC__f_div(uint8_t Modifier)
#line 841
{
  int32_t v1;
#line 842
  int32_t v2;

#line 843
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_div(%02x): v1=%d, v2=%d, div=%d\n", Modifier, v1, v2, v2 == 0 ? 0 : v1 / v2);
  dbgIx("VMDBG", "VM:: div operation: (%d / %d) = %d \n", v1, v2, v2 == 0 ? 0 : v1 / v2);
  TerraVMC__push(v2 == 0 ? 0 : v1 / v2);
  if (v2 == 0) {
#line 848
    TerraVMC__evtError(E_DIVZERO);
    }
}

#line 832
static inline void TerraVMC__f_mult(uint8_t Modifier)
#line 832
{
  int32_t v1;
#line 833
  int32_t v2;

#line 834
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_mult(%02x): v1=%d, v2=%d, mult=%d\n", Modifier, v1, v2, v1 * v2);
  dbgIx("VMDBG", "VM:: mult operation: (%d * %d) = %d \n", v1, v2, v1 * v2);
  TerraVMC__push(v1 * v2);
}

#line 822
static inline void TerraVMC__f_mod(uint8_t Modifier)
#line 822
{
  int32_t v1;
#line 823
  int32_t v2;

#line 824
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_mod(%02x): v1=%d, v2=%d, mod=%d\n", Modifier, v1, v2, v1 % v2);
  dbgIx("VMDBG", "VM:: mod operation: (%d %% %d) = %d \n", v1, v2, v1 % v2);
  TerraVMC__push(v2 == 0 ? 0 : v1 % v2);
  if (v2 == 0) {
#line 829
    TerraVMC__evtError(E_DIVZERO);
    }
}

#line 813
static inline void TerraVMC__f_add(uint8_t Modifier)
#line 813
{
  int32_t v1;
#line 814
  int32_t v2;

#line 815
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_add(%02x): v1=%d, v2=%d, add=%d\n", Modifier, v1, v2, v1 + v2);
  dbgIx("VMDBG", "VM:: add operation: (%d + %d) = %d \n", v1, v2, v1 + v2);
  TerraVMC__push(v1 + v2);
}

#line 804
static inline void TerraVMC__f_sub(uint8_t Modifier)
#line 804
{
  int32_t v1;
#line 805
  int32_t v2;

#line 806
  v1 = TerraVMC__pop();
  v2 = TerraVMC__pop();
  dbgIx("terra", "VM::f_sub(%02x): v1=%d, v2=%d, sub=%d\n", Modifier, v1, v2, v1 - v2);
  dbgIx("VMDBG", "VM:: sub operation: (%d - %d) = %d \n", v1, v2, v1 - v2);
  TerraVMC__push(v1 - v2);
}

#line 797
static inline void TerraVMC__f_neg(uint8_t Modifier)
#line 797
{
  int32_t v1;

#line 799
  v1 = TerraVMC__pop();
  dbgIx("terra", "VM::f_neg(%02x): -(v1=%d) =%d\n", Modifier, v1, -1 * v1);
  dbgIx("VMDBG", "VM:: negative operation: (-%d) = %d \n", v1, -1 * v1);
  TerraVMC__push(-1 * v1);
}

#line 790
static inline void TerraVMC__f_lnot(uint8_t Modifier)
#line 790
{
  int32_t v1;

#line 792
  v1 = TerraVMC__pop();
  dbgIx("terra", "VM::f_lnot(%02x): !(v1=%d) =%d\n", Modifier, v1, !v1);
  dbgIx("VMDBG", "VM:: logical NOT operation: (! %d) = %s \n", v1, !v1 ? "TRUE" : "FALSE");
  TerraVMC__push(!v1);
}

#line 783
static inline void TerraVMC__f_bnot(uint8_t Modifier)
#line 783
{
  int32_t v1;

#line 785
  v1 = TerraVMC__pop();
  dbgIx("terra", "VM::f_bnot(%02x): ~(v1=%d) =%d\n", Modifier, v1, ~v1);
  dbgIx("VMDBG", "VM:: binary NOT operation: (~ 0x%x) = 0x%x \n", v1, ~v1);
  TerraVMC__push(~v1);
}

#line 778
static inline void TerraVMC__f_end(uint8_t Modifier)
#line 778
{
  dbgIx("terra", "VM::f_end(%02x)\n", Modifier);
  dbgIx("VMDBG", "VM:: End of Trail\n");
}

#line 776
static inline void TerraVMC__f_nop(uint8_t Modifier)
#line 776
{
#line 776
  dbgIx("terra", "VM::f_nop(%02x)\n", Modifier);
}

#line 1591
static inline void TerraVMC__Decoder(uint8_t Opcode, uint8_t Modifier)
#line 1591
{


  dbgIx("terra", "VM::Decoder(): PC= %d opcode= %hhu modifier=%d Maddr[290]=%d\n", TerraVMC__PC - 1, Opcode, Modifier, TerraVMC__getMVal(290, U8));
  switch (Opcode) {
      case op_nop: TerraVMC__f_nop(Modifier);
#line 1596
      break;
      case op_end: TerraVMC__f_end(Modifier);
#line 1597
      break;
      case op_bnot: TerraVMC__f_bnot(Modifier);
#line 1598
      break;
      case op_lnot: TerraVMC__f_lnot(Modifier);
#line 1599
      break;
      case op_neg: TerraVMC__f_neg(Modifier);
#line 1600
      break;
      case op_sub: TerraVMC__f_sub(Modifier);
#line 1601
      break;
      case op_add: TerraVMC__f_add(Modifier);
#line 1602
      break;
      case op_mod: TerraVMC__f_mod(Modifier);
#line 1603
      break;
      case op_mult: TerraVMC__f_mult(Modifier);
#line 1604
      break;
      case op_div: TerraVMC__f_div(Modifier);
#line 1605
      break;
      case op_bor: TerraVMC__f_bor(Modifier);
#line 1606
      break;
      case op_band: TerraVMC__f_band(Modifier);
#line 1607
      break;
      case op_lshft: TerraVMC__f_lshft(Modifier);
#line 1608
      break;
      case op_rshft: TerraVMC__f_rshft(Modifier);
#line 1609
      break;
      case op_bxor: TerraVMC__f_bxor(Modifier);
#line 1610
      break;
      case op_eq: TerraVMC__f_eq(Modifier);
#line 1611
      break;
      case op_neq: TerraVMC__f_neq(Modifier);
#line 1612
      break;
      case op_gte: TerraVMC__f_gte(Modifier);
#line 1613
      break;
      case op_lte: TerraVMC__f_lte(Modifier);
#line 1614
      break;
      case op_gt: TerraVMC__f_gt(Modifier);
#line 1615
      break;
      case op_lt: TerraVMC__f_lt(Modifier);
#line 1616
      break;
      case op_lor: TerraVMC__f_lor(Modifier);
#line 1617
      break;
      case op_land: TerraVMC__f_land(Modifier);
#line 1618
      break;
      case op_popx: TerraVMC__f_popx(Modifier);
#line 1619
      break;


      case op_neg_f: TerraVMC__f_neg_f(Modifier);
#line 1622
      break;
      case op_sub_f: TerraVMC__f_sub_f(Modifier);
#line 1623
      break;
      case op_add_f: TerraVMC__f_add_f(Modifier);
#line 1624
      break;
      case op_mult_f: TerraVMC__f_mult_f(Modifier);
#line 1625
      break;
      case op_div_f: TerraVMC__f_div_f(Modifier);
#line 1626
      break;
      case op_eq_f: TerraVMC__f_eq_f(Modifier);
#line 1627
      break;
      case op_neq_f: TerraVMC__f_neq_f(Modifier);
#line 1628
      break;
      case op_gte_f: TerraVMC__f_gte_f(Modifier);
#line 1629
      break;
      case op_lte_f: TerraVMC__f_lte_f(Modifier);
#line 1630
      break;
      case op_gt_f: TerraVMC__f_gt_f(Modifier);
#line 1631
      break;
      case op_lt_f: TerraVMC__f_lt_f(Modifier);
#line 1632
      break;
      case op_func: TerraVMC__f_func(Modifier);
#line 1633
      break;
      case op_outEvt_e: TerraVMC__f_outevt_e(Modifier);
#line 1634
      break;
      case op_outevt_z: TerraVMC__f_outevt_z(Modifier);
#line 1635
      break;
      case op_clken_e: TerraVMC__f_clken_e(Modifier);
#line 1636
      break;
      case op_clken_v: TerraVMC__f_clken_v(Modifier);
#line 1637
      break;
      case op_clken_c: TerraVMC__f_clken_c(Modifier);
#line 1638
      break;
      case op_set_v: TerraVMC__f_set_v(Modifier);
#line 1639
      break;
      case op_setarr_vc: TerraVMC__f_setarr_vc(Modifier);
#line 1640
      break;
      case op_setarr_vv: TerraVMC__f_setarr_vv(Modifier);
#line 1641
      break;



      case op_poparr_v: TerraVMC__f_poparr_v(Modifier);
#line 1645
      break;
      case op_pusharr_v: TerraVMC__f_pusharr_v(Modifier);
#line 1646
      break;
      case op_getextdt_e: TerraVMC__f_getextdt_e(Modifier);
#line 1647
      break;
      case op_trg: TerraVMC__f_trg(Modifier);
#line 1648
      break;
      case op_exec: TerraVMC__f_exec(Modifier);
#line 1649
      break;
      case op_chkret: TerraVMC__f_chkret(Modifier);
#line 1650
      break;
      case op_tkins_z: TerraVMC__f_tkins_z(Modifier);
#line 1651
      break;


      case op_push_c: TerraVMC__f_push_c(Modifier);
#line 1654
      break;
      case op_cast: TerraVMC__f_cast(Modifier);
#line 1655
      break;
      case op_memclr: TerraVMC__f_memclr(Modifier);
#line 1656
      break;
      case op_ifelse: TerraVMC__f_ifelse(Modifier);
#line 1657
      break;
      case op_asen: TerraVMC__f_asen(Modifier);
#line 1658
      break;
      case op_tkclr: TerraVMC__f_tkclr(Modifier);
#line 1659
      break;
      case op_outEvt_c: TerraVMC__f_outevt_c(Modifier);
#line 1660
      break;
      case op_getextdt_v: TerraVMC__f_getextdt_v(Modifier);
#line 1661
      break;
      case op_inc: TerraVMC__f_inc(Modifier);
#line 1662
      break;
      case op_dec: TerraVMC__f_dec(Modifier);
#line 1663
      break;
      case op_set_e: TerraVMC__f_set_e(Modifier);
#line 1664
      break;
      case op_deref: TerraVMC__f_deref(Modifier);
#line 1665
      break;
      case op_memcpy: TerraVMC__f_memcpy(Modifier);
#line 1666
      break;

      case op_tkins_max: TerraVMC__f_tkins_max(Modifier);
#line 1668
      break;
      case op_push_v: TerraVMC__f_push_v(Modifier);
#line 1669
      break;
      case op_pop: TerraVMC__f_pop(Modifier);
#line 1670
      break;
      case op_outEvt_v: TerraVMC__f_outevt_v(Modifier);
#line 1671
      break;
      case op_set_c: TerraVMC__f_set_c(Modifier);
#line 1672
      break;
    }
}

#line 689
static inline void TerraVMC__execTrail(uint16_t lbl)
#line 689
{
  uint8_t Opcode;
#line 690
  uint8_t Param1;

  dbgIx("terra", "CEU::execTrail(%d), haltedFlag=%s\n", lbl, TerraVMC__haltedFlag ? "TRUE" : "FALSE");
  if (TerraVMC__haltedFlag) {
#line 693
    return;
    }
  TerraVMC__PC = TerraVMC__getLblAddr(lbl);
  if (TerraVMC__PC == 0) {
      dbgIx("terra", "ERROR CEU::execTrail():Label %d not found!\n", lbl);
      return;
    }
  TerraVMC__getOpCode(&Opcode, &Param1);

  while (Opcode != op_end) {
      if (TerraVMC__haltedFlag) {
#line 703
        return;
        }
      TerraVMC__Decoder(Opcode, Param1);
      TerraVMC__getOpCode(&Opcode, &Param1);
    }
  dbgIx("terra", "CEU::execTrail(%d):: found an 'end' opcode\n", lbl);
}

# 303 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  int8_t __nesc_ntoh_int8(const void * source)
#line 303
{
#line 303
  return __nesc_ntoh_uint8(source);
}

#line 334
static __inline  int16_t __nesc_ntoh_int16(const void * source)
#line 334
{
#line 334
  return __nesc_ntoh_uint16(source);
}




static __inline  uint32_t __nesc_ntoh_uint32(const void * source)
#line 340
{
  const uint8_t *base = source;

#line 342
  return ((((uint32_t )base[0] << 24) | (
  (uint32_t )base[1] << 16)) | (
  (uint32_t )base[2] << 8)) | base[3];
}

#line 372
static __inline  int32_t __nesc_ntoh_int32(const void * source)
#line 372
{
#line 372
  return __nesc_ntoh_uint32(source);
}

# 123 "TerraVMC.nc"
static inline void TerraVMC__TViewer(char *cmd, uint16_t p1, uint16_t p2)
#line 123
{
  dbgIx("TVIEW", "<<: %s %d %d %d :>>\n", cmd, TOS_NODE_ID, p1, p2);
}

# 185 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__VM__reset(void )
#line 185
{
}

# 15 "VMCustom.nc"
inline static void TerraVMC__VMCustom__reset(void ){
#line 15
  VMCustomP__VM__reset();
#line 15
}
#line 15
# 26 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
static __inline  float __nesc_hton_afloat(void * target, float value)
#line 26
{
  memcpy(target, &value, sizeof(float ));
  return value;
}

# 52 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__proc_send(uint16_t id, uint32_t addr)
#line 52
{
  VMCustomP__proc_send_x(id, (uint16_t )addr, FALSE);
}

# 21 "VMCustom.nc"
inline static void *VMCustomP__VM__getRealAddr(uint16_t Maddr){
#line 21
  void *__nesc_result;
#line 21

#line 21
  __nesc_result = TerraVMC__VMCustom__getRealAddr(Maddr);
#line 21

#line 21
  return __nesc_result;
#line 21
}
#line 21
# 8 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__outQ__put(void *Data){
#line 8
  unsigned char __nesc_result;
#line 8

#line 8
  __nesc_result = /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__put(Data);
#line 8

#line 8
  return __nesc_result;
#line 8
}
#line 8
# 1487 "BasicServicesP.nc"
static inline error_t BasicServicesP__BSRadio__send(uint8_t am_id, uint16_t target, void *dataMsg, uint8_t dataSize, uint8_t reqAck)
#line 1487
{
  dbgIx("terra", "BS::BSRadio.send(): insert in outQueue. AM_ID=%d, Target=%u, dataSize=%d, reqAck=%d\n", am_id, target, dataSize, reqAck);
  memcpy(& BasicServicesP__tempInputOutQ.Data, dataMsg, dataSize);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.AM_ID.nxdata, am_id);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.DataSize.nxdata, dataSize);
  __nesc_hton_uint16(BasicServicesP__tempInputOutQ.sendToMote.nxdata, target);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.reqAck.nxdata, reqAck);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.RFPower.nxdata, BasicServicesP__userRFPowerIdx);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.fromSerial.nxdata, FALSE);
  dbgIx("VMDBG", "Radio: Sending user msg AM_ID=%d to node %u\n", am_id, target);
  if (BasicServicesP__outQ__put(&BasicServicesP__tempInputOutQ) != SUCCESS) {
      dbgIx("terra", "BS::BSRadio.send(): outQueue is full! Losting a message.\n");
      return EBUSY;
    }
  return SUCCESS;
}

# 9 "BSRadio.nc"
inline static error_t VMCustomP__BSRadio__send(uint8_t am_id, uint16_t target, void *dataMsg, uint8_t dataSize, uint8_t reqAck){
#line 9
  unsigned char __nesc_result;
#line 9

#line 9
  __nesc_result = BasicServicesP__BSRadio__send(am_id, target, dataMsg, dataSize, reqAck);
#line 9

#line 9
  return __nesc_result;
#line 9
}
#line 9
# 55 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__proc_send_ack(uint16_t id, uint32_t addr)
#line 55
{
  VMCustomP__proc_send_x(id, (uint16_t )addr, TRUE);
}


static inline void VMCustomP__proc_req_custom_a(uint16_t id, uint32_t value)
#line 60
{
  uint8_t auxId;

#line 62
  __nesc_hton_uint8(VMCustomP__ExtDataCustomA.nxdata, (uint8_t )value);
  dbgIx("terra", "Custom::proc_req_custom_a(): id=%d, ExtDataCustomA=%d\n", id, __nesc_ntoh_uint8(VMCustomP__ExtDataCustomA.nxdata));
  auxId = (uint8_t )value;

  VMCustomP__VM__queueEvt(I_CUSTOM_A_ID, auxId, &VMCustomP__ExtDataCustomA);
  VMCustomP__VM__queueEvt(I_CUSTOM_A, 0, &VMCustomP__ExtDataCustomA);
}

static inline void VMCustomP__proc_req_custom(uint16_t id, uint32_t value)
#line 70
{
  dbgIx("terra", "Custom::proc_req_custom(): id=%d\n", id);

  __nesc_hton_uint8(VMCustomP__ExtDataCustomA.nxdata, 0);
  VMCustomP__VM__queueEvt(I_CUSTOM, 0, &VMCustomP__ExtDataCustomA);
}

static inline void VMCustomP__proc_req_screencolor(uint16_t id, uint32_t value)
#line 77
{
  dbgIx("terra", "SCREEN COLOR EVENT EXECUTED");
}

# 15 "BSTimer.nc"
inline static void TerraVMC__BSTimerVM__startOneShot(uint32_t dt){
#line 15
  BasicServicesP__BSTimerVM__startOneShot(dt);
#line 15
}
#line 15
# 80 "TerraVMC.nc"
static inline void TerraVMC__ceu_out_wclock(uint32_t ms)
#line 80
{
#line 80
  if (ms != 0x7FFFFFFF) {
#line 80
      TerraVMC__BSTimerVM__startOneShot(ms);
    }
}

# 151 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static uint32_t BasicServicesP__TimerVM__getdt(void ){
#line 151
  unsigned int __nesc_result;
#line 151

#line 151
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__getdt(2U);
#line 151

#line 151
  return __nesc_result;
#line 151
}
#line 151
#line 92
inline static bool BasicServicesP__TimerVM__isRunning(void ){
#line 92
  unsigned char __nesc_result;
#line 92

#line 92
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(2U);
#line 92

#line 92
  return __nesc_result;
#line 92
}
#line 92
#line 78
inline static void BasicServicesP__TimerVM__stop(void ){
#line 78
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(2U);
#line 78
}
#line 78
#line 73
inline static void BasicServicesP__TimerVM__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(2U, dt);
#line 73
}
#line 73
# 347 "/usr/lib/x86_64-linux-gnu/ncc/nesc_nx.h"
static __inline  uint32_t __nesc_hton_uint32(void * target, uint32_t value)
#line 347
{
  uint8_t *base = target;

#line 349
  base[3] = value;
  base[2] = value >> 8;
  base[1] = value >> 16;
  base[0] = value >> 24;
  return value;
}

#line 372
static __inline  int32_t __nesc_hton_int32(void * target, int32_t value)
#line 372
{
#line 372
  __nesc_hton_uint32(target, value);
#line 372
  return value;
}

#line 303
static __inline  int8_t __nesc_hton_int8(void * target, int8_t value)
#line 303
{
#line 303
  __nesc_hton_uint8(target, value);
#line 303
  return value;
}

#line 334
static __inline  int16_t __nesc_hton_int16(void * target, int16_t value)
#line 334
{
#line 334
  __nesc_hton_uint16(target, value);
#line 334
  return value;
}

# 85 "/home/mauricio/Terra/TerraVM/src/interfaces/PacketAcknowledgements.nc"
inline static bool BasicServicesP__RadioAck__wasAcked(message_t * msg){
#line 85
  unsigned char __nesc_result;
#line 85

#line 85
  __nesc_result = UDPActiveMessageP__PacketAcknowledgements__wasAcked(msg);
#line 85

#line 85
  return __nesc_result;
#line 85
}
#line 85
# 11 "BSRadio.nc"
inline static void BasicServicesP__BSRadio__sendDoneAck(uint8_t am_id, message_t *msg, void *dataMsg, error_t error, bool wasAcked){
#line 11
  VMCustomP__BSRadio__sendDoneAck(am_id, msg, dataMsg, error, wasAcked);
#line 11
}
#line 11
#line 10
inline static void BasicServicesP__BSRadio__sendDone(uint8_t am_id, message_t *msg, void *dataMsg, error_t error){
#line 10
  VMCustomP__BSRadio__sendDone(am_id, msg, dataMsg, error);
#line 10
}
#line 10
# 139 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static inline void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__fired(void )
{
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__fireTimers(/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__getNow());
}

# 83 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void SingleTimerMilliP__TimerFrom__fired(void ){
#line 83
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__TimerFrom__fired();
#line 83
}
#line 83
# 20 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
static inline void SingleTimerMilliP__tarefaTimer__runTask(void )
#line 20
{
  SingleTimerMilliP__TimerFrom__fired();
}

# 299 "BasicServicesP.nc"
static inline void BasicServicesP__RadioControl__stopDone(error_t error)
#line 299
{
  dbgIx("terra", "BS::RadioControl.stopDone().\n");
}

# 138 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
inline static void UDPActiveMessageP__SplitControl__stopDone(error_t error){
#line 138
  BasicServicesP__RadioControl__stopDone(error);
#line 138
}
#line 138
# 169 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__stop_done__runTask(void )
#line 169
{
  UDPActiveMessageP__SplitControl__stopDone(SUCCESS);
}

# 29 "BSUpload.nc"
inline static void BasicServicesP__BSUpload__start(bool resetFlag){
#line 29
  TerraVMC__BSUpload__start(resetFlag);
#line 29
}
#line 29
# 56 "/home/mauricio/Terra/TerraVM/src/interfaces/InternalFlash.nc"
inline static error_t ProgStorageP__InternalFlash__read(void *addr, void * buf, uint16_t size){
#line 56
  unsigned char __nesc_result;
#line 56

#line 56
  __nesc_result = RPI_InternalFlashP__IntFlash__read(addr, buf, size);
#line 56

#line 56
  return __nesc_result;
#line 56
}
#line 56
# 37 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ProgStorageP.nc"
static inline error_t ProgStorageP__ProgStorage__restore(uint8_t *bytecode, uint16_t len)
#line 37
{
  error_t status;

#line 39
  status = ProgStorageP__InternalFlash__read((void *)0, &ProgStorageP__data, 4096);
  memcpy(bytecode, & ProgStorageP__data.bytecode, len);
  return status;
}

# 27 "ProgStorage.nc"
inline static error_t TerraVMC__ProgStorage__restore(uint8_t *bytecode, uint16_t len){
#line 27
  unsigned char __nesc_result;
#line 27

#line 27
  __nesc_result = ProgStorageP__ProgStorage__restore(bytecode, len);
#line 27

#line 27
  return __nesc_result;
#line 27
}
#line 27
# 26 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ProgStorageP.nc"
static inline error_t ProgStorageP__ProgStorage__getEnv(progEnv_t *env)
#line 26
{
  error_t status;

#line 28
  status = ProgStorageP__InternalFlash__read((void *)0, &ProgStorageP__data, 4096);
  if (status == SUCCESS && ProgStorageP__data.env.persistFlag == TRUE && ProgStorageP__data.env.Version > 0 && ProgStorageP__data.env.ProgEnd > ProgStorageP__data.env.ProgStart) {
      memcpy(env, & ProgStorageP__data.env, sizeof(progEnv_t ));
      return SUCCESS;
    }
  else 
#line 32
    {
      return FAIL;
    }
}

# 19 "ProgStorage.nc"
inline static error_t TerraVMC__ProgStorage__getEnv(progEnv_t *env){
#line 19
  unsigned char __nesc_result;
#line 19

#line 19
  __nesc_result = ProgStorageP__ProgStorage__getEnv(env);
#line 19

#line 19
  return __nesc_result;
#line 19
}
#line 19
# 1895 "TerraVMC.nc"
static inline uint16_t TerraVMC__BSUpload__progRestore(void )
#line 1895
{

  error_t status = FAIL;

#line 1898
  TerraVMC__BSUpload__resetMemory();
  status = TerraVMC__ProgStorage__getEnv(&TerraVMC__envData);
  if (status == SUCCESS) {
      status = TerraVMC__ProgStorage__restore((uint8_t *)&TerraVMC__CEU_data[TerraVMC__envData.ProgStart], TerraVMC__envData.ProgEnd - TerraVMC__envData.ProgStart + 1);
      if (status == SUCCESS) {
          TerraVMC__progRestored = TRUE;
          TerraVMC__haltedFlag = FALSE;
          return TerraVMC__envData.Version;
        }
    }
  TerraVMC__progRestored = FALSE;

  return 0;
}

# 42 "BSUpload.nc"
inline static uint16_t BasicServicesP__BSUpload__progRestore(void ){
#line 42
  unsigned short __nesc_result;
#line 42

#line 42
  __nesc_result = TerraVMC__BSUpload__progRestore();
#line 42

#line 42
  return __nesc_result;
#line 42
}
#line 42
# 86 "TerraVMC.nc"
static inline void TerraVMC__BSBoot__booted(void )
#line 86
{

  __nesc_hton_uint16(TerraVMC__MoteID.nxdata, TOS_NODE_ID);
}

# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
inline static void BasicServicesP__BSBoot__booted(void ){
#line 60
  TerraVMC__BSBoot__booted();
#line 60
}
#line 60
# 244 "BasicServicesP.nc"
static inline uint32_t BasicServicesP__getRequestTimeout(void )
#line 244
{
#line 244
  return REQUEST_TIMEOUT;
}

# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void BasicServicesP__ProgReqTimer__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(5U, dt);
#line 73
}
#line 73
# 104 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
inline static error_t BasicServicesP__RadioControl__start(void ){
#line 104
  unsigned char __nesc_result;
#line 104

#line 104
  __nesc_result = UDPActiveMessageP__SplitControl__start();
#line 104

#line 104
  return __nesc_result;
#line 104
}
#line 104
# 249 "BasicServicesP.nc"
static inline void BasicServicesP__RadioControl__startDone(error_t error)
#line 249
{
  __nesc_hton_uint16(BasicServicesP__MoteID.nxdata, TOS_NODE_ID);


  if (error != SUCCESS) {
      if (BasicServicesP__RadioControl__start() != SUCCESS) {
#line 254
        dbgIx("terra", "BS::Error in RETRY RadioControl.start()\n");
        }
#line 255
      return;
    }




  dbgIx("terra", "BS::RadioControl.startDone(). TOS_NODE_ID=%d, TERRA_MOTE_TYPE = %d\n", TOS_NODE_ID, BasicServicesP__TERRA_MOTE_TYPE);




  if (BasicServicesP__firstInic) {
      reqProgBlock_t Data;

      BasicServicesP__firstInic = FALSE;

      BasicServicesP__ReqState = RO_NEW_VERSION;
      __nesc_hton_uint8(Data.reqOper.nxdata, RO_NEW_VERSION);
      __nesc_hton_uint8(Data.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
      __nesc_hton_uint16(Data.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
      __nesc_hton_uint16(Data.blockId.nxdata, 0);
      BasicServicesP__lastRequestBlock = 0;
      __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, AM_BROADCAST_ADDR);
      BasicServicesP__sendReqProgBlock(&Data);

      BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
    }








  BasicServicesP__BSBoot__booted();

  __nesc_hton_uint16(BasicServicesP__ProgVersion.nxdata, BasicServicesP__BSUpload__progRestore());
  if (__nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) > 0) {
      BasicServicesP__BSUpload__start(TRUE);
    }
}

# 113 "/home/mauricio/Terra/TerraVM/src/interfaces/SplitControl.nc"
inline static void UDPActiveMessageP__SplitControl__startDone(error_t error){
#line 113
  BasicServicesP__RadioControl__startDone(error);
#line 113
}
#line 113
# 166 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__start_done__runTask(void )
#line 166
{
  UDPActiveMessageP__SplitControl__startDone(SUCCESS);
}

#line 40
static inline uint16_t UDPActiveMessageP__getID_fromIP(void )
#line 40
{

  struct ifaddrs *ifaddr;
#line 42
  struct ifaddrs *ifa;
  int family;
#line 43
  int s;
  char host[1025];
  unsigned int addrHost[4];

  if (getifaddrs(&ifaddr) == -1) {
      perror("getifaddrs");
      exit(1);
    }





  dbgIx("UDP", "UDP::getID_fromIP() - looking for a good addr\n");
  for (ifa = ifaddr; ifa != (void *)0; ifa = ifa->ifa_next) {
      if (ifa->ifa_addr == (void *)0) {
        continue;
        }
      family = ifa->ifa_addr->sa_family;

      if (family == 2) {
          s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in ), host, 1025, (void *)0, 0, 0x00000002);
          if (s != 0) {
              dbgIx("UDP", "UDP::getID_fromIP():getnameinfo() failed: %s\n", gai_strerror(s));
              exit(1);
            }

          sscanf(host, "%u.%u.%u.%u", &addrHost[0], &addrHost[1], &addrHost[2], &addrHost[3]);
          dbgIx("UDP", "UDP::getID_fromIP() - test addr: %d.%d.%d.%d\n", 
          addrHost[0], addrHost[1], addrHost[2], addrHost[3]);

          if (addrHost[0] != 127) {
#line 74
            return (uint16_t )(addrHost[2] * 256 + addrHost[3]);
            }
        }
    }
  return 0;
}

# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void UDPActiveMessageP__timerDelay__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(1U, dt);
#line 73
}
#line 73
# 361 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline am_addr_t UDPActiveMessageP__AMPacket__address(void )
#line 361
{
  return TOS_NODE_ID;
}

#line 336
static inline bool UDPActiveMessageP__AMPacket__isForMe(message_t *amsg)
#line 336
{
  return UDPActiveMessageP__AMPacket__destination(amsg) == UDPActiveMessageP__AMPacket__address() || 
  UDPActiveMessageP__AMPacket__destination(amsg) == AM_BROADCAST_ADDR;
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t UDPActiveMessageP__send_doneAck__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(UDPActiveMessageP__send_doneAck);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void UDPActiveMessageP__sendDoneTimer__stop(void ){
#line 78
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(0U);
#line 78
}
#line 78
#line 92
inline static bool UDPActiveMessageP__sendDoneTimer__isRunning(void ){
#line 92
  unsigned char __nesc_result;
#line 92

#line 92
  __nesc_result = /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__isRunning(0U);
#line 92

#line 92
  return __nesc_result;
#line 92
}
#line 92
# 95 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__UDP_HandleReceiver(int signum)
{
  char dgram[256];
  struct sockaddr_in addr;
  int fromlen = sizeof addr;
  message_t *msg;
  ackMessage_t receiveAckMsg;
  int size;

  size = recvfrom(UDPActiveMessageP__socket_receiver, dgram, 256, 0, (struct sockaddr *)&addr, (socklen_t *)&fromlen);
  dbgIx("UDP", "UDP::UDP_HandleReceiver() - Received some data - len=%d\n", size);

  if (size < 0) {
#line 107
      dbgIx("UDP", "UDP::Ignoring message with size < 0\n");
#line 107
      return;
    }
  if (__nesc_ntoh_uint16((* (nx_uint16_t *)dgram).nxdata) == 0xFFFE) {

      memcpy(&receiveAckMsg, (ackMessage_t *)dgram, sizeof(ackMessage_t ));
      if (__nesc_ntoh_uint16(receiveAckMsg.dest.nxdata) == TOS_NODE_ID) {




          dbgIx("UDP", "UDP::received an ackID: %d from %d\n", __nesc_ntoh_uint16(receiveAckMsg.ackID.nxdata), __nesc_ntoh_uint16(receiveAckMsg.src.nxdata));


          if (__nesc_ntoh_uint16(
#line 118
          receiveAckMsg.src.nxdata) == __nesc_ntoh_uint16(UDPActiveMessageP__getHeader(UDPActiveMessageP__lastSendMessage)->dest.nxdata)
           && __nesc_ntoh_uint16(receiveAckMsg.ackID.nxdata) == __nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(UDPActiveMessageP__lastSendMessage)->ackID.nxdata)
           && UDPActiveMessageP__sendDoneTimer__isRunning()) {
              dbgIx("UDP", "UDP::ACK RECEBIDO\n");
              UDPActiveMessageP__sendDoneTimer__stop();
              UDPActiveMessageP__send_doneAck__postTask();
            }
        }
      else 
#line 125
        {
          dbgIx("UDP", "UDP:: Ack is not for me!\n");
        }
    }
  else {
      msg = (message_t *)dgram;

      if (UDPActiveMessageP__AMPacket__isForMe(msg)) {
          memcpy(&UDPActiveMessageP__lastReceiveMessage, msg, sizeof(message_t ));
          dbgIx("UDP", "UDP::Received from %d -- reqAck: %d\n", UDPActiveMessageP__AMPacket__source(msg), __nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata));


          if (__nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata) != 0 && __nesc_ntoh_uint16(UDPActiveMessageP__getHeader(msg)->dest.nxdata) == TOS_NODE_ID) {
              dbgIx("UDP", "UDP:: Reply an Ack message\n");
              UDPActiveMessageP__timerDelay__startOneShot(1);
            }
          else 
#line 140
            {
              UDPActiveMessageP__receiveTask__postTask();
            }
        }
      else 
#line 143
        {
          dbgIx("UDP", "UDP:: Message is not for me!\n");
        }
    }
}

# 89 "/home/mauricio/Android/Sdk/ndk-bundle/platforms/android-9/arch-arm/usr/include/signal.h"
static __inline int sigemptyset(sigset_t *set)
{
  memset(set, 0, sizeof  (*set));
  return 0;
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t UDPActiveMessageP__start_done__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(UDPActiveMessageP__start_done);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 65 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
static inline /*TerraVMAppC.evtQ*/QueueC__0__queue_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__head(void )
#line 65
{
  return /*TerraVMAppC.evtQ*/QueueC__0__queue[/*TerraVMAppC.evtQ*/QueueC__0__head];
}

#line 53
static inline bool /*TerraVMAppC.evtQ*/QueueC__0__Queue__empty(void )
#line 53
{
  return /*TerraVMAppC.evtQ*/QueueC__0__size == 0;
}

# 6 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/RPI_InternalFlashP.nc"
static inline FILE *RPI_InternalFlashP__getFD(char *mode)
#line 6
{
  char fname[80];

#line 8
  sprintf(fname, "Terra_ProgStorage_%d.bin", TOS_NODE_ID);
  return fopen(fname, mode);
}

#line 23
static inline error_t RPI_InternalFlashP__IntFlash__write(void *addr, void *buf, uint16_t size)
#line 23
{
  FILE *fd;
  error_t stat;

#line 26
  dbgIx("terra", "IntFlash.write(): addr=%d, size=%d\n", (uint32_t )addr, size);
  fd = RPI_InternalFlashP__getFD("w");
  if (fd == (void *)0) {
#line 28
    return FAIL;
    }
#line 29
  stat = fwrite(buf, size, 1, fd);
  if (stat != SUCCESS) {
#line 30
    return FAIL;
    }
#line 31
  return SUCCESS;
}

# 68 "/home/mauricio/Terra/TerraVM/src/interfaces/InternalFlash.nc"
inline static error_t ProgStorageP__InternalFlash__write(void *addr, void * buf, uint16_t size){
#line 68
  unsigned char __nesc_result;
#line 68

#line 68
  __nesc_result = RPI_InternalFlashP__IntFlash__write(addr, buf, size);
#line 68

#line 68
  return __nesc_result;
#line 68
}
#line 68
# 17 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/ProgStorageP.nc"
static inline error_t ProgStorageP__ProgStorage__save(progEnv_t *env, uint8_t *bytecode, uint16_t len)
#line 17
{
  error_t status;

#line 19
  if (len + sizeof(progEnv_t ) > 4096) {
#line 19
    return FAIL;
    }
#line 20
  memcpy(& ProgStorageP__data.env, env, sizeof(progEnv_t ));
  memcpy(& ProgStorageP__data.bytecode, bytecode, len);
  status = ProgStorageP__InternalFlash__write((void *)0, &ProgStorageP__data, 4096);
  return status;
}

# 12 "ProgStorage.nc"
inline static error_t TerraVMC__ProgStorage__save(progEnv_t *env, uint8_t *bytecode, uint16_t len){
#line 12
  unsigned char __nesc_result;
#line 12

#line 12
  __nesc_result = ProgStorageP__ProgStorage__save(env, bytecode, len);
#line 12

#line 12
  return __nesc_result;
#line 12
}
#line 12
# 566 "TerraVMC.nc"
static inline int TerraVMC__ceu_go_init(int *ret)
{

  if (TerraVMC__haltedFlag) {
#line 569
    return 0;
    }
  (&TerraVMC__CEU_)->p_tracks = (TerraVMC__tceu_trk *)TerraVMC__CEU_data + 0;
  (&TerraVMC__CEU_)->p_mem = TerraVMC__CEU_data + (TerraVMC__envData.nTracks + 1) * sizeof(TerraVMC__tceu_trk );
  TerraVMC__MEM = (&TerraVMC__CEU_)->p_mem;


  TerraVMC__ceu_track_ins(0x01, 0xFF, 0, TerraVMC__envData.ProgStart);
  return TerraVMC__ceu_go(ret);
}

#line 766
static inline void TerraVMC__ceu_boot(void )
{
  TerraVMC__old = (u32 )TerraVMC__BSTimerVM__getNow();
  TerraVMC__ceu_go_init((void *)0);
}

# 88 "/home/mauricio/Terra/TerraVM/src/interfaces/AMPacket.nc"
inline static am_addr_t BasicServicesP__RadioAMPacket__source(message_t * amsg){
#line 88
  unsigned short __nesc_result;
#line 88

#line 88
  __nesc_result = UDPActiveMessageP__AMPacket__source(amsg);
#line 88

#line 88
  return __nesc_result;
#line 88
}
#line 88
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t VMCustomP__BCRadio_receive__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(VMCustomP__BCRadio_receive);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 199 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static inline void VMCustomP__BSRadio__receive(uint8_t am_id, message_t *msg, void *payload, uint8_t len)
#line 199
{
  dbgIx("terra", "Custom::BSRadio.receive(): AM_ID = %d\n", am_id);
  if (am_id == AM_USRMSG) {
      memcpy(&VMCustomP__ExtDataRadioReceived, payload, sizeof(usrMsg_t ));
      VMCustomP__BCRadio_receive__postTask();
    }
  else 
#line 204
    {
      dbgIx("terra", "Custom::BSRadio.receive(): Discarting AM_ID = %d\n", am_id);
    }
}

# 12 "BSRadio.nc"
inline static void BasicServicesP__BSRadio__receive(uint8_t am_id, message_t *msg, void *payload, uint8_t len){
#line 12
  VMCustomP__BSRadio__receive(am_id, msg, payload, len);
#line 12
}
#line 12
# 147 "/home/mauricio/Terra/TerraVM/src/interfaces/AMPacket.nc"
inline static am_id_t BasicServicesP__RadioAMPacket__type(message_t * amsg){
#line 147
  unsigned char __nesc_result;
#line 147

#line 147
  __nesc_result = UDPActiveMessageP__AMPacket__type(amsg);
#line 147

#line 147
  return __nesc_result;
#line 147
}
#line 147
# 656 "BasicServicesP.nc"
static inline void BasicServicesP__recCustomMsgNet_receive(message_t *msg, void *payload, uint8_t len)
#line 656
{
  uint8_t am_id = (uint8_t )BasicServicesP__RadioAMPacket__type(msg);

#line 658
  dbgIx("terra", "BS::recCustomMsgNet.receive():\n");
  dbgIx("VMDBG", "Radio: Received Custom Msg AM=%d from %d\n", am_id, BasicServicesP__RadioAMPacket__source(msg));
  BasicServicesP__BSRadio__receive(am_id, msg, payload, len);
}

# 8 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__inQ__put(void *Data){
#line 8
  unsigned char __nesc_result;
#line 8

#line 8
  __nesc_result = /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__put(Data);
#line 8

#line 8
  return __nesc_result;
#line 8
}
#line 8
# 666 "BasicServicesP.nc"
static inline void BasicServicesP__recReqDataNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial)
#line 666
{

  dbgIx("terra", "BS::recReqDataNet_receive().\n");

  memcpy(BasicServicesP__tempInputInQ.Data, payload, sizeof(reqData_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.fromSerial.nxdata, fromSerial);

  __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_REQDATA);
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(reqData_t ));

  if (BasicServicesP__inQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 676
    dbgIx("terra", "BS::recReqDataNet_receive(): inQueue is full! Losting a message.\n");
    }
}

#line 632
static inline void BasicServicesP__recSetDataNDNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial)
#line 632
{
  setDataND_t *xmsg;

#line 634
  dbgIx("terra", "BS::recSetDataNDNet_receive().\n");

  memcpy(BasicServicesP__tempInputInQ.Data, payload, sizeof(setDataND_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.fromSerial.nxdata, fromSerial);
  xmsg = (setDataND_t *)BasicServicesP__tempInputInQ.Data;
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_SETDATAND);
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(setDataND_t ));

  if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) != __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata)) {
#line 642
      dbgIx("terra", "BS::recSetDataNDNet_receive(): Discarding old version!\n");
#line 642
      return;
    }
#line 643
  if (__nesc_ntoh_uint16(xmsg->seq.nxdata) < __nesc_ntoh_uint16(BasicServicesP__NewDataSeq.nxdata) + 1) {
#line 643
      dbgIx("terra", "BS::recSetDataNDNet_receive(): Discarding old data!\n");
#line 643
      return;
    }
  if (BasicServicesP__inQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 645
    dbgIx("terra", "BS::recSetDataNDNet_receive(): inQueue is full! Losting a message.\n");
    }
  __nesc_hton_uint16(BasicServicesP__NewDataMoteSource.nxdata, BasicServicesP__RadioAMPacket__source(msg));

  if (__nesc_ntoh_uint16(xmsg->seq.nxdata) == __nesc_ntoh_uint16(BasicServicesP__NewDataSeq.nxdata) + 1) {
      __nesc_hton_uint16(BasicServicesP__tempInputInQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
      if (BasicServicesP__outQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 651
        dbgIx("terra", "BS::recSetDataNDNet_receive(): outQueue is full! Losting a message.\n");
        }
    }
}

# 59 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static inline uint16_t /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(uint16_t bitnum)
{
  return 1 << bitnum % /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ELEMENT_SIZE;
}

#line 54
static inline uint16_t /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(uint16_t bitnum)
{
  return bitnum / /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ELEMENT_SIZE;
}

#line 97
static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clear(uint16_t bitnum)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 99
    {
#line 99
      /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(bitnum)] &= ~/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(bitnum);
    }
#line 100
    __nesc_atomic_end(__nesc_atomic); }
}

# 62 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static void BasicServicesP__BMaux__clear(uint16_t bitnum){
#line 62
  /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clear(bitnum);
#line 62
}
#line 62
# 600 "BasicServicesP.nc"
static inline void BasicServicesP__recReqProgBlockNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial)
#line 600
{
  reqProgBlock_t *xmsg;

  memcpy(BasicServicesP__tempInputInQ.Data, payload, sizeof(reqProgBlock_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.fromSerial.nxdata, fromSerial);
  xmsg = (reqProgBlock_t *)BasicServicesP__tempInputInQ.Data;
  dbgIx("terra", "BS::recReqProgBlockNet_receive(). Local MoteType=%d, Msg MoteType=%d\n", BasicServicesP__TERRA_MOTE_TYPE, __nesc_ntoh_uint8(xmsg->moteType.nxdata));

  if (__nesc_ntoh_uint8(xmsg->moteType.nxdata) == BasicServicesP__TERRA_MOTE_TYPE) {
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_REQPROGBLOCK);
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(reqProgBlock_t ));

      if (BasicServicesP__inQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 612
        dbgIx("terra", "BS::recReqProgBlockNet_receive(): inQueue is full! Losting a message.\n");
        }
    }
  else 
#line 613
    {

      dbgIx("terra", "BS::recReqProgBlockNet_receive(): Different MoteType. Forwarding to my Parent = %d.\n", BasicServicesP__lastRecParentId);

      if (__nesc_ntoh_uint16(xmsg->blockId.nxdata) == 0) {
          BasicServicesP__BMaux__clear(__nesc_ntoh_uint16(xmsg->blockId.nxdata));
          __nesc_hton_uint16(BasicServicesP__lastRecNewProgVersion.nxdata, 0);
        }
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_REQPROGBLOCK);
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(reqProgBlock_t ));
      __nesc_hton_uint16(BasicServicesP__tempInputInQ.sendToMote.nxdata, BasicServicesP__lastRecParentId);
      if (BasicServicesP__outQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 624
        dbgIx("terra", "BS::recReqProgBlockNet_receive(): outQueue is full! Losting a message to my parent.\n");
        }
    }
}

# 92 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__set(uint16_t bitnum)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 94
    {
#line 94
      /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(bitnum)] |= /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(bitnum);
    }
#line 95
    __nesc_atomic_end(__nesc_atomic); }
}

# 56 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static void BasicServicesP__BMaux__set(uint16_t bitnum){
#line 56
  /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__set(bitnum);
#line 56
}
#line 56
#line 50
inline static bool BasicServicesP__BMaux__get(uint16_t bitnum){
#line 50
  unsigned char __nesc_result;
#line 50

#line 50
  __nesc_result = /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__get(bitnum);
#line 50

#line 50
  return __nesc_result;
#line 50
}
#line 50
# 544 "BasicServicesP.nc"
static inline void BasicServicesP__recNewProgBlockNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial)
#line 544
{
  newProgBlock_t *xmsg;

  memcpy(BasicServicesP__tempInputInQ.Data, payload, sizeof(newProgBlock_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.fromSerial.nxdata, fromSerial);
  xmsg = (newProgBlock_t *)BasicServicesP__tempInputInQ.Data;
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_NEWPROGBLOCK);
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(newProgBlock_t ));
  dbgIx("terra", "BS::recNewProgBlockNet_receive(): xmsg->moteType=%d, local MoteType=%d, xmsg->versionId=%d,ProgVersion=%d, xmsg->blockId=%d, ProgBlockStart=%d\n", __nesc_ntoh_uint8(
  xmsg->moteType.nxdata), BasicServicesP__TERRA_MOTE_TYPE, __nesc_ntoh_uint16(xmsg->versionId.nxdata), __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata), __nesc_ntoh_uint16(xmsg->blockId.nxdata), __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata));


  if (__nesc_ntoh_uint8(xmsg->moteType.nxdata) == BasicServicesP__TERRA_MOTE_TYPE) {
      if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) == __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata)) {
          if (!BasicServicesP__BM__get(__nesc_ntoh_uint16(xmsg->blockId.nxdata))) {
              if (__nesc_ntoh_uint16(xmsg->blockId.nxdata) == __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata)) {

                  if (BasicServicesP__outQ__put(&BasicServicesP__lastNewProgVersion) != SUCCESS) {
#line 561
                    dbgIx("terra", "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");
                    }
                }
              if (BasicServicesP__inQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 564
                dbgIx("terra", "BS::recNewProgBlockNet_receive(): inQueue is full! Losting a message.\n");
                }
              __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, BasicServicesP__RadioAMPacket__source(msg));

              if (BasicServicesP__outQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 568
                dbgIx("terra", "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message.\n");
                }
            }
          else 
#line 569
            {
              dbgIx("terra", "BS::recNewProgBlockNet_receive(): Discarding duplicated message - block is 0!\n");
            }
        }
      else 
#line 572
        {
          if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) > __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata)) {

              if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) != BasicServicesP__lastBigAppVersion) {
                  BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
                }
            }
          else {
#line 579
            dbgIx("terra", "BS::recNewProgBlockNet_receive(): Discarding old version message!\n");
            }
        }
    }
  else 
#line 581
    {

      dbgIx("terra", "BS::recNewProgBlockNet_receive(): xmsg->versionId=%d, lastRecNewProgBlock_versionId=%d, xmsg->blockId=%d, BMaux.get()=%d\n", __nesc_ntoh_uint16(
      xmsg->versionId.nxdata), BasicServicesP__lastRecNewProgBlock_versionId, __nesc_ntoh_uint16(xmsg->blockId.nxdata), BasicServicesP__BMaux__get(__nesc_ntoh_uint16(xmsg->blockId.nxdata)));
      if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) != BasicServicesP__lastRecNewProgBlock_versionId || BasicServicesP__BMaux__get(__nesc_ntoh_uint16(xmsg->blockId.nxdata)) == 0) {
          BasicServicesP__lastRecNewProgBlock_versionId = __nesc_ntoh_uint16(xmsg->versionId.nxdata);
          BasicServicesP__BMaux__set(__nesc_ntoh_uint16(xmsg->blockId.nxdata));
          __nesc_hton_uint16(BasicServicesP__tempInputInQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
          dbgIx("terra", "BS::recNewProgBlockNet_receive(): Forwarding different MoteType message!\n");
          if (BasicServicesP__outQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 590
            dbgIx("terra", "BS::recNewProgBlockNet_receive(): outQueue is full! Losting a message. (forwarding different MoteType)\n");
            }
        }
      else 
#line 591
        {
          dbgIx("terra", "BS::recNewProgBlockNet_receive(): Discarding different MoteType message!\n");
        }
    }
}

# 70 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static inline void /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clearAll(void )
{
  uint16_t bitnum;

#line 73
  memset(/*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits, 0, sizeof /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits);

  for (bitnum = 100; bitnum < /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ARRAY_SIZE * /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ELEMENT_SIZE; bitnum++) 
    { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 76
      {
#line 76
        /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(bitnum)] |= /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(bitnum);
      }
#line 77
      __nesc_atomic_end(__nesc_atomic); }
}

# 38 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static void BasicServicesP__BMaux__clearAll(void ){
#line 38
  /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__clearAll();
#line 38
}
#line 38
# 462 "BasicServicesP.nc"
static inline void BasicServicesP__recNewProgVersionNet_receive(message_t *msg, void *payload, uint8_t len, uint8_t fromSerial)
#line 462
{
  newProgVersion_t *xmsg;


  memcpy(BasicServicesP__tempInputInQ.Data, payload, sizeof(newProgVersion_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputInQ.fromSerial.nxdata, fromSerial);
  xmsg = (newProgVersion_t *)BasicServicesP__tempInputInQ.Data;
  dbgIx("terra", "BS::recNewProgVersionNet_receive(): from %d, local MoteType= %d, Msg MoteType=%d\n", 
  BasicServicesP__RadioAMPacket__source(msg), BasicServicesP__TERRA_MOTE_TYPE, __nesc_ntoh_uint8(xmsg->moteType.nxdata));
#line 486
  dbgIx("terra", "BS::recNewProgVersionNet_receive(): versionId=%04x:%d, blockLen=%04x:%d, blockStart=%04x:%d, startProg=%04x:%d, endProg=%04x:%d, appSize=%04x:%d, \n", __nesc_ntoh_uint16(
  xmsg->versionId.nxdata), __nesc_ntoh_uint16(xmsg->versionId.nxdata), __nesc_ntoh_uint16(xmsg->blockLen.nxdata), __nesc_ntoh_uint16(xmsg->blockLen.nxdata), __nesc_ntoh_uint16(xmsg->blockStart.nxdata), __nesc_ntoh_uint16(xmsg->blockStart.nxdata), __nesc_ntoh_uint16(
  xmsg->startProg.nxdata), __nesc_ntoh_uint16(xmsg->startProg.nxdata), __nesc_ntoh_uint16(xmsg->endProg.nxdata), __nesc_ntoh_uint16(xmsg->endProg.nxdata), __nesc_ntoh_uint16(xmsg->appSize.nxdata));


  if (__nesc_ntoh_uint16(xmsg->versionId.nxdata) <= __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) || __nesc_ntoh_uint16(xmsg->versionId.nxdata) == __nesc_ntoh_uint16(BasicServicesP__lastRecNewProgVersion.nxdata)) {
      dbgIx("terra", "BS::recNewProgVersionNet_receive(): Discarding duplicated message!\n");
      return;
    }

  __nesc_hton_uint16(BasicServicesP__lastRecNewProgVersion.nxdata, __nesc_ntoh_uint16(xmsg->versionId.nxdata));
  BasicServicesP__BMaux__clearAll();

  if (BasicServicesP__lastRecParentId == 0) {
      BasicServicesP__lastRecParentId = BasicServicesP__RadioAMPacket__source(msg);
      dbgIx("terra", "BS::recNewProgVersionNet_receive(): ParentId=%d \n", BasicServicesP__lastRecParentId);
    }


  if (__nesc_ntoh_uint8(xmsg->moteType.nxdata) == BasicServicesP__TERRA_MOTE_TYPE) {


      if (__nesc_ntoh_uint16(xmsg->appSize.nxdata) > BLOCK_SIZE * CURRENT_MAX_BLOCKS) {
          BasicServicesP__lastBigAppVersion = __nesc_ntoh_uint16(xmsg->versionId.nxdata);

          return;
        }
      else 
#line 512
        {
          BasicServicesP__lastBigAppVersion = -1L;
        }



      __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_NEWPROGVERSION);
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(newProgVersion_t ));


      if (BasicServicesP__inQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 522
        dbgIx("terra", "BS::recNewProgVersionNet_receive(): inQueue is full! Losting a message.\n");
        }
      __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, BasicServicesP__RadioAMPacket__source(msg));

      __nesc_hton_uint16(BasicServicesP__tempInputInQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
      memcpy(&BasicServicesP__lastNewProgVersion, &BasicServicesP__tempInputInQ, sizeof(GenericData_t ));
    }
  else {


      __nesc_hton_uint8(BasicServicesP__tempInputInQ.AM_ID.nxdata, AM_NEWPROGVERSION);
      __nesc_hton_uint8(BasicServicesP__tempInputInQ.DataSize.nxdata, sizeof(newProgVersion_t ));
      __nesc_hton_uint16(BasicServicesP__tempInputInQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
      if (BasicServicesP__outQ__put(&BasicServicesP__tempInputInQ) != SUCCESS) {
#line 535
        dbgIx("terra", "BS::recNewProgVersionNet_receive(): inQueue is full! Losting a message.\n");
        }
    }
}

#line 680
static inline message_t *BasicServicesP__RadioReceiver__receive(am_id_t id, message_t *msg, void *payload, uint8_t len)
#line 680
{
  dbgIx("terra", "BS::RadioReceiver.receive(). AM=%hhu from %d.  disseminatorRoot=%d\n", id, BasicServicesP__RadioAMPacket__source(msg), BasicServicesP__disseminatorRoot);

  switch (id) {
      case AM_NEWPROGVERSION: 
        BasicServicesP__recNewProgVersionNet_receive(msg, payload, len, FALSE);
      break;
      case AM_NEWPROGBLOCK: 
        BasicServicesP__recNewProgBlockNet_receive(msg, payload, len, FALSE);
      break;
      case AM_REQPROGBLOCK: 
        BasicServicesP__recReqProgBlockNet_receive(msg, payload, len, FALSE);
      break;
      case AM_SETDATAND: 
        BasicServicesP__recSetDataNDNet_receive(msg, payload, len, FALSE);
      break;
      case AM_REQDATA: 
        BasicServicesP__recReqDataNet_receive(msg, payload, len, FALSE);
      break;
      default: 
        if (id >= AM_CUSTOM_START && id <= AM_CUSTOM_END) {
            if (BasicServicesP__loadingProgramFlag == FALSE) {
                BasicServicesP__recCustomMsgNet_receive(msg, payload, len);
              }
          }
        else 
#line 704
          {
            dbgIx("terra", "BS::RadioReceiver.receive(). Received a undefined AM=%hhu from %hhu\n", id, BasicServicesP__RadioAMPacket__source(msg));
          }
      break;
    }
  return msg;
}

# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Receive.nc"
inline static message_t * UDPActiveMessageP__Receive__receive(am_id_t arg_0x7f7d46f9ed68, message_t * msg, void * payload, uint8_t len){
#line 78
  nx_struct message_t *__nesc_result;
#line 78

#line 78
  __nesc_result = BasicServicesP__RadioReceiver__receive(arg_0x7f7d46f9ed68, msg, payload, len);
#line 78

#line 78
  return __nesc_result;
#line 78
}
#line 78
# 91 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__receiveTask__runTask(void )
#line 91
{
  UDPActiveMessageP__Receive__receive(UDPActiveMessageP__AMPacket__type(&UDPActiveMessageP__lastReceiveMessage), &UDPActiveMessageP__lastReceiveMessage, UDPActiveMessageP__Packet__getPayload(&UDPActiveMessageP__lastReceiveMessage, UDPActiveMessageP__Packet__payloadLength(&UDPActiveMessageP__lastReceiveMessage)), UDPActiveMessageP__Packet__payloadLength(&UDPActiveMessageP__lastReceiveMessage));
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 86 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__send_done__runTask(void )
#line 86
{
  __nesc_hton_uint16(UDPActiveMessageP__getMetadata(UDPActiveMessageP__lastSendMessage)->ackID.nxdata, FALSE);
  UDPActiveMessageP__AMSend__sendDone(__nesc_ntoh_uint8(UDPActiveMessageP__getHeader(UDPActiveMessageP__lastSendMessage)->type.nxdata), UDPActiveMessageP__lastSendMessage, SUCCESS);
}

#line 81
static inline void UDPActiveMessageP__send_doneAck__runTask(void )
#line 81
{
  __nesc_hton_uint16(UDPActiveMessageP__getMetadata(UDPActiveMessageP__lastSendMessage)->ackID.nxdata, TRUE);
  UDPActiveMessageP__AMSend__sendDone(__nesc_ntoh_uint8(UDPActiveMessageP__getHeader(UDPActiveMessageP__lastSendMessage)->type.nxdata), UDPActiveMessageP__lastSendMessage, SUCCESS);
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t BasicServicesP__sendMessage__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(BasicServicesP__sendMessage);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__outQ__get(void *Data){
#line 9
  unsigned char __nesc_result;
#line 9

#line 9
  __nesc_result = /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__get(Data);
#line 9

#line 9
  return __nesc_result;
#line 9
}
#line 9
# 1284 "BasicServicesP.nc"
static inline void BasicServicesP__sendNextMsg__runTask(void )
#line 1284
{
  dbgIx("terra", "BS::sendNextMsg(): \n");
  if (BasicServicesP__sendCounter < MAX_SEND_RETRIES) {
      BasicServicesP__sendMessage__postTask();
    }
  else 
#line 1288
    {
      BasicServicesP__outQ__get(&BasicServicesP__tempOutputOutQ);
      BasicServicesP__sendCounter = 0;
      BasicServicesP__sendMessage__postTask();
    }
}

# 11 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__outQ__read(void *Data){
#line 11
  unsigned char __nesc_result;
#line 11

#line 11
  __nesc_result = /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__read(Data);
#line 11

#line 11
  return __nesc_result;
#line 11
}
#line 11
# 1232 "BasicServicesP.nc"
static inline void BasicServicesP__sendMessage__runTask(void )
#line 1232
{
  BasicServicesP__sendCounter++;
  if (BasicServicesP__outQ__read(&BasicServicesP__tempOutputOutQ) == SUCCESS) {
      dbgIx("terra", "BS::sendMessage(): AM=%d, sendToMote=%d.\n", __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata));
      switch (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata)) {
#line 1252
          case AM_NEWPROGVERSION: BasicServicesP__sendRadioN();
#line 1252
          break;
          case AM_NEWPROGBLOCK: BasicServicesP__sendRadioN();
#line 1253
          break;
          case AM_REQPROGBLOCK: BasicServicesP__sendRadioN();
#line 1254
          break;




          default: 
            if (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) >= AM_CUSTOM_START && __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) <= AM_CUSTOM_END) {
                BasicServicesP__sendRadioN();
              }
          break;
        }
    }
  else 
#line 1265
    {
      BasicServicesP__outQ__get(&BasicServicesP__tempOutputOutQ);
      dbgIx("terra", "BS::sendMessage(): outQueue is empty!\n");
    }
}

# 126 "/home/mauricio/Terra/TerraVM/src/interfaces/Packet.nc"
inline static void * BasicServicesP__RadioPacket__getPayload(message_t * msg, uint8_t len){
#line 126
  void *__nesc_result;
#line 126

#line 126
  __nesc_result = UDPActiveMessageP__Packet__getPayload(msg, len);
#line 126

#line 126
  return __nesc_result;
#line 126
}
#line 126
# 407 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline uint8_t UDPActiveMessageP__Packet__maxPayloadLength(void )
#line 407
{
  return 28;
#line 408
  ;
}

# 106 "/home/mauricio/Terra/TerraVM/src/interfaces/Packet.nc"
inline static uint8_t BasicServicesP__RadioPacket__maxPayloadLength(void ){
#line 106
  unsigned char __nesc_result;
#line 106

#line 106
  __nesc_result = UDPActiveMessageP__Packet__maxPayloadLength();
#line 106

#line 106
  return __nesc_result;
#line 106
}
#line 106
# 431 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline error_t UDPActiveMessageP__PacketAcknowledgements__requestAck(message_t *msg)
#line 431
{

  __nesc_hton_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata, 1);
  return SUCCESS;
}

# 59 "/home/mauricio/Terra/TerraVM/src/interfaces/PacketAcknowledgements.nc"
inline static error_t BasicServicesP__RadioAck__requestAck(message_t * msg){
#line 59
  unsigned char __nesc_result;
#line 59

#line 59
  __nesc_result = UDPActiveMessageP__PacketAcknowledgements__requestAck(msg);
#line 59

#line 59
  return __nesc_result;
#line 59
}
#line 59
# 437 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline error_t UDPActiveMessageP__PacketAcknowledgements__noAck(message_t *msg)
#line 437
{

  __nesc_hton_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata, 0);
  return SUCCESS;
}

# 71 "/home/mauricio/Terra/TerraVM/src/interfaces/PacketAcknowledgements.nc"
inline static error_t BasicServicesP__RadioAck__noAck(message_t * msg){
#line 71
  unsigned char __nesc_result;
#line 71

#line 71
  __nesc_result = UDPActiveMessageP__PacketAcknowledgements__noAck(msg);
#line 71

#line 71
  return __nesc_result;
#line 71
}
#line 71
# 467 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__AMAux__setPower(message_t *p_msg, uint8_t power)
#line 467
{
}

# 2 "/home/mauricio/Terra/TerraVM/src/interfaces/AMAux.nc"
inline static void BasicServicesP__AMAux__setPower(message_t *p_msg, uint8_t power){
#line 2
  UDPActiveMessageP__AMAux__setPower(p_msg, power);
#line 2
}
#line 2
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t BasicServicesP__forceRadioDone__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(BasicServicesP__forceRadioDone);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 73 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void UDPActiveMessageP__sendDoneTimer__startOneShot(uint32_t dt){
#line 73
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__startOneShot(0U, dt);
#line 73
}
#line 73
# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t UDPActiveMessageP__send_done__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(UDPActiveMessageP__send_done);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 346 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static inline void UDPActiveMessageP__AMPacket__setType(message_t *amsg, am_id_t t)
#line 346
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 348
  __nesc_hton_uint8(header->type.nxdata, t);
}

#line 375
static inline void UDPActiveMessageP__AMPacket__setGroup(message_t *amsg, am_group_t grp)
#line 375
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 377
  __nesc_hton_uint8(header->group.nxdata, grp);
}

#line 365
static inline void UDPActiveMessageP__AMPacket__setDestination(message_t *amsg, am_addr_t addr)
#line 365
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 367
  __nesc_hton_uint16(header->dest.nxdata, addr);
}

#line 341
static inline void UDPActiveMessageP__AMPacket__setSource(message_t *amsg, am_addr_t addr)
#line 341
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 343
  __nesc_hton_uint16(header->src.nxdata, addr);
}

#line 299
static inline error_t UDPActiveMessageP__AMSend__send(am_id_t id, am_addr_t am_addr, message_t *msg, uint8_t len)
#line 299
{

  UDPActiveMessageP__AMPacket__setSource(msg, TOS_NODE_ID);
  UDPActiveMessageP__AMPacket__setDestination(msg, am_addr);
  UDPActiveMessageP__AMPacket__setGroup(msg, TOS_AM_GROUP);
  UDPActiveMessageP__AMPacket__setType(msg, id);

  if (__nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata) != 0) {
      UDPActiveMessageP__counter = UDPActiveMessageP__counter == 0 ? 1 : UDPActiveMessageP__counter + 1;
      __nesc_hton_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata, UDPActiveMessageP__counter);
    }
  dbgIx("UDP", "UDP::AMSend.send(): Sending to %d am_id=%d, ackID=%d\n", am_addr, id, __nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata));

  UDPActiveMessageP__lastSendMessage = msg;
  sendto(UDPActiveMessageP__socket_sender, msg, sizeof(message_t ), 0, (struct sockaddr *)&UDPActiveMessageP__addrSender, sizeof(struct sockaddr_in ));


  if (__nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata) == 0) {
    UDPActiveMessageP__send_done__postTask();
    }
  else 
#line 318
    {
      UDPActiveMessageP__sendDoneTimer__startOneShot(100);
    }
  return SUCCESS;
}

# 80 "/home/mauricio/Terra/TerraVM/src/interfaces/AMSend.nc"
inline static error_t BasicServicesP__RadioSender__send(am_id_t arg_0x7f7d472828d8, am_addr_t addr, message_t * msg, uint8_t len){
#line 80
  unsigned char __nesc_result;
#line 80

#line 80
  __nesc_result = UDPActiveMessageP__AMSend__send(arg_0x7f7d472828d8, addr, msg, len);
#line 80

#line 80
  return __nesc_result;
#line 80
}
#line 80
# 1166 "BasicServicesP.nc"
static inline uint8_t BasicServicesP__isOtherNet(uint16_t addr)
#line 1166
{
#line 1166
  return addr != AM_BROADCAST_ADDR && (addr >> 11) != (TOS_NODE_ID >> 11);
}





static inline error_t BasicServicesP__RadioSender_send(uint8_t am_id, uint16_t target, message_t *msg, uint8_t len, uint8_t fromSerial)
#line 1173
{
  error_t stat = SUCCESS;










  dbgIx("terra", "BS::RadioSender_send(): MoteID=%d, AM=%d, to=%d, sendCounter=%d, fromSerial=%d\n", __nesc_ntoh_uint16(BasicServicesP__MoteID.nxdata), __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata), BasicServicesP__sendCounter, fromSerial);
  if (!BasicServicesP__isOtherNet(__nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata)) && ! __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata) == 0) {
      stat = BasicServicesP__RadioSender__send(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata), &BasicServicesP__sendBuff, __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.DataSize.nxdata));
    }
  else 
#line 1188
    {
      dbgIx("terra", "BS::RadioSender_send():bypassing radio \n");
      BasicServicesP__forceRadioDone__postTask();
    }









  return stat;
}

#line 1160
static inline void BasicServicesP__forceRadioDone__runTask(void )
#line 1160
{
  uint8_t id = __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata);

#line 1162
  dbgIx("terra", "BS::forceRadioDone(): am_id=%d \n", id);
  BasicServicesP__RadioSender__sendDone(id, &BasicServicesP__sendBuff, SUCCESS);
}

# 9 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__inQ__get(void *Data){
#line 9
  unsigned char __nesc_result;
#line 9

#line 9
  __nesc_result = /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__get(Data);
#line 9

#line 9
  return __nesc_result;
#line 9
}
#line 9
# 87 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static bool BasicServicesP__BM__isAllBitSet(void ){
#line 87
  unsigned char __nesc_result;
#line 87

#line 87
  __nesc_result = /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__isAllBitSet();
#line 87

#line 87
  return __nesc_result;
#line 87
}
#line 87
# 1402 "BasicServicesP.nc"
static inline void BasicServicesP__sendNewProgVersion(newProgVersion_t *Data)
#line 1402
{
  dbgIx("terra", "BS::sendNewProgVersion(): insert in outQueue\n");
  memcpy(& BasicServicesP__tempInputOutQ.Data, Data, sizeof(newProgVersion_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.AM_ID.nxdata, AM_NEWPROGVERSION);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.DataSize.nxdata, sizeof(newProgVersion_t ));
  __nesc_hton_uint16(BasicServicesP__tempInputOutQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.reqAck.nxdata, 0);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.fromSerial.nxdata, FALSE);
  if (BasicServicesP__outQ__put(&BasicServicesP__tempInputOutQ) != SUCCESS) {
      dbgIx("terra", "BS::sendNewProgVersion(): outQueue is full! Losting a message.\n");
    }
}

# 1828 "TerraVMC.nc"
static inline void TerraVMC__BSUpload__getEnv(newProgVersion_t *data)
#line 1828
{
  dbgIx("terra", "VM::BSUpload.getEnv()\n");
  __nesc_hton_uint16(data->versionId.nxdata, TerraVMC__envData.Version);
  __nesc_hton_uint16(data->startProg.nxdata, TerraVMC__envData.ProgStart);
  __nesc_hton_uint16(data->endProg.nxdata, TerraVMC__envData.ProgEnd);
  __nesc_hton_uint16(data->nTracks.nxdata, TerraVMC__envData.nTracks);
  __nesc_hton_uint16(data->wClocks.nxdata, TerraVMC__envData.wClocks);
  __nesc_hton_uint16(data->asyncs.nxdata, TerraVMC__envData.asyncs);
  __nesc_hton_uint16(data->wClock0.nxdata, TerraVMC__envData.wClock0);
  __nesc_hton_uint16(data->gate0.nxdata, TerraVMC__envData.gate0);
  __nesc_hton_uint16(data->inEvts.nxdata, TerraVMC__envData.inEvts);
  __nesc_hton_uint16(data->async0.nxdata, TerraVMC__envData.async0);
  __nesc_hton_uint16(data->appSize.nxdata, TerraVMC__envData.appSize);
  __nesc_hton_uint8(data->persistFlag.nxdata, TerraVMC__envData.persistFlag);
  dbgIx("terra", "VM::BSUpload.getEnv(): ProgStart=%d, ProgEnd=%d, nTracks=%d, wClocks=%d, asyncs=%d, wClock0=%d, gate0=%d, async0=%d\n", 
  TerraVMC__envData.ProgStart, TerraVMC__envData.ProgEnd, TerraVMC__envData.nTracks, TerraVMC__envData.wClocks, TerraVMC__envData.asyncs, TerraVMC__envData.wClock0, TerraVMC__envData.gate0, TerraVMC__envData.async0);
}

# 26 "BSUpload.nc"
inline static void BasicServicesP__BSUpload__getEnv(newProgVersion_t *data){
#line 26
  TerraVMC__BSUpload__getEnv(data);
#line 26
}
#line 26
# 854 "BasicServicesP.nc"
static inline void BasicServicesP__procRecReqProgBlock(reqProgBlock_t *Data)
#line 854
{
  newProgVersion_t xVersion;
  newProgBlock_t xBlock;
  uint8_t *mem;
  uint16_t i = 0;

#line 859
  dbgIx("terra", "BS::procRecReqProgBlock(). Local version=%hhu, Req Version %hhu Oper=%hhu, BM.isAllBitSet=%s\n", __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata), __nesc_ntoh_uint16(Data->versionId.nxdata), __nesc_ntoh_uint8(Data->reqOper.nxdata), BasicServicesP__BM__isAllBitSet() ? "TRUE" : "FALSE");
  switch (__nesc_ntoh_uint8(Data->reqOper.nxdata)) {
      case RO_NEW_VERSION: 
        if (__nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) > __nesc_ntoh_uint16(Data->versionId.nxdata) && __nesc_ntoh_uint8(Data->moteType.nxdata) == BasicServicesP__TERRA_MOTE_TYPE && __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) > 0 && BasicServicesP__BM__isAllBitSet()) {
            __nesc_hton_uint8(xVersion.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
            __nesc_hton_uint16(xVersion.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
            __nesc_hton_uint16(xVersion.blockLen.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgBlockLen.nxdata));
            __nesc_hton_uint16(xVersion.blockStart.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata));
            BasicServicesP__BSUpload__getEnv(&xVersion);
            BasicServicesP__sendNewProgVersion(&xVersion);
          }
        else 
#line 869
          {
            dbgIx("terra", "BS::procRecReqProgBlock(). Request RO_NEW_VERSION discarted!\n");
          }
      break;
      case RO_DATA_FULL: 

        if (__nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) == __nesc_ntoh_uint16(Data->versionId.nxdata) && __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) > 0 && BasicServicesP__BM__isAllBitSet()) {
            BasicServicesP__DsmBlockCount = 0;
            BasicServicesP__SendDataFullTimer__startOneShot(DISSEMINATION_TIMEOUT);
          }
        else 
#line 878
          {
            dbgIx("terra", "BS::procRecReqProgBlock(). Request RO_DATA_FULL discarted!\n");
          }
      break;
      case RO_DATA_SINGLE: 
        if (__nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) == __nesc_ntoh_uint16(Data->versionId.nxdata) && __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata) > 0 && BasicServicesP__BM__get(__nesc_ntoh_uint16(Data->blockId.nxdata))) {
            __nesc_hton_uint8(xBlock.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
            __nesc_hton_uint16(xBlock.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
            __nesc_hton_uint16(xBlock.blockId.nxdata, __nesc_ntoh_uint16(Data->blockId.nxdata));
            mem = BasicServicesP__BSUpload__getSection(__nesc_ntoh_uint16(Data->blockId.nxdata) * BLOCK_SIZE);
            for (i = 0; i < BLOCK_SIZE; i++) __nesc_hton_uint8(xBlock.data[i].nxdata, __nesc_ntoh_uint8((* (nx_uint8_t *)(mem + i)).nxdata));
            BasicServicesP__ReqState = ST_WAIT_PROG_BLK;
            BasicServicesP__sendNewProgBlock(&xBlock);
          }
        else 
#line 891
          {
            dbgIx("terra", "BS::procRecReqProgBlock(). Request RO_DATA_SINGLE discarted! Block=%hhu\n", BasicServicesP__BM__get(__nesc_ntoh_uint16(Data->blockId.nxdata)));
          }
      break;
    }
}

#line 183
static inline void BasicServicesP__TViewer(char *cmd, uint16_t p1, uint16_t p2)
#line 183
{
  dbgIx("TVIEW", "<<: %s %d %d %d :>>\n", cmd, TOS_NODE_ID, p1, p2);
}

# 59 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static inline uint16_t /*BasicServicesC.Bitmap*/vmBitVectorC__0__getMask(uint16_t bitnum)
{
  return 1 << bitnum % /*BasicServicesC.Bitmap*/vmBitVectorC__0__ELEMENT_SIZE;
}

#line 54
static inline uint16_t /*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(uint16_t bitnum)
{
  return bitnum / /*BasicServicesC.Bitmap*/vmBitVectorC__0__ELEMENT_SIZE;
}

#line 92
static inline void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__set(uint16_t bitnum)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 94
    {
#line 94
      /*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[/*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(bitnum)] |= /*BasicServicesC.Bitmap*/vmBitVectorC__0__getMask(bitnum);
    }
#line 95
    __nesc_atomic_end(__nesc_atomic); }
}

# 56 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static void BasicServicesP__BM__set(uint16_t bitnum){
#line 56
  /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__set(bitnum);
#line 56
}
#line 56
# 1890 "TerraVMC.nc"
static inline void TerraVMC__BSUpload__loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[])
#line 1890
{
  memcpy(&TerraVMC__CEU_data[Addr], Data, Size);
  dbgIx("terra", "VM::BSUpload.loadSection(): blk=%d, Addr=%d, Size=%d 1stByte=%d\n", (uint8_t )(Addr / BLOCK_SIZE), Addr, Size, __nesc_ntoh_uint8(TerraVMC__CEU_data[Addr].nxdata));
}

# 35 "BSUpload.nc"
inline static void BasicServicesP__BSUpload__loadSection(uint16_t Addr, uint8_t Size, uint8_t Data[]){
#line 35
  TerraVMC__BSUpload__loadSection(Addr, Size, Data);
#line 35
}
#line 35
# 78 "/home/mauricio/Terra/TerraVM/src/interfaces/Timer.nc"
inline static void BasicServicesP__ProgReqTimer__stop(void ){
#line 78
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__stop(5U);
#line 78
}
#line 78
# 822 "BasicServicesP.nc"
static inline void BasicServicesP__procNewProgBlock(newProgBlock_t *Data)
#line 822
{
  uint8_t lData[BLOCK_SIZE];
  uint16_t i;
  uint16_t Addr = 0;

#line 826
  dbgIx("terra", "BS::procNewProgBlock(). version=%hhu, blockId=%hhu, ReqState=%d\n", __nesc_ntoh_uint16(Data->versionId.nxdata), __nesc_ntoh_uint16(Data->blockId.nxdata), BasicServicesP__ReqState);
  BasicServicesP__ProgReqTimer__stop();

  for (i = 0; i < BLOCK_SIZE; i++) lData[i] = (uint8_t )__nesc_ntoh_uint8(Data->data[i].nxdata);

  Addr = __nesc_ntoh_uint16(Data->blockId.nxdata) * BLOCK_SIZE;

  BasicServicesP__BSUpload__loadSection(Addr, (uint8_t )BLOCK_SIZE, &lData[0]);
  BasicServicesP__BM__set((uint16_t )__nesc_ntoh_uint16(Data->blockId.nxdata));

  BasicServicesP__ProgTimeOutCounter = 0;

  if (BasicServicesP__BM__isAllBitSet()) {
      BasicServicesP__loadingProgramFlag = FALSE;

      BasicServicesP__ReqState = ST_IDLE;
      BasicServicesP__TViewer("vmstart", 0, 0);
      BasicServicesP__BSUpload__start(TRUE);
    }
  else 
#line 844
    {

      BasicServicesP__ReqState = ST_WAIT_PROG_BLK;
      BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
    }
}

# 128 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static inline void /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__resetRange(uint16_t from, uint16_t to)
{
  uint16_t bitnum;

  memset(/*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits, 255, sizeof /*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits);

  for (bitnum = from; bitnum <= to; bitnum++) /* atomic removed: atomic calls only */
#line 134
    {
#line 134
      /*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[/*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(bitnum)] &= ~/*BasicServicesC.Bitmap*/vmBitVectorC__0__getMask(bitnum);
    }
#line 134
  ;
  dbgIx("terra", "VM::BitVector.resetRange(): from=%d, to=%d, bits=%0x\n", from, to, (uint8_t )/*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[0]);
}

# 94 "/home/mauricio/Terra/TerraVM/src/system/vmBitVector.nc"
inline static void BasicServicesP__BM__resetRange(uint16_t from, uint16_t to){
#line 94
  /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__resetRange(from, to);
#line 94
}
#line 94
# 1808 "TerraVMC.nc"
static inline void TerraVMC__BSUpload__setEnv(newProgVersion_t *data)
#line 1808
{

  TerraVMC__envData.Version = __nesc_ntoh_uint16(data->versionId.nxdata);
  TerraVMC__envData.ProgStart = (uint16_t )__nesc_ntoh_uint16(data->startProg.nxdata);
  TerraVMC__envData.ProgEnd = (uint16_t )__nesc_ntoh_uint16(data->endProg.nxdata);
  TerraVMC__envData.nTracks = __nesc_ntoh_uint16(data->nTracks.nxdata);
  TerraVMC__envData.wClocks = __nesc_ntoh_uint16(data->wClocks.nxdata);
  TerraVMC__envData.asyncs = __nesc_ntoh_uint16(data->asyncs.nxdata);
  TerraVMC__envData.wClock0 = __nesc_ntoh_uint16(data->wClock0.nxdata);
  TerraVMC__envData.gate0 = __nesc_ntoh_uint16(data->gate0.nxdata);
  TerraVMC__envData.inEvts = __nesc_ntoh_uint16(data->inEvts.nxdata);
  TerraVMC__envData.async0 = __nesc_ntoh_uint16(data->async0.nxdata);
  TerraVMC__envData.appSize = __nesc_ntoh_uint16(data->appSize.nxdata);
  TerraVMC__envData.persistFlag = __nesc_ntoh_uint8(data->persistFlag.nxdata);
  TerraVMC__progRestored = FALSE;

  dbgIx("terra", "VM::BSUpload.setEnv(): ProgStart=%d, ProgEnd=%d, nTracks=%d, wClocks=%d, asyncs=%d, wClock0=%d, gate0=%d, async0=%d\n", 
  TerraVMC__envData.ProgStart, TerraVMC__envData.ProgEnd, TerraVMC__envData.nTracks, TerraVMC__envData.wClocks, TerraVMC__envData.asyncs, TerraVMC__envData.wClock0, TerraVMC__envData.gate0, TerraVMC__envData.async0);
}

# 23 "BSUpload.nc"
inline static void BasicServicesP__BSUpload__setEnv(newProgVersion_t *data){
#line 23
  TerraVMC__BSUpload__setEnv(data);
#line 23
}
#line 23









inline static void BasicServicesP__BSUpload__resetMemory(void ){
#line 32
  TerraVMC__BSUpload__resetMemory();
#line 32
}
#line 32
# 1802 "TerraVMC.nc"
static inline void TerraVMC__BSUpload__stop(void )
#line 1802
{

  dbgIx("terra", "VM::BSUpload.stop()\n");
  TerraVMC__haltedFlag = TRUE;
}

# 20 "BSUpload.nc"
inline static void BasicServicesP__BSUpload__stop(void ){
#line 20
  TerraVMC__BSUpload__stop();
#line 20
}
#line 20
# 788 "BasicServicesP.nc"
static inline void BasicServicesP__procNewProgVersion(newProgVersion_t *Data)
#line 788
{
  dbgIx("terra", "BS::procNewProgVersion().\n");

  BasicServicesP__BSUpload__stop();
  BasicServicesP__BSUpload__resetMemory();
  BasicServicesP__TViewer("vmstop", 0, 0);

  __nesc_hton_uint16(BasicServicesP__ProgVersion.nxdata, __nesc_ntoh_uint16(Data->versionId.nxdata));
  __nesc_hton_uint16(BasicServicesP__ProgBlockStart.nxdata, __nesc_ntoh_uint16(Data->blockStart.nxdata));
  __nesc_hton_uint16(BasicServicesP__ProgBlockLen.nxdata, __nesc_ntoh_uint16(Data->blockLen.nxdata));

  BasicServicesP__BSUpload__setEnv(Data);
  dbgIx("terra", "BS::procNewProgVersion(). ProgVersion=%d, ProgBlockStart=%d, ProgBlockLen=%d \n", __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata), __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata), __nesc_ntoh_uint16(BasicServicesP__ProgBlockLen.nxdata));

  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 802
    BasicServicesP__BM__resetRange(__nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata), __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata) + __nesc_ntoh_uint16(BasicServicesP__ProgBlockLen.nxdata) - 1);
#line 802
    __nesc_atomic_end(__nesc_atomic); }
  {
    reqProgBlock_t xData;

    BasicServicesP__ProgTimeOutCounter = 0;
    __nesc_hton_uint8(xData.reqOper.nxdata, RO_DATA_FULL);
    BasicServicesP__ReqState = RO_DATA_FULL;
    __nesc_hton_uint8(xData.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
    __nesc_hton_uint16(xData.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
    __nesc_hton_uint16(xData.blockId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata));
    BasicServicesP__loadingProgramFlag = TRUE;
    BasicServicesP__sendReqProgBlock(&xData);

    BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
  }
}

# 58 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static inline error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__read(void *Data)
#line 58
{
  dbgIx("terra", "dataQ[%hhu]::read(). Size and FlagFree before %hhu : %s\n", 0, /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize, /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize <= 0) {
#line 61
    return FAIL;
    }
  memcpy(Data, (void *)&/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qData[/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead], sizeof(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType ));
  return SUCCESS;
}

# 11 "/home/mauricio/Terra/TerraVM/src/system/dataQueue.nc"
inline static error_t BasicServicesP__inQ__read(void *Data){
#line 11
  unsigned char __nesc_result;
#line 11

#line 11
  __nesc_result = /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__read(Data);
#line 11

#line 11
  return __nesc_result;
#line 11
}
#line 11
# 1123 "BasicServicesP.nc"
static inline void BasicServicesP__procInputEvent__runTask(void )
#line 1123
{
  {
    dbgIx("terra", "BS::procInputEvent().\n");
    if (BasicServicesP__inQ__read(&BasicServicesP__tempOutputInQ) == SUCCESS) {
        BasicServicesP__inQ__get(&BasicServicesP__tempOutputInQ);
        switch (__nesc_ntoh_uint8(BasicServicesP__tempOutputInQ.AM_ID.nxdata)) {
            case AM_NEWPROGVERSION: BasicServicesP__procNewProgVersion((newProgVersion_t *)& BasicServicesP__tempOutputInQ.Data);
#line 1129
            break;
            case AM_NEWPROGBLOCK: BasicServicesP__procNewProgBlock((newProgBlock_t *)& BasicServicesP__tempOutputInQ.Data);
#line 1130
            break;
            case AM_REQPROGBLOCK: BasicServicesP__procRecReqProgBlock((reqProgBlock_t *)& BasicServicesP__tempOutputInQ.Data);
#line 1131
            break;




            default: dbgIx("terra", "BS::procInputEvent(): Unknow AM_ID=%hhu\n", __nesc_ntoh_uint8(BasicServicesP__tempOutputInQ.AM_ID.nxdata));
#line 1136
            break;
          }
        dbgIx("terra", "BS::procInputEvent(): nextMessage.\n");
        BasicServicesP__inQ__get(&BasicServicesP__tempOutputInQ);
        BasicServicesP__procInputEvent__postTask();
      }
    else 
#line 1141
      {
        BasicServicesP__inQ__get(&BasicServicesP__tempOutputInQ);
        dbgIx("terra", "BS::procInputEvent(): inQueue is empty!\n");
      }
  }
}

#line 351
static inline uint16_t BasicServicesP__getNextEmptyBlock(void )
#line 351
{
  uint16_t i;

#line 353
  for (i = 0; i < CURRENT_MAX_BLOCKS; i++) {
      if (!BasicServicesP__BM__get(i)) {
#line 354
        return i;
        }
    }
#line 356
  return CURRENT_MAX_BLOCKS;
}

#line 900
static inline void BasicServicesP__ProgReqTimerTask__runTask(void )
#line 900
{
  uint16_t nextBlock = CURRENT_MAX_BLOCKS;
  reqProgBlock_t Data;
  uint32_t timeout = BasicServicesP__getRequestTimeout();

#line 904
  nextBlock = BasicServicesP__getNextEmptyBlock();
  dbgIx("terra", "BS::ProgReqTimer.fired(). nextBlock=%d lastRequestBlock=%d, ReqState=%d, ProgTimeOutCounter=%d\n", nextBlock, BasicServicesP__lastRequestBlock, BasicServicesP__ReqState, BasicServicesP__ProgTimeOutCounter);
  __nesc_hton_uint16(BasicServicesP__lastRecNewProgVersion.nxdata, 0);
  switch (BasicServicesP__ReqState) {
      case RO_NEW_VERSION: 
        BasicServicesP__ProgTimeOutCounter++;

      if (BasicServicesP__ProgTimeOutCounter >= 3) {
          BasicServicesP__ProgTimeOutCounter = 0;
          __nesc_hton_uint16(BasicServicesP__lastRecNewProgVersion.nxdata, 0);
          timeout = REQUEST_VERY_LONG_TIMEOUT;
        }
      __nesc_hton_uint8(Data.reqOper.nxdata, RO_NEW_VERSION);
      __nesc_hton_uint8(Data.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
      __nesc_hton_uint16(Data.versionId.nxdata, 0);
      __nesc_hton_uint16(Data.blockId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata));
      BasicServicesP__lastRequestBlock = 0;
      __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, AM_BROADCAST_ADDR);
      BasicServicesP__sendReqProgBlock(&Data);

      BasicServicesP__ProgReqTimer__startOneShot(timeout);
      break;
      case RO_DATA_FULL: 


        if (nextBlock < __nesc_ntoh_uint16(BasicServicesP__ProgBlockLen.nxdata)) {

            if (BasicServicesP__lastRequestBlock == nextBlock) {
#line 931
              BasicServicesP__ProgTimeOutCounter++;
              }
#line 932
            if (BasicServicesP__ProgTimeOutCounter <= 3) {
                BasicServicesP__lastRequestBlock = nextBlock;
                __nesc_hton_uint8(Data.reqOper.nxdata, RO_DATA_FULL);
                BasicServicesP__ReqState = RO_DATA_FULL;
                __nesc_hton_uint8(Data.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
                __nesc_hton_uint16(Data.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
                __nesc_hton_uint16(Data.blockId.nxdata, nextBlock);
                BasicServicesP__sendReqProgBlock(&Data);

                BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
              }
            else 
#line 942
              {
                BasicServicesP__ReqState = RO_NEW_VERSION;
                __nesc_hton_uint8(Data.reqOper.nxdata, RO_NEW_VERSION);
                __nesc_hton_uint8(Data.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
                __nesc_hton_uint16(Data.versionId.nxdata, 0);
                __nesc_hton_uint16(Data.blockId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgBlockStart.nxdata));
                BasicServicesP__ProgTimeOutCounter = 0;
                BasicServicesP__lastRequestBlock = 0;
                __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, AM_BROADCAST_ADDR);
                BasicServicesP__sendReqProgBlock(&Data);

                BasicServicesP__ProgReqTimer__startOneShot(timeout);
              }
          }
        else 
#line 955
          {

            if (BasicServicesP__BM__isAllBitSet()) {

                BasicServicesP__ReqState = RO_IDLE;
                BasicServicesP__TViewer("vmstart", 0, 0);
                BasicServicesP__BSUpload__start(TRUE);
              }
          }
      break;
      case RO_DATA_SINGLE: 


        if (nextBlock < CURRENT_MAX_BLOCKS) {
            __nesc_hton_uint8(Data.reqOper.nxdata, RO_DATA_SINGLE);
            BasicServicesP__ReqState = RO_DATA_SINGLE;
            __nesc_hton_uint8(Data.moteType.nxdata, BasicServicesP__TERRA_MOTE_TYPE);
            __nesc_hton_uint16(Data.versionId.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgVersion.nxdata));
            __nesc_hton_uint16(Data.blockId.nxdata, nextBlock);
            BasicServicesP__sendReqProgBlock(&Data);

            BasicServicesP__ProgReqTimer__startOneShot(BasicServicesP__getRequestTimeout());
          }
        else 
#line 977
          {

            if (BasicServicesP__BM__isAllBitSet()) {

                BasicServicesP__ReqState = RO_IDLE;
                BasicServicesP__TViewer("vmstart", 0, 0);
                BasicServicesP__BSUpload__start(TRUE);
              }
          }
      break;
    }
}

# 580 "TerraVMC.nc"
static inline int TerraVMC__ceu_go_event(int *ret, int id, uint8_t auxId, void *data)
{
  dbgIx("terra", "CEU::ceu_go_event(): halted=%s - evt slotAddr=%d, auxId=%d\n", TerraVMC__haltedFlag ? "TRUE" : "FALSE", id, auxId);

  if (TerraVMC__haltedFlag) {
#line 584
    return 0;
    }
  (&TerraVMC__CEU_)->ext_data = data;
  (&TerraVMC__CEU_)->stack = 0x01;
  TerraVMC__ceu_trigger(id, auxId);

  (&TerraVMC__CEU_)->wclk_late--;

  return TerraVMC__ceu_go(ret);
}

#line 1702
static inline void TerraVMC__update_wclk_late(void )
#line 1702
{
  u32 now = (u32 )TerraVMC__BSTimerVM__getNow();
  s32 dt = now - TerraVMC__old;

#line 1705
  dbgIx("terra", "VM::update_wclk_late(): now=%d, old=%d, dt=%d\n", now, TerraVMC__old, dt);
  TerraVMC__old = now;
  TerraVMC__ceu_go_wclock((void *)0, dt, (void *)0);
}

# 67 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
inline static error_t TerraVMC__procEvent__postTask(void ){
#line 67
  unsigned char __nesc_result;
#line 67

#line 67
  __nesc_result = SchedulerBasicP__TaskBasic__postTask(TerraVMC__procEvent);
#line 67

#line 67
  return __nesc_result;
#line 67
}
#line 67
# 298 "TerraVMC.nc"
static inline uint16_t TerraVMC__getEvtCeuId(uint8_t EvtId)
#line 298
{
  uint8_t i = 0;
  uint8_t slotSize;
  uint16_t currSlot = TerraVMC__envData.gate0;

#line 302
  slotSize = __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot + 1)).nxdata) & 0x80 ? 3 : 2;
  dbgIx("terra", "VM::getEvtCeuId(): EvtId?=%d : currSlot=%d,  slotId=%d, slotSize=%d, i=%d, inEvts=%d\n", EvtId, currSlot, __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot)).nxdata), slotSize, i, TerraVMC__envData.inEvts);

  while (EvtId != __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot)).nxdata) && i < TerraVMC__envData.inEvts) {
      i++;
      currSlot = currSlot + 1 + (__nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot + 1)).nxdata) & 0x7f) * slotSize + 1;
      slotSize = __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot + 1)).nxdata) & 0x80 ? 3 : 2;
      dbgIx("terra", "VM::getEvtCeuId(): EvtId?=%d : currSlot=%d,  slotId=%d, slotSize=%d, i=%d, inEvts=%d\n", EvtId, currSlot, __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot)).nxdata), slotSize, i, TerraVMC__envData.inEvts);
    }
  if (EvtId != __nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + currSlot)).nxdata)) {
      dbgIx("terra", "WARNING: Not found slot for event %d!\n", EvtId);
      return 0;
    }
  return currSlot + 1;
}

# 81 "/home/mauricio/Terra/TerraVM/src/interfaces/Queue.nc"
inline static TerraVMC__evtQ__t  TerraVMC__evtQ__dequeue(void ){
#line 81
  struct evtData __nesc_result;
#line 81

#line 81
  __nesc_result = /*TerraVMAppC.evtQ*/QueueC__0__Queue__dequeue();
#line 81

#line 81
  return __nesc_result;
#line 81
}
#line 81
# 57 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
static inline uint8_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__size(void )
#line 57
{
  return /*TerraVMAppC.evtQ*/QueueC__0__size;
}

# 58 "/home/mauricio/Terra/TerraVM/src/interfaces/Queue.nc"
inline static uint8_t TerraVMC__evtQ__size(void ){
#line 58
  unsigned char __nesc_result;
#line 58

#line 58
  __nesc_result = /*TerraVMAppC.evtQ*/QueueC__0__Queue__size();
#line 58

#line 58
  return __nesc_result;
#line 58
}
#line 58
# 1713 "TerraVMC.nc"
static inline void TerraVMC__procEvent__runTask(void )
#line 1713
{
  evtData_t evtData;
  uint16_t ceuId;

#line 1716
  dbgIx("terra", "VM::procEvent(): haltedFlag = %s, procFlag=%s\n", TerraVMC__haltedFlag ? "TRUE" : "FALSE", TerraVMC__procFlag ? "TRUE" : "FALSE");
  if (TerraVMC__haltedFlag == TRUE) {
      TerraVMC__evtQ__dequeue();
      return;
    }

  if (TerraVMC__evtQ__size() > 0 && TerraVMC__procFlag == FALSE) {

      dbgIx("terra", "VM::procEvent(): Dequeue an event and ...\n");
      evtData = TerraVMC__evtQ__dequeue();
      dbgIx("terra", "VM::procEvent(): ... calling ceu_go_event() for evtId=%d, auxId=%d\n", evtData.evtId, evtData.auxId);
      ceuId = TerraVMC__getEvtCeuId(evtData.evtId);
      if (ceuId == 0) {
          dbgIx("terra", "VM::procEvent(): Discarding event %d\n", evtData.evtId);
          TerraVMC__procEvent__postTask();
        }
      else 
#line 1731
        {

          TerraVMC__update_wclk_late();
          TerraVMC__ceu_go_event((void *)0, ceuId, evtData.auxId, evtData.data);
        }
    }
  dbgIx("terra", "VM::procEvent()...\n");
}

# 69 "/home/mauricio/Terra/TerraVM/src/system/TinyError.h"
static inline  error_t ecombine(error_t r1, error_t r2)




{
  return r1 == r2 ? r1 : FAIL;
}

# 109 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
static inline error_t SingleTimerMilliP__SoftwareInit__init(void )
#line 109
{


  gettimeofday(&SingleTimerMilliP__t_initial, (void *)0);
  SingleTimerMilliP__now = 0;
  SingleTimerMilliP__isRunning = TRUE;
  return SUCCESS;
}

# 55 "/home/mauricio/Terra/TerraVM/src/system/RandomMlcgC.nc"
static inline error_t RandomMlcgC__Init__init(void )
#line 55
{
  /* atomic removed: atomic calls only */
#line 56
  RandomMlcgC__seed = (uint32_t )(TOS_NODE_ID + 1);

  return SUCCESS;
}

# 62 "/home/mauricio/Terra/TerraVM/src/interfaces/Init.nc"
inline static error_t RealMainP__SoftwareInit__init(void ){
#line 62
  unsigned char __nesc_result;
#line 62

#line 62
  __nesc_result = RandomMlcgC__Init__init();
#line 62
  __nesc_result = ecombine(__nesc_result, SingleTimerMilliP__SoftwareInit__init());
#line 62

#line 62
  return __nesc_result;
#line 62
}
#line 62
# 4 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
static __inline void __nesc_enable_interrupt()
#line 4
{
}

# 195 "BasicServicesP.nc"
static inline void BasicServicesP__inicCtlData(void )
#line 195
{
  dbgIx("terra", "BS::inicCtlData().\n");

  if (BasicServicesP__firstInic) {

      __nesc_hton_uint16(BasicServicesP__ProgVersion.nxdata, 0);
      __nesc_hton_uint16(BasicServicesP__NewDataSeq.nxdata, 0);
      __nesc_hton_uint16(BasicServicesP__maxSeenDataSeq.nxdata, 0);
      __nesc_hton_uint16(BasicServicesP__NewDataMoteSource.nxdata, AM_BROADCAST_ADDR);

      __nesc_hton_uint16(BasicServicesP__ProgBlockLen.nxdata, CURRENT_MAX_BLOCKS);
      __nesc_hton_uint16(BasicServicesP__ProgMoteSource.nxdata, 0);
    }
}

# 46 "/home/mauricio/Terra/TerraVM/src/interfaces/Random.nc"
inline static uint32_t BasicServicesP__Random__rand32(void ){
#line 46
  unsigned int __nesc_result;
#line 46

#line 46
  __nesc_result = RandomMlcgC__Random__rand32();
#line 46

#line 46
  return __nesc_result;
#line 46
}
#line 46
# 215 "BasicServicesP.nc"
static inline void BasicServicesP__TOSBoot__booted(void )
#line 215
{
  uint32_t rnd = 0;

#line 217
  dbgIx("terra", "BS::TOSBoot.booted().\n");
  BasicServicesP__userRFPowerIdx = 3;




  __nesc_hton_uint16(BasicServicesP__MoteID.nxdata, TOS_NODE_ID);
  rnd = BasicServicesP__Random__rand32() & 0x0f;
  BasicServicesP__reSendDelay = RESEND_DELAY + rnd * 5;

  if (BasicServicesP__firstInic) {
      BasicServicesP__inicCtlData();



      if (BasicServicesP__RadioControl__start() != SUCCESS) {
#line 232
        dbgIx("terra", "BS::Error in RadioControl.start()\n");
        }
    }
  else 



    {
      BasicServicesP__BSBoot__booted();
    }
}

# 60 "/home/mauricio/Terra/TerraVM/src/interfaces/Boot.nc"
inline static void RealMainP__Boot__booted(void ){
#line 60
  BasicServicesP__TOSBoot__booted();
#line 60
}
#line 60
# 11 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/McuSleepC.nc"
static inline void McuSleepC__McuSleep__sleep(void )
#line 11
{

  sleep(1);
}

# 76 "/home/mauricio/Terra/TerraVM/src/interfaces/McuSleep.nc"
inline static void SchedulerBasicP__McuSleep__sleep(void ){
#line 76
  McuSleepC__McuSleep__sleep();
#line 76
}
#line 76
# 81 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
static __inline uint8_t SchedulerBasicP__popTask(void )
{
  if (SchedulerBasicP__m_head != SchedulerBasicP__NO_TASK) 
    {
      uint8_t id = SchedulerBasicP__m_head;

#line 86
      SchedulerBasicP__m_head = SchedulerBasicP__m_next[SchedulerBasicP__m_head];
      if (SchedulerBasicP__m_head == SchedulerBasicP__NO_TASK) 
        {
          SchedulerBasicP__m_tail = SchedulerBasicP__NO_TASK;
        }
      SchedulerBasicP__m_next[id] = SchedulerBasicP__NO_TASK;
      return id;
    }
  else 
    {
      return SchedulerBasicP__NO_TASK;
    }
}

#line 152
static inline void SchedulerBasicP__Scheduler__taskLoop(void )
{
  for (; ; ) 
    {
      uint8_t nextTask;

      { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
        {
          while ((nextTask = SchedulerBasicP__popTask()) == SchedulerBasicP__NO_TASK) 
            {
              SchedulerBasicP__McuSleep__sleep();
            }
        }
#line 164
        __nesc_atomic_end(__nesc_atomic); }

      androidCheckEvent();

      SchedulerBasicP__TaskBasic__runTask(nextTask);
    }
}

# 72 "/home/mauricio/Terra/TerraVM/src/interfaces/Scheduler.nc"
inline static void RealMainP__Scheduler__taskLoop(void ){
#line 72
  SchedulerBasicP__Scheduler__taskLoop();
#line 72
}
#line 72
# 5 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/hardware.h"
static __inline void __nesc_disable_interrupt()
#line 5
{
}

# 69 "/home/mauricio/Terra/TerraVM/src/system/RealMainP.nc"
  void android_main(struct android_app *state)
#line 69
{
  androidInitEvent(state);



  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
    {





      {
      }
#line 81
      ;

      RealMainP__Scheduler__init();





      RealMainP__PlatformInit__init();
      while (RealMainP__Scheduler__runNextTask()) ;





      RealMainP__SoftwareInit__init();
      while (RealMainP__Scheduler__runNextTask()) ;
    }
#line 98
    __nesc_atomic_end(__nesc_atomic); }


  __nesc_enable_interrupt();

  RealMainP__Boot__booted();


  RealMainP__Scheduler__taskLoop();





  return;
}

# 137 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
static bool SchedulerBasicP__Scheduler__runNextTask(void )
{
  uint8_t nextTask;

  /* atomic removed: atomic calls only */
#line 141
  {
    nextTask = SchedulerBasicP__popTask();
    if (nextTask == SchedulerBasicP__NO_TASK) 
      {
        {
          unsigned char __nesc_temp = 
#line 145
          FALSE;

#line 145
          return __nesc_temp;
        }
      }
  }
#line 148
  SchedulerBasicP__TaskBasic__runTask(nextTask);
  return TRUE;
}

#line 181
static void SchedulerBasicP__TaskBasic__default__runTask(uint8_t id)
{
}

# 75 "/home/mauricio/Terra/TerraVM/src/interfaces/TaskBasic.nc"
static void SchedulerBasicP__TaskBasic__runTask(uint8_t arg_0x7f7d477717d8){
#line 75
  switch (arg_0x7f7d477717d8) {
#line 75
    case TerraVMC__procEvent:
#line 75
      TerraVMC__procEvent__runTask();
#line 75
      break;
#line 75
    case BasicServicesP__ProgReqTimerTask:
#line 75
      BasicServicesP__ProgReqTimerTask__runTask();
#line 75
      break;
#line 75
    case BasicServicesP__procInputEvent:
#line 75
      BasicServicesP__procInputEvent__runTask();
#line 75
      break;
#line 75
    case BasicServicesP__forceRadioDone:
#line 75
      BasicServicesP__forceRadioDone__runTask();
#line 75
      break;
#line 75
    case BasicServicesP__sendMessage:
#line 75
      BasicServicesP__sendMessage__runTask();
#line 75
      break;
#line 75
    case BasicServicesP__sendNextMsg:
#line 75
      BasicServicesP__sendNextMsg__runTask();
#line 75
      break;
#line 75
    case UDPActiveMessageP__send_doneAck:
#line 75
      UDPActiveMessageP__send_doneAck__runTask();
#line 75
      break;
#line 75
    case UDPActiveMessageP__send_done:
#line 75
      UDPActiveMessageP__send_done__runTask();
#line 75
      break;
#line 75
    case UDPActiveMessageP__receiveTask:
#line 75
      UDPActiveMessageP__receiveTask__runTask();
#line 75
      break;
#line 75
    case UDPActiveMessageP__start_done:
#line 75
      UDPActiveMessageP__start_done__runTask();
#line 75
      break;
#line 75
    case UDPActiveMessageP__stop_done:
#line 75
      UDPActiveMessageP__stop_done__runTask();
#line 75
      break;
#line 75
    case SingleTimerMilliP__tarefaTimer:
#line 75
      SingleTimerMilliP__tarefaTimer__runTask();
#line 75
      break;
#line 75
    case /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer:
#line 75
      /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__runTask();
#line 75
      break;
#line 75
    case /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady:
#line 75
      /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__runTask();
#line 75
      break;
#line 75
    case /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady:
#line 75
      /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__runTask();
#line 75
      break;
#line 75
    case VMCustomP__BCRadio_receive:
#line 75
      VMCustomP__BCRadio_receive__runTask();
#line 75
      break;
#line 75
    default:
#line 75
      SchedulerBasicP__TaskBasic__default__runTask(arg_0x7f7d477717d8);
#line 75
      break;
#line 75
    }
#line 75
}
#line 75
# 1685 "TerraVMC.nc"
static void TerraVMC__VMCustom__queueEvt(uint8_t evtId, uint8_t auxId, void *data)
#line 1685
{
  evtData_t evtData;

#line 1687
  dbgIx("terra", "VM::VMCustom.queueEvt(): queueing evtId=%d, auxId=%d. procFlag=%s\n", evtId, auxId, TerraVMC__procFlag ? "TRUE" : "FALSE");


  evtData.evtId = evtId;
  evtData.auxId = auxId;
  evtData.data = data;
  TerraVMC__evtQ__enqueue(evtData);
  if (TerraVMC__procFlag == FALSE) {
#line 1694
    TerraVMC__procEvent__postTask();
    }
}

# 97 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
static error_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__enqueue(/*TerraVMAppC.evtQ*/QueueC__0__queue_t newVal)
#line 97
{
  if (/*TerraVMAppC.evtQ*/QueueC__0__Queue__size() < /*TerraVMAppC.evtQ*/QueueC__0__Queue__maxSize()) {
      dbgIx("QueueC", "%s: size is %hhu\n", __FUNCTION__, /*TerraVMAppC.evtQ*/QueueC__0__size);
      /*TerraVMAppC.evtQ*/QueueC__0__queue[/*TerraVMAppC.evtQ*/QueueC__0__tail] = newVal;
      /*TerraVMAppC.evtQ*/QueueC__0__tail++;
      if (/*TerraVMAppC.evtQ*/QueueC__0__tail == 6) {
#line 102
        /*TerraVMAppC.evtQ*/QueueC__0__tail = 0;
        }
#line 103
      /*TerraVMAppC.evtQ*/QueueC__0__size++;
      /*TerraVMAppC.evtQ*/QueueC__0__printQueue();
      return SUCCESS;
    }
  else {
      return FAIL;
    }
}

# 176 "/home/mauricio/Terra/TerraVM/src/system/SchedulerBasicP.nc"
static error_t SchedulerBasicP__TaskBasic__postTask(uint8_t id)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 178
    {
#line 178
      {
        unsigned char __nesc_temp = 
#line 178
        SchedulerBasicP__pushTask(id) ? SUCCESS : EBUSY;

        {
#line 178
          __nesc_atomic_end(__nesc_atomic); 
#line 178
          return __nesc_temp;
        }
      }
    }
#line 181
    __nesc_atomic_end(__nesc_atomic); }
}

# 144 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__startTimer(uint8_t num, uint32_t t0, uint32_t dt, bool isoneshot)
{
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer_t *timer = &/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num];

#line 147
  timer->t0 = t0;
  timer->dt = dt;
  timer->isoneshot = isoneshot;
  timer->isrunning = TRUE;
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__postTask();
}

# 79 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/SingleTimerMilliP.nc"
static uint32_t SingleTimerMilliP__TimerFrom__getNow(void )
#line 79
{
  uint32_t result;


  gettimeofday(&SingleTimerMilliP__t_current, (void *)0);

  result = SingleTimerMilliP__t_current.tv_sec * 1000 - SingleTimerMilliP__t_initial.tv_sec * 1000;
  result += SingleTimerMilliP__t_current.tv_usec / 1000 - SingleTimerMilliP__t_initial.tv_usec / 1000;

  SingleTimerMilliP__now += result;





  SingleTimerMilliP__t_initial.tv_sec = SingleTimerMilliP__t_current.tv_sec;
  SingleTimerMilliP__t_initial.tv_usec = SingleTimerMilliP__t_current.tv_usec;



  return SingleTimerMilliP__now;
}

# 73 "/home/mauricio/Terra/TerraVM/src/system/VirtualizeTimerC.nc"
static void /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__fireTimers(uint32_t now)
{
  uint16_t num;

  for (num = 0; num < /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__NUM_TIMERS; num++) 
    {
      /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer_t *timer = &/*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__m_timers[num];

      if (timer->isrunning) 
        {
          uint32_t elapsed = now - timer->t0;

          if (elapsed >= timer->dt) 
            {
              if (timer->isoneshot) {
                timer->isrunning = FALSE;
                }
              else {
#line 90
                timer->t0 += timer->dt;
                }
              /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__Timer__fired(num);
              break;
            }
        }
    }
  /*HilTimerMilliC.VirtualizeTimerC*/VirtualizeTimerC__0__updateFromTimer__postTask();
}

# 84 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__get(uint16_t bitnum)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 86
    {
      dbgIx("terra", "VM::BitVector.get(): bitnum=%d, bits=%0x, ARRAY_SIZE=%d\n", bitnum, (uint8_t )/*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[/*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(bitnum)], /*BasicServicesC.Bitmap*/vmBitVectorC__0__ARRAY_SIZE);
      {
        unsigned char __nesc_temp = 
#line 88
        /*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[/*BasicServicesC.Bitmap*/vmBitVectorC__0__getIndex(bitnum)] & /*BasicServicesC.Bitmap*/vmBitVectorC__0__getMask(bitnum) ? TRUE : FALSE;

        {
#line 88
          __nesc_atomic_end(__nesc_atomic); 
#line 88
          return __nesc_temp;
        }
      }
    }
#line 91
    __nesc_atomic_end(__nesc_atomic); }
}

# 1419 "BasicServicesP.nc"
static void BasicServicesP__sendNewProgBlock(newProgBlock_t *Data)
#line 1419
{
  dbgIx("terra", "BS::sendNewProgBlock(): insert in outQueue\n");
  memcpy(& BasicServicesP__tempInputOutQ.Data, Data, sizeof(newProgBlock_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.AM_ID.nxdata, AM_NEWPROGBLOCK);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.DataSize.nxdata, sizeof(newProgBlock_t ));
  __nesc_hton_uint16(BasicServicesP__tempInputOutQ.sendToMote.nxdata, AM_BROADCAST_ADDR);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.reqAck.nxdata, 0);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.fromSerial.nxdata, FALSE);
  if (BasicServicesP__outQ__put(&BasicServicesP__tempInputOutQ) != SUCCESS) {
      dbgIx("terra", "BS::sendNewProgBlock(): outQueue is full! Losting a message.\n");
    }
}

# 19 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__put(void *Data)
#line 19
{
  dbgIx("terra", "dataQ[%hhu]::put(). Size and FlagFree before %hhu : %s\n", 1, /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize, /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize >= 10) {
      return FAIL;
    }

  memcpy((void *)&/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qData[/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qTail], Data, sizeof(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType ));
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qTail++;
#line 27
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qTail = (uint8_t )(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qTail % 10);
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize++;
  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ == TRUE) {
      /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ = FALSE;
#line 30
      /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataReady__postTask();
    }
  return SUCCESS;
}

# 331 "BasicServicesP.nc"
static void BasicServicesP__BSTimerAsync__startOneShot(uint32_t dt)
#line 331
{
  dbgIx("terra", "BS::BSTimerAsync.startOneShot() dt=%ld, getdt=%ld, isRunning=%s\n", dt, BasicServicesP__TimerAsync__getdt(), BasicServicesP__TimerAsync__isRunning() ? "TRUE" : "FALSE");
  if (BasicServicesP__TimerAsync__isRunning()) {
#line 333
    BasicServicesP__TimerAsync__stop();
    }
#line 334
  BasicServicesP__TimerAsync__startOneShot(dt);
}

# 415 "TerraVMC.nc"
static void TerraVMC__ceu_track_ins(u8 stack, u8 tree, int chk, uint16_t lbl)
{
  dbgIx("terra", "CEU::ceu_track_ins():: track_n=%d, stack=%d tree=%d chk=%d lbl=%d\n", (&TerraVMC__CEU_)->tracks_n, stack, tree, chk, lbl);
  {
#line 418
    int i;

#line 419
    if (chk) {
        for (i = 1; i <= (&TerraVMC__CEU_)->tracks_n; i++) {
            if (lbl == __nesc_ntoh_uint16(((&TerraVMC__CEU_)->p_tracks + i)->lbl.nxdata)) {
                return;
              }
          }
      }
  }

  {
    int i;

    TerraVMC__tceu_trk trk;

#line 432
    __nesc_hton_uint8(trk.stack.nxdata, stack);
    __nesc_hton_uint8(trk.tree.nxdata, tree);
    __nesc_hton_uint16(trk.lbl.nxdata, lbl);

    for (i = ++ (&TerraVMC__CEU_)->tracks_n; 
    i > 1 && TerraVMC__ceu_track_cmp(&trk, (&TerraVMC__CEU_)->p_tracks + i / 2); 
    i /= 2) {

        memcpy((&TerraVMC__CEU_)->p_tracks + i, (&TerraVMC__CEU_)->p_tracks + i / 2, sizeof(TerraVMC__tceu_trk ));
      }


    * (TerraVMC__tceu_trk *)((&TerraVMC__CEU_)->p_tracks + i) = trk;
  }
}

#line 401
static int TerraVMC__ceu_track_cmp(TerraVMC__tceu_trk *trk1, TerraVMC__tceu_trk *trk2)
#line 401
{
  dbgIx("terra", "CEU::ceu_track_cmp():: trk1->lbl=%d,stack=%d trk2->lbl=%d,stack=%d -- CEU->stack=%d\n", __nesc_ntoh_uint16(trk1->lbl.nxdata), __nesc_ntoh_uint8(trk1->stack.nxdata), __nesc_ntoh_uint16(trk2->lbl.nxdata), __nesc_ntoh_uint8(trk2->stack.nxdata), (&TerraVMC__CEU_)->stack);

  if (__nesc_ntoh_uint8(trk1->stack.nxdata) != __nesc_ntoh_uint8(trk2->stack.nxdata)) {
      if (__nesc_ntoh_uint8(trk1->stack.nxdata) == (&TerraVMC__CEU_)->stack) {
        return 1;
        }
#line 407
      if (__nesc_ntoh_uint8(trk2->stack.nxdata) == (&TerraVMC__CEU_)->stack) {
        return 0;
        }
#line 409
      return __nesc_ntoh_uint8(trk1->stack.nxdata) > __nesc_ntoh_uint8(trk2->stack.nxdata);
    }
  return __nesc_ntoh_uint8(trk1->tree.nxdata) > __nesc_ntoh_uint8(trk2->tree.nxdata);
}

#line 711
static int TerraVMC__ceu_go(int *ret)
{
  uint8_t nextTrk;
  TerraVMC__tceu_trk trk;
  uint16_t _lbl_;

  dbgIx("terra", "CEU::ceu_go():\n");
  TerraVMC__procFlag = TRUE;
  (&TerraVMC__CEU_)->stack = 0x01;

  nextTrk = TerraVMC__ceu_track_rem(&trk, 1);
  while (nextTrk) 
    {
      if (__nesc_ntoh_uint8(trk.stack.nxdata) != (&TerraVMC__CEU_)->stack) {
          (&TerraVMC__CEU_)->stack = __nesc_ntoh_uint8(trk.stack.nxdata);
        }
      if (__nesc_ntoh_uint16(trk.lbl.nxdata) == TerraVMC__Inactive) {
        continue;
        }
      _lbl_ = __nesc_ntoh_uint16(trk.lbl.nxdata);
      dbgIx("terra", "CEU::ceu_go(): trk.lbl=%d, _lbl_=%d \n", __nesc_ntoh_uint16(trk.lbl.nxdata), _lbl_);

      TerraVMC__execTrail(_lbl_);

      nextTrk = TerraVMC__ceu_track_rem(&trk, 1);
    }
  TerraVMC__procFlag = FALSE;
  TerraVMC__procEvent__postTask();
  return 0;
}

#line 450
static int TerraVMC__ceu_track_rem(TerraVMC__tceu_trk *trk, u8 N)
{
  dbgIx("terra", "CEU::ceu_track_rem: track_n=%d\n", (&TerraVMC__CEU_)->tracks_n);
  if ((&TerraVMC__CEU_)->tracks_n == 0) {
    return 0;
    }
  {
#line 456
    int i;
#line 456
    int cur;
    TerraVMC__tceu_trk *last;

    if (trk) {
      memcpy(trk, (&TerraVMC__CEU_)->p_tracks + N, sizeof(TerraVMC__tceu_trk ));
      }
    last = (&TerraVMC__CEU_)->p_tracks + (&TerraVMC__CEU_)->tracks_n--;

    for (i = N; i * 2 <= (&TerraVMC__CEU_)->tracks_n; i = cur) 
      {
        cur = i * 2;
        if (cur != (&TerraVMC__CEU_)->tracks_n && 
        TerraVMC__ceu_track_cmp((&TerraVMC__CEU_)->p_tracks + (cur + 1), (&TerraVMC__CEU_)->p_tracks + cur)) {
          cur++;
          }
        if (TerraVMC__ceu_track_cmp((&TerraVMC__CEU_)->p_tracks + cur, last)) {
          memcpy((&TerraVMC__CEU_)->p_tracks + i, (&TerraVMC__CEU_)->p_tracks + cur, sizeof(TerraVMC__tceu_trk ));
          }
        else {
#line 474
          break;
          }
      }
#line 476
    memcpy((&TerraVMC__CEU_)->p_tracks + i, last, sizeof(TerraVMC__tceu_trk ));
    return 1;
  }
}

#line 97
static uint8_t TerraVMC__getOpCode(uint8_t *Opcode, uint8_t *Modifier)
#line 97
{
  uint8_t i;

#line 99
  *Opcode = (uint8_t )__nesc_ntoh_uint8(TerraVMC__CEU_data[TerraVMC__PC].nxdata);
  *Modifier = (uint8_t )__nesc_ntoh_uint8(TerraVMC__CEU_data[TerraVMC__PC].nxdata);
  dbgIx("terra", "VM::getOpCode(): CEU_data[%d]=%d (0x%02x)  %s \n", TerraVMC__PC, *Opcode, *Opcode, *Opcode == op_end ? "--> f_end" : "");
  TerraVMC__PC++;
  for (i = 0; i < 6; i++) {
      if (*Opcode >= IS_RangeMask[i][0] && *Opcode <= IS_RangeMask[i][1]) {
          *Modifier = (uint8_t )(*Opcode & IS_RangeMask[i][2]);
          *Opcode = (uint8_t )(*Opcode & ~IS_RangeMask[i][2]);
          break;
        }
    }
  return *Opcode;
}

#line 239
static uint32_t TerraVMC__getMVal(uint16_t Maddr, uint8_t type)
#line 239
{
  switch (type) {
      case U8: return (uint32_t )__nesc_ntoh_uint8((* (nx_uint8_t *)(TerraVMC__MEM + Maddr)).nxdata);
      case U16: return (uint32_t )__nesc_ntoh_uint16((* (nx_uint16_t *)(TerraVMC__MEM + Maddr)).nxdata);
      case U32: return (uint32_t )__nesc_ntoh_uint32((* (nx_uint32_t *)(TerraVMC__MEM + Maddr)).nxdata);
      case S8: return (uint32_t )__nesc_ntoh_int8((* (nx_int8_t *)(TerraVMC__MEM + Maddr)).nxdata);
      case S16: return (uint32_t )__nesc_ntoh_int16((* (nx_int16_t *)(TerraVMC__MEM + Maddr)).nxdata);
      case S32: return (uint32_t )__nesc_ntoh_int32((* (nx_int32_t *)(TerraVMC__MEM + Maddr)).nxdata);
    }
  dbgIx("terra", "ERROR VM::getMVal(): Invalid type=%d\n", type);
  return 0;
}

#line 230
static uint32_t TerraVMC__pop(void )
#line 230
{
  TerraVMC__currStack = TerraVMC__currStack + 4;
  return __nesc_ntoh_uint32((* (nx_uint32_t *)(TerraVMC__CEU_data + TerraVMC__currStack - 4)).nxdata);
}

#line 203
static void TerraVMC__push(uint32_t value)
#line 203
{
  TerraVMC__currStack = TerraVMC__currStack - 4;
  dbgIx("terra", "VM::push(): newStack=%d, value=%d (0x%04x), ProgEnd=%d\n", TerraVMC__currStack, value, value, TerraVMC__envData.ProgEnd);
  if (TerraVMC__currStack > TerraVMC__envData.ProgEnd) {
    __nesc_hton_uint32((* (nx_uint32_t *)(TerraVMC__CEU_data + TerraVMC__currStack)).nxdata, value);
    }
  else 
#line 208
    {
      TerraVMC__evtError(E_STKOVF);

      dbgIx("terra", "VM::push(): Stack Overflow - VM execution stopped\n");
      TerraVMC__haltedFlag = TRUE;
      TerraVMC__VMCustom__reset();
    }
}

#line 130
static void TerraVMC__evtError(uint8_t ecode)
#line 130
{
  evtData_t evtData;

#line 132
  dbgIx("terra", "ERROR VM::evtError: error code=%d\n", ecode);

  __nesc_hton_uint8(TerraVMC__ExtDataSysError.nxdata, ecode);
  evtData.evtId = I_ERROR_ID;
  evtData.auxId = ecode;
  evtData.data = &TerraVMC__ExtDataSysError;
  TerraVMC__evtQ__enqueue(evtData);
  evtData.evtId = I_ERROR;
  evtData.auxId = 0;
  TerraVMC__evtQ__enqueue(evtData);
  if (TerraVMC__procFlag == FALSE) {
#line 142
    TerraVMC__procEvent__postTask();
    }
#line 143
  TerraVMC__TViewer("error", ecode, 0);
}

#line 234
static float TerraVMC__popf(void )
#line 234
{
  TerraVMC__currStack = TerraVMC__currStack + 4;
  return __nesc_ntoh_afloat((* (nx_float *)(TerraVMC__CEU_data + TerraVMC__currStack - 4)).nxdata);
}

#line 216
static void TerraVMC__pushf(float value)
#line 216
{
  TerraVMC__currStack = TerraVMC__currStack - 4;

  if (TerraVMC__currStack > TerraVMC__envData.ProgEnd) {
      __nesc_hton_afloat((* (nx_float *)(TerraVMC__CEU_data + TerraVMC__currStack)).nxdata, value);
    }
  else 
#line 221
    {
      TerraVMC__evtError(E_STKOVF);

      dbgIx("terra", "VM::pushf(): Stack Overflow - VM execution stopped\n");
      TerraVMC__haltedFlag = TRUE;
      TerraVMC__VMCustom__reset();
    }
}

#line 149
static uint8_t TerraVMC__getPar8(uint8_t p_len)
#line 149
{
  uint8_t temp = (uint8_t )__nesc_ntoh_uint8(TerraVMC__CEU_data[TerraVMC__PC].nxdata);

#line 151
  TerraVMC__PC++;
  dbgIx("terra", "VM::getPar8: PC=%d, p_len=%d, value=%d\n", TerraVMC__PC - 1, p_len, temp);
  return temp;
}

# 69 "/home/mauricio/Terra/TerraVM/src/system/RandomMlcgC.nc"
static uint32_t RandomMlcgC__Random__rand32(void )
#line 69
{
  uint32_t mlcg;
#line 70
  uint32_t p;
#line 70
  uint32_t q;
  uint64_t tmpseed;

#line 72
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
    {
      tmpseed = (uint64_t )33614U * (uint64_t )RandomMlcgC__seed;
      q = tmpseed;
      q = q >> 1;
      p = tmpseed >> 32;
      mlcg = p + q;
      if (mlcg & 0x80000000) {
          mlcg = mlcg & 0x7FFFFFFF;
          mlcg++;
        }
      RandomMlcgC__seed = mlcg;
    }
#line 84
    __nesc_atomic_end(__nesc_atomic); }
  return mlcg;
}

# 155 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static void VMCustomP__VM__procOutEvt(uint8_t id, uint32_t value)
#line 155
{
  dbgIx("terra", "Custom::procOutEvt(): id=%d\n", id);
  switch (id) {

      case O_SEND: VMCustomP__proc_send(id, value);
#line 159
      break;
      case O_SEND_ACK: VMCustomP__proc_send_ack(id, value);
#line 160
      break;
      case O_CUSTOM_A: VMCustomP__proc_req_custom_a(id, value);
#line 161
      break;
      case O_CUSTOM: VMCustomP__proc_req_custom(id, value);
#line 162
      break;
      case O_SCREENCOLOR: VMCustomP__proc_req_screencolor(id, value);
#line 163
      break;
    }
}

#line 42
static void VMCustomP__proc_send_x(uint16_t id, uint16_t addr, uint8_t ack)
#line 42
{
  usrMsg_t *usrMsg;
  uint8_t reqRetryAck;

#line 45
  usrMsg = (usrMsg_t *)VMCustomP__VM__getRealAddr(addr);
  dbgIx("terra", "Custom::proc_sendx(): id=%d, target=%d, addr=%d, realAddr=%x, ack=%d\n", 
  id, __nesc_ntoh_uint16(usrMsg->target.nxdata), addr, usrMsg, ack);
  reqRetryAck = ack ? 1 << REQ_ACK_BIT : 0;
  VMCustomP__BSRadio__send(AM_USRMSG, __nesc_ntoh_uint16(usrMsg->target.nxdata), usrMsg, sizeof(usrMsg_t ), reqRetryAck);
}

# 1747 "TerraVMC.nc"
static void *TerraVMC__VMCustom__getRealAddr(uint16_t Maddr)
#line 1747
{
  dbgIx("terra", "VM::VMCustom.getRealAddr(): Maddr=%d,RealMEM=%x\n", Maddr, TerraVMC__MEM + Maddr);
  return TerraVMC__MEM + Maddr;
}

#line 184
static uint8_t TerraVMC__getBits(uint8_t data, uint8_t stBit, uint8_t endBit)
#line 184
{
  uint8_t ret = 0;
  uint8_t pos;

#line 187
  for (pos = stBit; pos <= endBit; pos++) ret += (data & (1 << pos)) == 0 ? 0 : 1 << (pos - stBit);
  return ret;
}

#line 155
static uint16_t TerraVMC__getPar16(uint8_t p_len)
#line 155
{
  uint16_t temp = 0;
#line 156
  uint16_t temp2;
  uint8_t idx;

#line 158
  for (idx = 0; idx < p_len; idx++) {

      if (idx < sizeof(uint16_t )) {
          temp2 = (uint8_t )__nesc_ntoh_uint8(TerraVMC__CEU_data[TerraVMC__PC].nxdata);
          temp = temp + (temp2 << (p_len - 1 - idx) * 8);
        }
      TerraVMC__PC++;
    }
  dbgIx("terra", "VM::getPar16: PC=%d, p_len=%d, value=%d\n", TerraVMC__PC - idx, p_len, temp);
  return temp;
}

#line 193
static uint32_t TerraVMC__unit2val(uint32_t val, uint8_t unit)
#line 193
{
  switch (unit) {
      case 0: return (uint32_t )val;
      case 1: return (uint32_t )(val * 1000L);
      case 2: return (uint32_t )(val * 60L * 1000L);
      case 3: return (uint32_t )(val * 60L * 60L * 1000L);
    }
  return val;
}

#line 541
static void TerraVMC__ceu_wclock_enable(int gte, s32 us, uint16_t lbl)
#line 541
{
  TerraVMC__tceu_wclock *tmr = (TerraVMC__tceu_wclock *)(TerraVMC__MEM + TerraVMC__envData.wClock0 + gte * sizeof(TerraVMC__tceu_wclock ));
  s32 dt = us - (&TerraVMC__CEU_)->wclk_late;

  dt = dt < 0 ? 0 : dt;

  dbgIx("terra", "CEU::ceu_wclock_enable(): gate=%d, time=%d, lbl=%d, dt=%ld, wClock0=%d\n", gte, us, lbl, dt, TerraVMC__envData.wClock0);
  __nesc_hton_int32(tmr->togo.nxdata, dt);
  __nesc_hton_uint16((* (nx_uint16_t *)& tmr->lbl).nxdata, lbl);

  if (TerraVMC__ceu_wclock_lt(tmr)) {
      TerraVMC__ceu_out_wclock(dt);
    }
}

#line 530
static int TerraVMC__ceu_wclock_lt(TerraVMC__tceu_wclock *tmr)
#line 530
{
  dbgIx("terra", "CEU::ceu_wclock_lt(): wclk_cur=%ld, togo=%d, cur.togo=%d\n", (&TerraVMC__CEU_)->wclk_cur ? __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) : 0, (unsigned int )__nesc_ntoh_int32(tmr->togo.nxdata), (&TerraVMC__CEU_)->wclk_cur ? (unsigned int )__nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) : 5555);

  if ((! (&TerraVMC__CEU_)->wclk_cur || (! (&TerraVMC__CEU_)->wclk_cur || __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) == 0)) || (! (&TerraVMC__CEU_)->wclk_cur || __nesc_ntoh_int32(tmr->togo.nxdata) < __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata))) {
      (&TerraVMC__CEU_)->wclk_cur = tmr;
      return 1;
    }
  return 0;
}

# 315 "BasicServicesP.nc"
static void BasicServicesP__BSTimerVM__startOneShot(uint32_t dt)
#line 315
{
  dbgIx("terra", "BS::BSTimerVM.startOneShot() dt=%ld, getdt=%ld, isRunning=%s\n", dt, BasicServicesP__TimerVM__getdt(), BasicServicesP__TimerVM__isRunning() ? "TRUE" : "FALSE");
  if (BasicServicesP__TimerVM__isRunning()) {
#line 317
    BasicServicesP__TimerVM__stop();
    }
#line 318
  BasicServicesP__TimerVM__startOneShot(dt);
}

# 169 "TerraVMC.nc"
static uint32_t TerraVMC__getPar32(uint8_t p_len)
#line 169
{
  uint32_t temp = 0L;
#line 170
  uint32_t temp2;
  uint8_t idx;

#line 172
  for (idx = 0; idx < p_len; idx++) {

      if (idx < sizeof(uint32_t )) {
          temp2 = (uint8_t )__nesc_ntoh_uint8(TerraVMC__CEU_data[TerraVMC__PC].nxdata);
          temp = temp + (temp2 << (p_len - 1 - idx) * 8);
        }
      TerraVMC__PC++;
    }
  dbgIx("terra", "VM::getPar32: PC=%d, p_len=%d, value=%d\n", TerraVMC__PC - idx, p_len, temp);
  return temp;
}

#line 255
static void TerraVMC__setMVal(uint32_t buffer, uint16_t Maddr, uint8_t fromTp, uint8_t toTp)
#line 255
{
  if (fromTp == F32) {
      float value = * (float *)&buffer;

#line 258
      switch (toTp) {
          case U8: __nesc_hton_uint8((* (nx_uint8_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint8_t )value);
#line 259
          return;
          case U16: __nesc_hton_uint16((* (nx_uint16_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint16_t )value);
#line 260
          return;
          case U32: __nesc_hton_uint32((* (nx_uint32_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint32_t )value);
#line 261
          return;
          case F32: __nesc_hton_afloat((* (nx_float *)(TerraVMC__MEM + Maddr)).nxdata, (float )value);
          case S8: __nesc_hton_int8((* (nx_int8_t *)(TerraVMC__MEM + Maddr)).nxdata, (int8_t )value);
#line 263
          return;
          case S16: __nesc_hton_int16((* (nx_int16_t *)(TerraVMC__MEM + Maddr)).nxdata, (int16_t )value);
#line 264
          return;
          case S32: __nesc_hton_int32((* (nx_int32_t *)(TerraVMC__MEM + Maddr)).nxdata, (int32_t )value);
#line 265
          return;
        }
    }
  else 
#line 267
    {
      if (fromTp <= F32) {
          uint32_t value = * (uint32_t *)&buffer;

#line 270
          switch (toTp) {
              case U8: __nesc_hton_uint8((* (nx_uint8_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint8_t )value);
#line 271
              return;
              case U16: __nesc_hton_uint16((* (nx_uint16_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint16_t )value);
#line 272
              return;
              case U32: __nesc_hton_uint32((* (nx_uint32_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint32_t )value);
#line 273
              return;
              case F32: __nesc_hton_afloat((* (nx_float *)(TerraVMC__MEM + Maddr)).nxdata, (float )value);
              case S8: __nesc_hton_int8((* (nx_int8_t *)(TerraVMC__MEM + Maddr)).nxdata, (int8_t )value);
#line 275
              return;
              case S16: __nesc_hton_int16((* (nx_int16_t *)(TerraVMC__MEM + Maddr)).nxdata, (int16_t )value);
#line 276
              return;
              case S32: __nesc_hton_int32((* (nx_int32_t *)(TerraVMC__MEM + Maddr)).nxdata, (int32_t )value);
#line 277
              return;
            }
        }
      else 
#line 279
        {
          int32_t value = * (int32_t *)&buffer;

#line 281
          switch (toTp) {
              case U8: __nesc_hton_uint8((* (nx_uint8_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint8_t )value);
#line 282
              return;
              case U16: __nesc_hton_uint16((* (nx_uint16_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint16_t )value);
#line 283
              return;
              case U32: __nesc_hton_uint32((* (nx_uint32_t *)(TerraVMC__MEM + Maddr)).nxdata, (uint32_t )value);
#line 284
              return;
              case F32: __nesc_hton_afloat((* (nx_float *)(TerraVMC__MEM + Maddr)).nxdata, (float )value);
              case S8: __nesc_hton_int8((* (nx_int8_t *)(TerraVMC__MEM + Maddr)).nxdata, (int8_t )value);
#line 286
              return;
              case S16: __nesc_hton_int16((* (nx_int16_t *)(TerraVMC__MEM + Maddr)).nxdata, (int16_t )value);
#line 287
              return;
              case S32: __nesc_hton_int32((* (nx_int32_t *)(TerraVMC__MEM + Maddr)).nxdata, (int32_t )value);
#line 288
              return;
            }
        }
    }
  dbgIx("terra", "ERROR VM::setMVal(): Invalid fromTp=%d, toTp=%d\n", fromTp, toTp);
}

#line 499
static void TerraVMC__ceu_trigger(uint16_t off, uint8_t auxId)
{
  int i;
  uint8_t slotSize;
#line 502
  uint8_t slotAuxId;

  int n = * (char *)((&TerraVMC__CEU_)->p_mem + off) & 0x7f;

  slotSize = * (char *)((&TerraVMC__CEU_)->p_mem + off) & 0x80 ? 3 : 2;
  dbgIx("terra", "CEU::ceu_trigger(): evtId=%d, auxId=%d, slotSize=%d, gate addr=%d, nGates=%d\n", * (char *)((&TerraVMC__CEU_)->p_mem + off - 1), auxId, slotSize, off, n);
  for (i = 0; i < n; i++) {

      if (slotSize == 2) {
          TerraVMC__ceu_spawn((nx_uint16_t *)((&TerraVMC__CEU_)->p_mem + off + 1 + i * slotSize));
        }
      else 
#line 512
        {
          slotAuxId = * (char *)((&TerraVMC__CEU_)->p_mem + off + 1 + i * slotSize);
          dbgIx("terra", "CEU::ceu_trigger(): testauxId -> slotAuxId=%d, auxId=%d\n", slotAuxId, auxId);
          if (slotAuxId == auxId) {
              TerraVMC__ceu_spawn((nx_uint16_t *)((&TerraVMC__CEU_)->p_mem + off + 2 + i * slotSize));
            }
        }
    }
}

#line 491
static void TerraVMC__ceu_spawn(nx_uint16_t *lbl)
{
  if (__nesc_ntoh_uint16((* (nx_uint16_t *)lbl).nxdata) != TerraVMC__Inactive) {
      TerraVMC__ceu_track_ins((&TerraVMC__CEU_)->stack, 0xFF, 0, __nesc_ntoh_uint16((*lbl).nxdata));
      __nesc_hton_uint16((* (nx_uint16_t *)lbl).nxdata, TerraVMC__Inactive);
    }
}

#line 632
static int TerraVMC__ceu_go_wclock(int *ret, s32 dt, s32 *nxt)
{
  unsigned char *__nesc_temp42;
#line 634
  int i;
  s32 min_togo = 0x7FFFFFFF;
  TerraVMC__tceu_wclock *CLK0 = (TerraVMC__tceu_wclock *)((&TerraVMC__CEU_)->p_mem + TerraVMC__envData.wClock0);

  (&TerraVMC__CEU_)->stack = 0x01;

  if (! (&TerraVMC__CEU_)->wclk_cur) {
      if (nxt) {
#line 641
        *nxt = 0x7FFFFFFF;
        }
      TerraVMC__ceu_out_wclock(0x7FFFFFFF);
      return 0;
    }
  if (__nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) <= dt) {
      min_togo = __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata);
      (&TerraVMC__CEU_)->wclk_late = dt - __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata);
    }




  (&TerraVMC__CEU_)->wclk_cur = (void *)0;
  for (i = 0; i < TerraVMC__envData.wClocks; i++) 
    {
      TerraVMC__tceu_wclock *tmr = &CLK0[i];

#line 658
      dbgIx("terra", "CEU::ceu_go_wclock(): Loop1 nos wClocks: tmr->togo=%d, tmr->lbl=%d\n", (unsigned int )__nesc_ntoh_int32(tmr->togo.nxdata), __nesc_ntoh_uint16(tmr->lbl.nxdata));
      if (__nesc_ntoh_uint16(tmr->lbl.nxdata) == TerraVMC__Inactive) {
        continue;
        }
      if (__nesc_ntoh_int32(tmr->togo.nxdata) == min_togo) {
          __nesc_hton_int32(tmr->togo.nxdata, 0L);
          dbgIx("VMDBG", "VM:: timer fired for label %d\n", __nesc_ntoh_uint16(tmr->lbl.nxdata));
          TerraVMC__ceu_spawn(& tmr->lbl);
        }
      else 
#line 666
        {
          (__nesc_temp42 = tmr->togo.nxdata, __nesc_hton_int32(__nesc_temp42, __nesc_ntoh_int32(__nesc_temp42) - dt));
          if (__nesc_ntoh_int32(tmr->togo.nxdata) < 0) {
              __nesc_hton_int32(tmr->togo.nxdata, 0L);
              TerraVMC__ceu_spawn(& tmr->lbl);
            }
          else {
#line 672
            TerraVMC__ceu_wclock_lt(tmr);
            }
        }
    }


  {
#line 678
    int s = TerraVMC__ceu_go(ret);

#line 679
    if (nxt) {
      *nxt = (&TerraVMC__CEU_)->wclk_cur ? __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) : 0x7FFFFFFF;
      }
#line 681
    (&TerraVMC__CEU_)->wclk_late = 0;
    TerraVMC__ceu_out_wclock((&TerraVMC__CEU_)->wclk_cur ? __nesc_ntoh_int32((&TerraVMC__CEU_)->wclk_cur->togo.nxdata) : 0x7FFFFFFF);

    return s;
  }
}

# 1306 "BasicServicesP.nc"
static void BasicServicesP__RadioSender_sendDone(am_id_t id, message_t *msg, error_t error)
#line 1306
{
  bool doneStatus;
#line 1307
  bool reqAck;


  if (id > AM_RESERVED_END) {
      BasicServicesP__outQ__read(&BasicServicesP__tempOutputOutQ);
      doneStatus = error == SUCCESS;
      reqAck = (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.reqAck.nxdata) & (1 << REQ_ACK_BIT)) > 0;

      if (doneStatus && reqAck) {
#line 1315
        doneStatus = (uint8_t )BasicServicesP__RadioAck__wasAcked(msg);
        }
#line 1316
      if (doneStatus) {
          dbgIx("terra", "BS::sendDone(): SUCCESS SendCounter=%hhu\n", BasicServicesP__sendCounter);
          BasicServicesP__outQ__get(&BasicServicesP__tempOutputOutQ);
          BasicServicesP__sendCounter = 0;
          BasicServicesP__sendTimer__startOneShot(BasicServicesP__reSendDelay);
          if (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) >= AM_CUSTOM_START && __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) <= AM_CUSTOM_END) {
              dbgIx("terra", "BS::sendDone(): UsrMsg err=%d ack=%d, \n", error, BasicServicesP__RadioAck__wasAcked(msg));
              if (reqAck == TRUE) {
                BasicServicesP__BSRadio__sendDoneAck(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), msg, BasicServicesP__tempOutputOutQ.Data, error, BasicServicesP__RadioAck__wasAcked(msg));
                }
              else {
#line 1326
                BasicServicesP__BSRadio__sendDone(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), msg, BasicServicesP__tempOutputOutQ.Data, error);
                }
            }
        }
      else 
#line 1328
        {
          dbgIx("terra", "BS::sendDone(): FAIL\n");
          if (BasicServicesP__sendCounter < MAX_SEND_RETRIES) {
              dbgIx("terra", "BS::sendDone(): FAIL-Retry SendCounter=%hhu\n", BasicServicesP__sendCounter);
              BasicServicesP__sendTimer__startOneShot(BasicServicesP__reSendDelay);
            }
          else 
#line 1333
            {
              dbgIx("terra", "BS::sendDone(): FAIL-Discard SendCounter=%hhu\n", BasicServicesP__sendCounter);
              BasicServicesP__outQ__get(&BasicServicesP__tempOutputOutQ);
              BasicServicesP__sendCounter = 0;
              BasicServicesP__sendTimer__startOneShot(BasicServicesP__reSendDelay);
              if (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) >= AM_CUSTOM_START && __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata) <= AM_CUSTOM_END) {
                  dbgIx("terra", "BS::sendDone(): FAIL-UsrMsg err=%d ack=%d, \n", error, BasicServicesP__RadioAck__wasAcked(msg));
                  if (reqAck == TRUE) {
                    BasicServicesP__BSRadio__sendDoneAck(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), msg, BasicServicesP__tempOutputOutQ.Data, error, FALSE);
                    }
                  else {
                    BasicServicesP__BSRadio__sendDone(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), msg, BasicServicesP__tempOutputOutQ.Data, error);
                    }
                }
            }
        }
    }
}

# 58 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__read(void *Data)
#line 58
{
  dbgIx("terra", "dataQ[%hhu]::read(). Size and FlagFree before %hhu : %s\n", 1, /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize, /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize <= 0) {
#line 61
    return FAIL;
    }
  memcpy(Data, (void *)&/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qData[/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead], sizeof(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType ));
  return SUCCESS;
}

# 426 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static bool UDPActiveMessageP__PacketAcknowledgements__wasAcked(message_t *msg)
#line 426
{

  return __nesc_ntoh_uint16(UDPActiveMessageP__getMetadata(msg)->ackID.nxdata) == 1;
}

# 35 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static error_t /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataQueue__get(void *Data)
#line 35
{
  dbgIx("terra", "dataQ[%hhu]::get(%x[%d]). Size and FlagFree before %hhu : %s\n", 1, Data, sizeof(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType ), /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize, /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize <= 0) {
#line 38
      /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ = TRUE;
#line 38
      return FAIL;
    }
  memcpy(Data, (void *)&/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qData[/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead], sizeof(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__dataType ));
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead++;
#line 41
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead = (uint8_t )(/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qHead % 10);
  /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize--;
  if (/*BasicServicesC.outQueue.dQueue*/dataQueueP__1__qSize <= 0) {
#line 43
    /*BasicServicesC.outQueue.dQueue*/dataQueueP__1__flagFreeQ = TRUE;
    }
#line 44
  return SUCCESS;
}

# 219 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
static void VMCustomP__BSRadio__sendDoneAck(uint8_t am_id, message_t *msg, void *dataMsg, error_t error, bool wasAcked)
#line 219
{
  dbgIx("terra", "Custom::BSRadio.sendDoneAck(): AM_ID = %d, error=%d, ack=%d\n", am_id, error, wasAcked);
  if (am_id == AM_USRMSG) {
      __nesc_hton_uint8(VMCustomP__ExtDataWasAcked.nxdata, (uint8_t )wasAcked);
      VMCustomP__VM__queueEvt(I_SEND_DONE_ACK_ID, __nesc_ntoh_uint8(((usrMsg_t *)dataMsg)->type.nxdata), &VMCustomP__ExtDataWasAcked);
      VMCustomP__VM__queueEvt(I_SEND_DONE_ACK, 0, &VMCustomP__ExtDataWasAcked);
    }
  else 
#line 225
    {
      dbgIx("terra", "Custom::BSRadio.sendDoneAck(): Discarting sendDoneAck AM_ID = %d\n", am_id);
    }
}

#line 209
static void VMCustomP__BSRadio__sendDone(uint8_t am_id, message_t *msg, void *dataMsg, error_t error)
#line 209
{
  dbgIx("terra", "Custom::BSRadio.sendDone(): AM_ID = %d, error=%d\n", am_id, error);
  if (am_id == AM_USRMSG) {
      __nesc_hton_uint8(VMCustomP__ExtDataSendDoneError.nxdata, (uint8_t )error);
      VMCustomP__VM__queueEvt(I_SEND_DONE_ID, __nesc_ntoh_uint8(((usrMsg_t *)dataMsg)->type.nxdata), &VMCustomP__ExtDataSendDoneError);
      VMCustomP__VM__queueEvt(I_SEND_DONE, 0, &VMCustomP__ExtDataSendDoneError);
    }
  else 
#line 215
    {
      dbgIx("terra", "Custom::BSRadio.sendDone(): Discarting sendDone AM_ID = %d\n", am_id);
    }
}

# 173 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static error_t UDPActiveMessageP__SplitControl__start(void )
#line 173
{

  const unsigned int reuse = 1;
  struct sockaddr_in addr;
  struct ip_mreq mcast_group;
  pid_t pid;
  int a_flags;
  struct sigaction a_sa;
  int ttl;

  const unsigned int zero = 0;
  const unsigned int one = 1;
  int status;


  if (UDPActiveMessageP__getID_fromIP() == 0) {
      dbgIx("UDP", "UDP::Nenhuma interface ethernet AF_INET foi encontrada\n");
      return FAIL;
    }
  dbgIx("UDP", "UDP::Addr/NODE_ID: %d\n", TOS_NODE_ID);



  UDPActiveMessageP__socket_receiver = socket(2, 2, 0);
  if (UDPActiveMessageP__socket_receiver < 0) {
      dbgIx("UDP", "UDP::Erro.1 - %d\n", *__errno());
      return FAIL;
    }

  if (setsockopt(UDPActiveMessageP__socket_receiver, 1, 2, &reuse, sizeof reuse) < 0) {
      close(UDPActiveMessageP__socket_receiver);
      dbgIx("UDP", "UDP::Erro.2 - %d\n", *__errno());
      return FAIL;
    }

  if (fcntl(UDPActiveMessageP__socket_receiver, 4, 00004000) < 0) {
      close(UDPActiveMessageP__socket_receiver);
      dbgIx("UDP", "UDP::Erro.3 - %d\n", *__errno());
      return FAIL;
    }

  memset((char *)&addr, 0, sizeof addr);
  addr.sin_family = 2;
  addr.sin_port = __builtin_bswap16(5000);
  addr.sin_addr.s_addr = (unsigned long int )0x00000000;
  if (bind(UDPActiveMessageP__socket_receiver, (struct sockaddr *)&addr, sizeof addr)) {
      close(UDPActiveMessageP__socket_receiver);
      dbgIx("UDP", "UDP::Erro.4 - %d\n", *__errno());
      return FAIL;
    }

  mcast_group.imr_multiaddr.s_addr = inet_addr("224.0.2.1");
  mcast_group.imr_interface.s_addr = (unsigned long int )0x00000000;
  if (setsockopt(UDPActiveMessageP__socket_receiver, IPPROTO_IP, 35, (char *)&mcast_group, sizeof mcast_group)) {
      close(UDPActiveMessageP__socket_receiver);
      dbgIx("UDP", "UDP::Erro.5 - %d\n", *__errno());
      return FAIL;
    }

  ttl = 2;
  if (setsockopt(UDPActiveMessageP__socket_receiver, IPPROTO_IP, 2, &ttl, sizeof ttl)) {
      close(UDPActiveMessageP__socket_receiver);
      dbgIx("UDP", "UDP::Erro.5.1 - %d\n", *__errno());
      return FAIL;
    }


  pid = getpid();

  a_flags = fcntl(UDPActiveMessageP__socket_receiver, 3);
  fcntl(UDPActiveMessageP__socket_receiver, 4, a_flags | 00020000);

  a_sa.sa_flags = 0;
  a_sa._u._sa_handler = UDPActiveMessageP__UDP_HandleReceiver;
  sigemptyset(& a_sa.sa_mask);

  sigaction(29, &a_sa, (void *)0);
  fcntl(UDPActiveMessageP__socket_receiver, 8, pid);


  memset((char *)&UDPActiveMessageP__addrSender, 0, sizeof UDPActiveMessageP__addrSender);
  UDPActiveMessageP__addrSender.sin_addr.s_addr = inet_addr("224.0.2.1");
  UDPActiveMessageP__addrSender.sin_family = 2;
  UDPActiveMessageP__addrSender.sin_port = __builtin_bswap16(5000);

  UDPActiveMessageP__socket_sender = socket(2, 2, 0);
  if (UDPActiveMessageP__socket_sender < 0) {
      dbgIx("UDP", "UDP::Erro.6 - %d\n", *__errno());
      return FAIL;
    }

  if (setsockopt(UDPActiveMessageP__socket_sender, 1, 2, &one, sizeof(unsigned int )) < 0) {
      close(UDPActiveMessageP__socket_sender);
      dbgIx("UDP", "UDP::Erro.7 - %d\n", *__errno());
      return FAIL;
    }

  if (setsockopt(UDPActiveMessageP__socket_sender, IPPROTO_IP, 34, &zero, sizeof(unsigned int )) < 0) {
      close(UDPActiveMessageP__socket_sender);
      dbgIx("UDP", "UDP::Erro.8 - %d\n", *__errno());
      return FAIL;
    }

  mcast_group.imr_multiaddr.s_addr = inet_addr("224.0.2.1");
  mcast_group.imr_interface.s_addr = (unsigned long int )0x00000000;
  status = setsockopt(UDPActiveMessageP__socket_sender, IPPROTO_IP, 35, (char *)&mcast_group, sizeof mcast_group);
  if (status) {
      dbgIx("UDP", "UDP::Erro.9 - %d\n", *__errno());
      close(UDPActiveMessageP__socket_sender);
      return FAIL;
    }

  dbgIx("UDP", "UDP::Started - pid: %d\n", pid);

  UDPActiveMessageP__start_done__postTask();

  return SUCCESS;
}

#line 356
static am_addr_t UDPActiveMessageP__AMPacket__destination(message_t *amsg)
#line 356
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 358
  return __nesc_ntoh_uint16(header->dest.nxdata);
}










static am_addr_t UDPActiveMessageP__AMPacket__source(message_t *amsg)
#line 370
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 372
  return __nesc_ntoh_uint16(header->src.nxdata);
}

# 1436 "BasicServicesP.nc"
static void BasicServicesP__sendReqProgBlock(reqProgBlock_t *Data)
#line 1436
{
  dbgIx("terra", "BS::sendReqProgBlock(): insert in outQueue --- BlkId=%d, versionId=%d, moteType=%d\n", __nesc_ntoh_uint16(Data->blockId.nxdata), __nesc_ntoh_uint16(Data->versionId.nxdata), __nesc_ntoh_uint8(Data->moteType.nxdata));
  memcpy(& BasicServicesP__tempInputOutQ.Data, Data, sizeof(reqProgBlock_t ));
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.AM_ID.nxdata, AM_REQPROGBLOCK);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.DataSize.nxdata, sizeof(reqProgBlock_t ));
  __nesc_hton_uint16(BasicServicesP__tempInputOutQ.sendToMote.nxdata, __nesc_ntoh_uint16(BasicServicesP__ProgMoteSource.nxdata));
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.reqAck.nxdata, 0);
  __nesc_hton_uint8(BasicServicesP__tempInputOutQ.fromSerial.nxdata, FALSE);
  if (BasicServicesP__outQ__put(&BasicServicesP__tempInputOutQ) != SUCCESS) {
      dbgIx("terra", "BS::sendReqProgBlock(): outQueue is full! Losting a message.\n");
    }
}

# 1876 "TerraVMC.nc"
static void TerraVMC__BSUpload__resetMemory(void )
#line 1876
{
  uint16_t i;
  uint8_t size;

  dbgIx("terra", "VM::BSUpload.resetMemory()\n");
  TerraVMC__haltedFlag = TRUE;

  for (i = 0; i < (uint16_t )(BLOCK_SIZE * CURRENT_MAX_BLOCKS); i++) __nesc_hton_uint8(TerraVMC__CEU_data[i].nxdata, 0);

  size = TerraVMC__evtQ__size();
  for (i = 0; i < size; i++) TerraVMC__evtQ__dequeue();
}

# 85 "/home/mauricio/Terra/TerraVM/src/system/QueueC.nc"
static /*TerraVMAppC.evtQ*/QueueC__0__queue_t /*TerraVMAppC.evtQ*/QueueC__0__Queue__dequeue(void )
#line 85
{
  /*TerraVMAppC.evtQ*/QueueC__0__queue_t t = /*TerraVMAppC.evtQ*/QueueC__0__Queue__head();

#line 87
  dbgIx("QueueC", "%s: size is %hhu\n", __FUNCTION__, /*TerraVMAppC.evtQ*/QueueC__0__size);
  if (!/*TerraVMAppC.evtQ*/QueueC__0__Queue__empty()) {
      /*TerraVMAppC.evtQ*/QueueC__0__head++;
      if (/*TerraVMAppC.evtQ*/QueueC__0__head == 6) {
#line 90
        /*TerraVMAppC.evtQ*/QueueC__0__head = 0;
        }
#line 91
      /*TerraVMAppC.evtQ*/QueueC__0__size--;
      /*TerraVMAppC.evtQ*/QueueC__0__printQueue();
    }
  return t;
}

# 12 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/RPI_InternalFlashP.nc"
static error_t RPI_InternalFlashP__IntFlash__read(void *addr, void *buf, uint16_t size)
#line 12
{
  FILE *fd;
  error_t stat;

#line 15
  dbgIx("terra", "IntFlash.read(): addr=%d, size=%d\n", (uint32_t )addr, size);
  fd = RPI_InternalFlashP__getFD("r");
  if (fd == (void *)0) {
#line 17
    return FAIL;
    }
#line 18
  stat = fread(buf, size, 1, fd);
  if (stat != SUCCESS) {
#line 19
    return FAIL;
    }
#line 20
  return SUCCESS;
}

# 1847 "TerraVMC.nc"
static void TerraVMC__BSUpload__start(bool resetFlag)
#line 1847
{
  uint8_t i;
#line 1848
  uint8_t size;

#line 1849
  __nesc_hton_uint16(TerraVMC__MoteID.nxdata, TOS_NODE_ID);


  if (TerraVMC__envData.persistFlag && TerraVMC__progRestored == FALSE) {
      TerraVMC__ProgStorage__save(&TerraVMC__envData, (uint8_t *)&TerraVMC__CEU_data[TerraVMC__envData.ProgStart], TerraVMC__envData.ProgEnd - TerraVMC__envData.ProgStart + 1);
      TerraVMC__progRestored = TRUE;
    }

  dbgIx("terra", "VM::BSUpload.start(%s)\n", resetFlag ? "TRUE" : "FALSE");
  if (resetFlag == TRUE) {

      size = TerraVMC__evtQ__size();
      for (i = 0; i < size; i++) TerraVMC__evtQ__dequeue();
    }
  TerraVMC__haltedFlag = FALSE;


  TerraVMC__VMCustom__reset();
  TerraVMC__TViewer("error", 0, 0);

  TerraVMC__ceu_boot();
}

# 19 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__put(void *Data)
#line 19
{
  dbgIx("terra", "dataQ[%hhu]::put(). Size and FlagFree before %hhu : %s\n", 0, /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize, /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize >= 5) {
      return FAIL;
    }

  memcpy((void *)&/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qData[/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qTail], Data, sizeof(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType ));
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qTail++;
#line 27
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qTail = (uint8_t )(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qTail % 5);
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize++;
  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ == TRUE) {
      /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ = FALSE;
#line 30
      /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataReady__postTask();
    }
  return SUCCESS;
}

# 84 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static bool /*BasicServicesC.Bitmap2*/vmBitVectorC__1__BitVector__get(uint16_t bitnum)
{
  { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 86
    {
      dbgIx("terra", "VM::BitVector.get(): bitnum=%d, bits=%0x, ARRAY_SIZE=%d\n", bitnum, (uint8_t )/*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(bitnum)], /*BasicServicesC.Bitmap2*/vmBitVectorC__1__ARRAY_SIZE);
      {
        unsigned char __nesc_temp = 
#line 88
        /*BasicServicesC.Bitmap2*/vmBitVectorC__1__m_bits[/*BasicServicesC.Bitmap2*/vmBitVectorC__1__getIndex(bitnum)] & /*BasicServicesC.Bitmap2*/vmBitVectorC__1__getMask(bitnum) ? TRUE : FALSE;

        {
#line 88
          __nesc_atomic_end(__nesc_atomic); 
#line 88
          return __nesc_temp;
        }
      }
    }
#line 91
    __nesc_atomic_end(__nesc_atomic); }
}

# 351 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/UDPActiveMessageP.nc"
static am_id_t UDPActiveMessageP__AMPacket__type(message_t *amsg)
#line 351
{
  serial_header_t *header = UDPActiveMessageP__getHeader(amsg);

#line 353
  return __nesc_ntoh_uint8(header->type.nxdata);
}

#line 398
static void *UDPActiveMessageP__Packet__getPayload(message_t *msg, uint8_t len)
#line 398
{
  if (len > UDPActiveMessageP__Packet__maxPayloadLength()) {
      return (void *)0;
    }
  else {
      return (void * )msg->data;
    }
}

#line 393
static uint8_t UDPActiveMessageP__Packet__payloadLength(message_t *msg)
#line 393
{
  serial_header_t *header = UDPActiveMessageP__getHeader(msg);

#line 395
  return __nesc_ntoh_uint8(header->length.nxdata);
}

# 1204 "BasicServicesP.nc"
static void BasicServicesP__sendRadioN(void )
#line 1204
{
  error_t err;

#line 1206
  dbgIx("terra", "BS::sendRadioN(): AM=%hhu to %d, reqAck=%s\n", __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata), (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.reqAck.nxdata) & (1 << REQ_ACK_BIT)) > 0 ? "TRUE" : "FALSE");
  memcpy(BasicServicesP__RadioPacket__getPayload(&BasicServicesP__sendBuff, BasicServicesP__RadioPacket__maxPayloadLength()), & BasicServicesP__tempOutputOutQ.Data, __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.DataSize.nxdata));




  if ((__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.reqAck.nxdata) & (1 << REQ_ACK_BIT)) > 0) {
      if (BasicServicesP__RadioAck__requestAck(&BasicServicesP__sendBuff) != SUCCESS) {
#line 1213
        dbgIx("terra", "BS::sendRadioN()(): requestAck() error!\n");
        }
    }
  else 
#line 1214
    {
      if (BasicServicesP__RadioAck__noAck(&BasicServicesP__sendBuff) != SUCCESS) {
#line 1215
        dbgIx("terra", "BS::sendRadioN()(): requestNoAck() error!\n");
        }
    }
  if (__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.RFPower.nxdata) > 0) {
#line 1218
    BasicServicesP__AMAux__setPower(&BasicServicesP__sendBuff, __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.RFPower.nxdata));
    }
#line 1219
  err = BasicServicesP__RadioSender_send(__nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata), &BasicServicesP__sendBuff, __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.DataSize.nxdata), __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.fromSerial.nxdata));
  if (err != SUCCESS) {
      dbgIx("terra", "BS::sendRadioN(): Error %hhu in sending Message AM=%hhu to node=%d via radio\n", err, __nesc_ntoh_uint8(BasicServicesP__tempOutputOutQ.AM_ID.nxdata), __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata));
      BasicServicesP__sendTimer__startOneShot(BasicServicesP__reSendDelay);
    }
  else 
#line 1223
    {
      BasicServicesP__TViewer("radio", __nesc_ntoh_uint16(BasicServicesP__tempOutputOutQ.sendToMote.nxdata), 0);
    }
}

# 35 "/home/mauricio/Terra/TerraVM/src/system/dataQueueP.nc"
static error_t /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataQueue__get(void *Data)
#line 35
{
  dbgIx("terra", "dataQ[%hhu]::get(%x[%d]). Size and FlagFree before %hhu : %s\n", 0, Data, sizeof(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType ), /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize, /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ == TRUE ? "TRUE" : "FALSE");

  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize <= 0) {
#line 38
      /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ = TRUE;
#line 38
      return FAIL;
    }
  memcpy(Data, (void *)&/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qData[/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead], sizeof(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__dataType ));
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead++;
#line 41
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead = (uint8_t )(/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qHead % 5);
  /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize--;
  if (/*BasicServicesC.inQueue.dQueue*/dataQueueP__0__qSize <= 0) {
#line 43
    /*BasicServicesC.inQueue.dQueue*/dataQueueP__0__flagFreeQ = TRUE;
    }
#line 44
  return SUCCESS;
}

# 120 "/home/mauricio/Terra/TerraVM/src/system/vmBitVectorC.nc"
static bool /*BasicServicesC.Bitmap*/vmBitVectorC__0__BitVector__isAllBitSet(void )
{
  uint16_t elnum;

#line 123
  for (elnum = 0; elnum < /*BasicServicesC.Bitmap*/vmBitVectorC__0__ARRAY_SIZE; elnum++) 
    { __nesc_atomic_t __nesc_atomic = __nesc_atomic_start();
#line 124
      {
#line 124
        if (/*BasicServicesC.Bitmap*/vmBitVectorC__0__m_bits[elnum] != 0xff) {
            unsigned char __nesc_temp = 
#line 124
            FALSE;

            {
#line 124
              __nesc_atomic_end(__nesc_atomic); 
#line 124
              return __nesc_temp;
            }
          }
      }
#line 127
      __nesc_atomic_end(__nesc_atomic); }
#line 125
  return TRUE;
}

# 247 "/home/mauricio/Terra/TerraVM/src/platforms/Droid/VMCustomP.nc"
  void androidTouchEvent(uint16_t posX, uint16_t posY)
#line 247
{
  dbgIx("terra", "Custom::Android Touch Event Registered : posX = %d, posY = %d", posX, posY);
  __nesc_hton_uint16(VMCustomP__ExtDataTouch.x.nxdata, posX);
  __nesc_hton_uint16(VMCustomP__ExtDataTouch.y.nxdata, posY);
  VMCustomP__VM__queueEvt(I_TOUCH, 0, &VMCustomP__ExtDataTouch);
}

