#ifndef __ASM_ARM_PLATFORMS_SUN6I_H
#define __ASM_ASM_PLATFORMS_SUN6I_H

/* Constants below is only used in assembly because the DTS is not yet parsed */
#ifdef __ASSEMBLY__

/* GIC Base Address */
#define SUN6I_GIC_BASE_ADDRESS       0x01c80000

/* Timer's frequency */
/* \TODO I do not know yet, assume it 24MHz. check it later */
#define SUN6I_TIMER_FREQUENCY       (24 * 1000 * 1000) /* 24 MHz */

/* Arndale machine ID */
/* XXX 3894 is downstream number for sun6i. 4137 is upstream number for sun6i */
#define MACH_TYPE_SUN6I             3894

#endif /* __ASSEMBLY__ */

#endif /* __ASM_ARM_PLATFORMS_SUN6I_H */
/*
 * Local variables:
 * mode: C
 * c-file-style: "BSD"
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 */
