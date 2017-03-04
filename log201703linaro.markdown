
14:35 2017-03-04
----------------
1.  Patches of cont page hint
    1.  For contiguous mapping. Used by kernel segment(text, data...), memblock(What it is?) and efi runtime. Contribute by (Jeremy Linton <jeremy.linton@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>)
        ```
        0bfc445 arm64: mm: set the contiguous bit for kernel mappings where appropriate
        667c275 Revert "arm64: Mark kernel page ranges contiguous"
        348a65c arm64: Mark kernel page ranges contiguous
        202e41a arm64: Make the kernel page dump utility aware of the CONT bit
        06f90d2 arm64: Default kernel pages should be contiguous
        93ef666 arm64: Macros to check/set/unset the contiguous bit
        ecf35a2 arm64: PTE/PMD contiguous bit definition
        2ff4439 arm64: Add contiguous page flag shifts and constants
        ```
        1.  Could it become a problem if we change the mapping in running for some reason? (I do not know if we need do it).
        2.  Is there performance downgrade if the kernel run in the virtualization senario?

    2.  enable for hugetlb contribute by David Woods <dwoods@ezchip.com>
        "66b3923" arm64: hugetlb: add support for PTE contiguous bit)

    3.  filesystem

1.  does our smmu suppport cont page hint?
    1.  if so, I could add the support for it.


change the mobile and chromebook
