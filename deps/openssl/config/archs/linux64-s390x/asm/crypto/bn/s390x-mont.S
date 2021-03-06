.text
.globl	bn_mul_mont
.type	bn_mul_mont,@function
bn_mul_mont:
	lgf	%r1,164(%r15)	# pull %r1
	sla	%r1,3	# %r1 to enumerate bytes
	la	%r4,0(%r1,%r4)

	stg	%r2,2*8(%r15)

	cghi	%r1,16		#
	lghi	%r2,0		#
	blr	%r14		# if(%r1<16) return 0;
	cghi	%r1,96		#
	bhr	%r14		# if(%r1>96) return 0;
	stmg	%r3,%r15,3*8(%r15)

	lghi	%r2,-160-8	# leave room for carry bit
	lcgr	%r7,%r1		# -%r1
	lgr	%r0,%r15
	la	%r2,0(%r2,%r15)
	la	%r15,0(%r7,%r2)	# alloca
	stg	%r0,0(%r15)	# back chain

	sra	%r1,3		# restore %r1
	la	%r4,0(%r7,%r4)	# restore %r4
	ahi	%r1,-1		# adjust %r1 for inner loop
	lg	%r6,0(%r6)	# pull n0
	

	lg	%r2,0(%r4)
	
	lg	%r9,0(%r3)
	
	mlgr	%r8,%r2	# ap[0]*bp[0]
	lgr	%r12,%r8

	lgr	%r0,%r9	# "tp[0]"*n0
	msgr	%r0,%r6

	lg	%r11,0(%r5)	#
	
	mlgr	%r10,%r0	# np[0]*m1
	algr	%r11,%r9	# +="tp[0]"
	lghi	%r13,0
	alcgr	%r13,%r10

	la	%r7,8		# j=1
	lr	%r14,%r1

.align	16
.L1st:
	lg	%r9,0(%r7,%r3)
	
	mlgr	%r8,%r2	# ap[j]*bp[0]
	algr	%r9,%r12
	lghi	%r12,0
	alcgr	%r12,%r8

	lg	%r11,0(%r7,%r5)
	
	mlgr	%r10,%r0	# np[j]*m1
	algr	%r11,%r13
	lghi	%r13,0
	alcgr	%r10,%r13	# +="tp[j]"
	algr	%r11,%r9
	alcgr	%r13,%r10

	stg	%r11,160-8(%r7,%r15)	# tp[j-1]=
	la	%r7,8(%r7)	# j++
	brct	%r14,.L1st

	algr	%r13,%r12
	lghi	%r12,0
	alcgr	%r12,%r12	# upmost overflow bit
	stg	%r13,160-8(%r7,%r15)
	stg	%r12,160(%r7,%r15)
	la	%r4,8(%r4)	# bp++

.Louter:
	lg	%r2,0(%r4)	# bp[i]
	
	lg	%r9,0(%r3)
	
	mlgr	%r8,%r2	# ap[0]*bp[i]
	alg	%r9,160(%r15)	# +=tp[0]
	lghi	%r12,0
	alcgr	%r12,%r8

	lgr	%r0,%r9
	msgr	%r0,%r6	# tp[0]*n0

	lg	%r11,0(%r5)	# np[0]
	
	mlgr	%r10,%r0	# np[0]*m1
	algr	%r11,%r9	# +="tp[0]"
	lghi	%r13,0
	alcgr	%r13,%r10

	la	%r7,8		# j=1
	lr	%r14,%r1

.align	16
.Linner:
	lg	%r9,0(%r7,%r3)
	
	mlgr	%r8,%r2	# ap[j]*bp[i]
	algr	%r9,%r12
	lghi	%r12,0
	alcgr	%r8,%r12
	alg	%r9,160(%r7,%r15)# +=tp[j]
	alcgr	%r12,%r8

	lg	%r11,0(%r7,%r5)
	
	mlgr	%r10,%r0	# np[j]*m1
	algr	%r11,%r13
	lghi	%r13,0
	alcgr	%r10,%r13
	algr	%r11,%r9	# +="tp[j]"
	alcgr	%r13,%r10

	stg	%r11,160-8(%r7,%r15)	# tp[j-1]=
	la	%r7,8(%r7)	# j++
	brct	%r14,.Linner

	algr	%r13,%r12
	lghi	%r12,0
	alcgr	%r12,%r12
	alg	%r13,160(%r7,%r15)# accumulate previous upmost overflow bit
	lghi	%r8,0
	alcgr	%r12,%r8	# new upmost overflow bit
	stg	%r13,160-8(%r7,%r15)
	stg	%r12,160(%r7,%r15)

	la	%r4,8(%r4)	# bp++
	clg	%r4,200(%r7,%r15)	# compare to &bp[num]
	jne	.Louter

	lg	%r2,184(%r7,%r15)	# reincarnate rp
	la	%r3,160(%r15)
	ahi	%r1,1		# restore %r1, incidentally clears "borrow"

	la	%r7,0
	lr	%r14,%r1
.Lsub:	lg	%r9,0(%r7,%r3)
	lg	%r11,0(%r7,%r5)
	
	slbgr	%r9,%r11
	stg	%r9,0(%r7,%r2)
	la	%r7,8(%r7)
	brct	%r14,.Lsub
	lghi	%r8,0
	slbgr	%r12,%r8	# handle upmost carry
	lghi	%r13,-1
	xgr	%r13,%r12

	la	%r7,0
	lgr	%r14,%r1
.Lcopy:	lg	%r8,160(%r7,%r15)	# conditional copy
	lg	%r9,0(%r7,%r2)
	ngr	%r8,%r12
	ngr	%r9,%r13
	ogr	%r9,%r8
	
	stg	%r7,160(%r7,%r15)	# zap tp
	stg	%r9,0(%r7,%r2)
	la	%r7,8(%r7)
	brct	%r14,.Lcopy

	la	%r1,216(%r7,%r15)
	lmg	%r6,%r15,0(%r1)
	lghi	%r2,1		# signal "processed"
	br	%r14
.size	bn_mul_mont,.-bn_mul_mont
.string	"Montgomery Multiplication for s390x, CRYPTOGAMS by <appro@openssl.org>"
