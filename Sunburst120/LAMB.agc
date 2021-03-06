### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	LAMB.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-19 RSB	Transcribed from scratch.  Ouch!
##		2016-10-31 RSB	Typos.
##		2016-11-01 RSB  A line reading "OCT B0", which is not supported by yaYUL,
##				has been replaced by "OCT 1", in lieu of modifying 
##				yaYUL at this time.  An appropriate program comment was 
##				also added at this point in the code.  Plus, more typos.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				 changes made.
##		2017-06-10 MAS	Corrected typos and a missing comment found while
##				updating for Sunburst 37.



## Page 926
		BANK	36
		EBANK=	SCAXIS

#  PROGRAM NAME ... LAMBERT ROUTINE                                        DATE ... 11/29/66
#
#  MOD NO ... 3                                                            LOG SECTION ...LAMB
#                                                                          ASSEMBLY ... SUNBURST REVISION 03
#
#  MODIFICATION BY ... J.J. BESTER AND L.G. HULL
#  FUNCTIONAL DESCRIPTION ...

#    THIS SUBROUTINE SOLVES FOR THE CONIC TRAJECTORY BETWEEN R0VEC AND R1VEC WHICH SATISFIES A SPECIFIED TIME
#  OF FLIGHT, TFL.  A SLOPE ITERATOR IS USED TO FORCE THE TIME OF FLIGHT TO CONVERGE.



#  CALLING SEQUENCE:

#  THIS ROUTINE IS CALLED IN THE INTERPRETIVE MODE BY
#                                                                 CALL
#                                                                          LAMBERT



#  NORMAL EXIT MODE:

#  EXIT FROM THIS ROUTINE IS IN BASIC BY
#                                                                 TCF      ENDOFJOB



#  OUTPUT:

#  THE OUTPUT OF THIS ROUTINE (WITH SCALING INDICATED IN PARENTHESES) CONSISTS OF ...

#  V0VEC (+7)    -THE REQUIRED VELOCITY VECTOR IN METERS/CENTISECONDS

# DONESW         -THE DONE SWITCH INDICATING WHETHER THE JOB HAS BEEN COMPLETED.  WHEN THE JOB IS DONE IT
#                 IS TURNED ON.

#  CONVSW        - THE CONVERGENCE SWITCH INDICATING WHETHER THE ITERATION PROCESS HAS CONVERGED.  IT IS TURNED
#                 ON IF CONVERGENCE HAS NOT OCCURRED, BUT AN ESTIMATE OF V0VEC IS NEVERTHELESS GIVEN.



#  INPUT:

#  THE QUANTITIES INPUTED AND THEIR SCALE FACTORS ARE ...
## Page 927
# RCOV   (+25)   -INITIAL POSITION IN METERS.
#  R1VEC (+25)   -THE TARGET POSITION IN METERS.

#  TFL (+28)     -TIME OF FLIGHT IN CENTISECONDS.

#  UNNORM (+1)   -A UNIT VECTOR IN THE DIRECTION OF THE ANGULAR MOMENTUM  VECTOR.

#  TAG5          -A PARAMETER SET TO -0.5 IF THE TRUE ANOMALY DIFFERENCE BETWEEN R0VEC AND R1VEC IS MORE THAN
#                 180 DEGREES.  OTHERWISE IT SHOULD BE SET TO +0.5.

#  GUESSW        -THE GUESS SWITCH, IF A FIRST GUESS TO THE COTANGENT OF THE FLIGHT PATH ANGLE IS AVAILABLE THE
#                 SWITCH SHOULD BE SET , CLEAR IF NO GUESS IS FORTHCOMING.

#  COGAVAIL (+5) -THE AVAILABLE COTANGENT OF THE FLIGHT PATH ANGLE.  IF A GUESS IS AVAILABLE THE GUESSW SHOULD BE
#                 SET AND THE GUESS PLACED HERE BEFORE THE LAMBERT ROUTINE IS ENTERED.  AFTER ONE PASS THROUGH
#                 LAMBERT, THE LAST ITERATED VALUE OF THE COTANGENT IS PLACED IN COGAVAIL AND  MAY BE USED AS THE
#                 GUESS FOR THE NEXT PASS.



#  THE FOLLOWING SWITCHES ARE IN THIS ROUTINE , THOUGH THEY ARE NOT USED FOR THIS PARTICULAR MISSION AND ARE
#  ALWAYS CLEAR IN 206.

#  MOONSW        - THE MOON SWITCH: 1-INSIDE THE SPHERE OF INFLUENCE OF THE MOON (35,000 N.MI.)
#                                   0-OUTSIDE

#  ESCPSW        -THE ESCAPE SWITCH: 1-HYPERBOLIC ORBIT
#                                    0-ELLIPTIC ORBIT

#  SMANGLSW      -SMALL ANGLE SWITCH: 1-SMALL TRANSFER ANGLES
#                                     0-LARGE ANGLES (THE USUAL CASE)

#  TWO SWITCHES ARE USED INTERNALLY.  THEY ARE ...

#  ITERSW        -THE ITERATION SWITCH: 1-FIRST ITERATION IS TO TAKE PLACE
#                                       0-SUBSEQUENT ITERATIONS

#  PIESW         -THE 180 DEGREES SWITCH: 1-ANGLES GREATER THAN 180 DEGREES WITH TAG5=-0.5
#                                         0-ANGLES LESS THAN 180, TAG5=0.5



#  DEBRIS ...

#    THE LAMBERT ROUTINE INTERNALLY USES SCALING WHICH IS DIFFERENT FROM THAT USED BY THE MAIN PROGRAM.
#  INTERNAL TO LAMBERT,
#                               7
#  LENGTH IS SCALED BY RNORM = 2  RE

#  VELOCITY IS SCALED BY VNORM = 2 SQRT(MU/RE)
## Page 928
#                             10        3
#  TIME IS SCALED BY TNORM = 2   SQRT(RE /MU)
#  WHERE MU IS THE GRAVITATIONAL CONSTANT TIMES THE MASS OF THE EARTH AND RE IS THE RADIUS OF THE EARTH.
#           22
#  FOR RE, 2   METERS IS USED. HOWEVER, INPUT AND OUTPUT QUANTITIES HAVE  SCALING COMPATIBLE WITH THE REST OF THE
#  PROGRAM.  RESCALING WILL BE DONE BY THE LAMBERT ROUTINE BEFORE COMPUTATIONS BEGIN.

## Page 929
LAMBERT		SET	SETPD
			ITERSW
			0D
		CLEAR	CLEAR
			MOONSW
			DONESW
		CLEAR	CLEAR
			SMANGLSW
			PIESW
		DLOAD	BPL
			TAG5
			+3
		SET
			PIESW
		BON	
			GUESSW
			+6
		DLOAD
			D1/4
		STORE	TWEEKIT
		GOTO
			PROG
		DLOAD
			D1/64
		STORE	TWEEKIT
PROG		DLOAD	DMP
			TFL
			TFACT
		SL3			# RESCALE TIME OF FLIGHT
		STOVL	TF
			RCOTEMPV
		VSR4
		STCALL	R0VEC
			DTPRD
		CALL
			CGTH
		DLOAD	NORM
			36D
			X1
		BDDV	SL*
			32D
			0	-7,1
		STODL	30D		# 30D=R (+7)
		
			D1/2
		DSU	SR1
			28D
		STORE	20D		# 20D=1-CSTH  (+2)  (FOR PCALC IN LOOP)
		
		NORM	PDDL		# 1-CSTH (+2-N1)                 PL AT 2D
## Page 930
			X1
			30D
		DDV                     #                                PL AT 0D
		SL*	SQRT
			0	-4,1
		BOFF	BDSU
			ESCPSW
			ELIPLMTS
			16D
		PUSH	ABS		#				 PL AT 2D
		DMP	BDSU		#				 PL AT 0D
			PERCENT
		STADR
		STODL	26D		# 26D=COGAMX
		
			24D
		SR1
		STORE	18D		# 18D=SIN(TH) (+2) (FOR PCALC IN LOOP)
		NORM	PDDL		# SIN(TH) (+1-N1)                PL AT 2D
			X1
			28D
		SR	DSU
			6
			30D
		STORE	30D		# 30D=COS(TH)-R (+7)  (FOR PCALC IN LOOP)
		
		BON	DDV		#				 PL AT 0D
			PIESW
			ABSMIN
		SL*	BOV
			0,1
			ABSMIN
		PUSH	ABS		# (CSTH-R)/SNTH (+5)		 PL AT 2D
		DMP	DAD		#				 PL AT 0D
			PERCENT
		GOTO
			+4
ABSMIN		SETPD	DLOAD		#				 PL AT 0D
			0D
			ABSOLMIN
		STORE	22D		# 22D=COGAMN (+5)
		BOFF	DLOAD		#				 PL AT 2D
			GUESSW
			FIRSTCOG
			COGAVAIL
		BON	DSU		# IF ESCPSW IS OFF, CHECK IF COGAVAIL
			ESCPSW		# IS LESS THAN COGAMN
			LOOP
			22D
		BPL	DLOAD
## Page 931
			+5
			22D		# COGAVAIL IS A BAD GUESS, SO PUT
		STORE	COGAVAIL	# COGAMN IN COGAVAIL
		GOTO
			LOOP
		DLOAD
			COGAVAIL
LOOP		STORE	INDEP
		DMP	DSU
			18D
			30D
		NORM	BDDV
			X1
			20D
		SL*	BOV
			0	-7,1
			SPEEDY
PSTORE		STCALL	34D		# 34D=P (+2)
			SMAR
		CALL
			TRIGFNS
		CALL
			SMA
		CALL
			DELTIME
ZOOM		STORE	DEPVAR
		BDSU
			TF
		STORE	DELDEP
		ABS	DSU
			DEPCRIT
		BMN	CALL
			TIMECONV
			ITERATOR
		ABS	DSU
			NEARZERO
		BMN	DLOAD
			NOSOL
			DEPVAR
		STODL	PREVDEP
			DELINDEP
		DAD	GOTO
			INDEP
			LOOP
FIRSTCOG	SR1	PDDL		#				 PL AT 2D
			26D
		SR1	DAD		#				 PL AT 0D
		GOTO
			LOOP
## Page 932
TIMECONV	DLOAD
			INDEP
		STORE	COGAVAIL
		STCALL	18D		# 18D=COGA (+5)
			INITV
		SET	EXIT
			DONESW
		TCF	ENDOFJOB
NOSOL		SET	GOTO
			CONVSW
			TIMECONV
ELIPLMTS	PUSH	DAD		#				 PL AT 2D
			16D
		PUSH	ABS		#				 PL AT 4D
		DMP	BDSU		#				 PL AT 2D
			PERCENT
		STADR
		STODL	26D		# 26D=COGAMX (+5)
			28D
		SR	DSU
			6
			30D
		STODL	30D		# 30D=CSTH-R (+7)
			24D
		SR1
		STODL	18D
			16D
		DSU	PUSH		#				 PL AT 0D,2D
		ABS	DMP
			PERCENT
		DAD			#				 PL AT 0D
		GOTO
			ABSMIN	+3
SPEEDY		DLOAD	GOTO
			DZERO
			ZOOM
# V0VEC (+1) IN MPAC.
			
## Page 933
# THIS SECTION CALCULATES THE SINE AND COSINE OF THE ANGLE BETWEEN R0VEC
# AND R1VEC. THE SIGN OF SIN(TH) IS DETERMINED BY TAG5.  THE COSINE OF THE 
# ANGLE IS STORED IN 28D WHILE THE SINE IS IN MPAC AS WELL AS IN 24D, BOTH
# ARE SCALED BY  (+2).


# ASSUMES R0VEC (+7) , R1VEC (+7) , TAG5 (+/- ACCORDING TO ANGLE GREATER
# OR LESS THAN 180 DEG) AVAILABLE.
DTPRD		VLOAD	UNIT
			R0VEC
		STODL	UNR1
			36D
		STOVL	32D		# 32D=R1 (+7)
			R1VEC
		VSR4	
		UNIT	PUSH		# 32D=R1 (+7)			 PL AT 6D
		DOT	SL1
			UNR1
		STOVL	28D		# 28D=COS(TH) (+1)
			UNR1
		VXV	VSL1		#				 PL AT 0D
		ABVAL	SIGN
			TAG5
		STORE	24D		# 24D=SIN(TH) (+1)
		RVQ
		
#          28D=COS(TH) (+1), 24D=SIN(TH) (+1)=MPAC.

## Page 934
# THIS SECTION COMPUTES COT(TH/2) = (1+COS(TH))/SIN(TH) SCALED BY (+5),
# AND STORES IT IN 16D.  NOTE THAT COT(TH/2) WILL OVERFLOW IF THE ANGLE
# TH IS LESS THAN 3 DEG 35 MINUTES OR GREATER THAN 356 DEG 25 MINUTES.


# ASSUMES SNTH(+1) IN MPAC, 28D=CSTH (+1).
CGTH		BZE	NORM		# SNTH (+1-N1)
			THISPI
			X1
		PDDL	SR1
			28D
		DAD	DDV		#				 PL AT 0D
			D1/4
		SL*
			0	-4,1
THISPI		STORE	16D
		RVQ
		
#          COGTH (+5)=16D.

## Page 935
# THIS SECTION USES COT(GAMMA),I.E. COGA (+5) AND P (+2) TO CALCULATE R1A
# SCALED BY (+6) AND STORES THE RESULT IN 14D.


# ASSUMES COGA=INDEP (+5), P (+2)=34D.
SMAR		DLOAD	DSQ
			INDEP
		DAD	NORM
			D1/1024
			X1
		DMP	SR*
			34D
			0	-6,1
		BDSU	BOV
			D1/32
			SPEEDY
SMARSTOR	STORE	14D		# 14D=R1A (+6)
		RVQ


# R1A (+6)=2-P(1+COGA*COGA) IN 14D.

## Page 936
# ASSUMES 16D=COGTH (+5), INDEP=COGA(+5), 34D=P (+2), 14D= R1A (+6).
TRIGFNS		DLOAD	DSU
			16D
			INDEP
		STORE	36D		# 36D=DCOT=COT(TH/2)-COGA (+5)
		
		DSQ	NORM
			X1
		DMP	SR1
			34D
		PDDL	ABS		# DCOT*DCOT (+13-N1)		 PL AT 2D
			14D
		NORM	BDDV		# COGDS (+7-N1+N2)		 PL AT 0D
			S1
		XSU,1	SR*
			S1
			3,1
		BOV
			COGDSOVF
COGDSTOR	PUSH	SIGN		# COGDS (+10)
			14D
		DAD	NORM
			D1/1024
			X1
		BDDV	PDDL		# 2D=1-CSD (-7+N1)		 PL AT 4D
			D1/4
			0D
		SQRT	NORM
			X2
		DMP	SIGN
			2D
			36D		# SND=+-(1-CSD)SQRT(COGDS) (-2+N1-N2)
		XSU,2	BON
			X1
			ESCPSW
			HYPTRIG		# DUE TO DIFFERENT SCALING
		SR*	PDDL		# DXNGE WITH PD,2D=SND (+1)	 PL AT 4D
			3,2
		SL*	BOV
			0	-8D,1
			HALFCIRC
COSFN		PUSH	DCOMP		# 4D=(1-CSD)(+1)		 PL AT 6D
		DAD	ACOS
			D1/2
		SIGN	DMP
			36D
			PI/4		# CONVERT FROM CIRCLES TO RADIANS/8
		BPL	DAD
			+2
			PI/4		
## Page 937
		STORE	0D		# 0D=DELTAE (+3)
		RVQ
		
		
HALFCIRC	DLOAD	GOTO
			NEARI
			COSFN
HYPTRIG		SR*	DCOMP
			12D,2
		PDDL			# DXNGE WITH PD,2D=SND (+10)	 PL AT 4D
		SL*	PUSH
			0	-17D,1	# 4D=(1-CSD) (+10)		 PL AT 6D
		DCOMP	DAD
			D1/1024
		SR1	PDDL		#			 	 PL AT 8D
			2D
		SR1	DAD		# ARG=COSH(DELG)+SINH(DELG) (+11)  PL AT 6D
		
		NORM	BDSU		# THIS IS AN ARCSINH ROUTINE
			SPLOC		# ARG=.5-ARG (+11-N1)
			D1/2
		EXIT
ARCSINH		CA	TEN
		ADS	SPLOC		# C(SPLOC)=10-N1
		TC	POLY
		DEC	9
DZERO		2DEC	.0

		2DEC	.015625
		
		2DEC	.015625
		
		2DEC	.020833333
		
		2DEC	.03125
		
		2DEC	.05
		
		2DEC	.083333333
		
		2DEC	.14285714
		
		2DEC	.25
		
		2DEC	.44444444
		
		2DEC	.8
		
		CAF	ZERO
		
## Page 938
		TS	MPAC	+2
		EXTEND
		DCA	LN2/128
		DXCH	MPAC		# MPAC,+1 CONTAINS LN2/128
		DXCH	SPLOC	+1	# SPLOC+1,+2 CONTAINS LN(1/2-ARGS)/128
		CA	SPLOC
		TC	SHORTMP
		DXCH	MPAC	+1
		DXCH	MPAC		# MPAC CONTAINS (10-N1)LN2/128
		DXCH	SPLOC	+1	# A,L CONTAIN LN(1/2-ARGS)/128
		EXTEND
		DCOM
		DAS	MPAC
		TC	INTPRET
		SR
			5
		STORE	0D		# 0D=DELG (+12)			 PL AT 6D
		RVQ
		
		
COGDSOVF	DLOAD	GOTO
			BIGNO		# BIGNO=NEARONE-DP1/1024
			COGDSTOR
# RETURNS WITH 0D=DELE (+3) OR DELG(+12),,2D=SND (+1 OR +10),4D=1-CSD (+1
# OR +10), AND PUSHLOC AT 6D

## Page 939
# ASSUMES 14D=R1A (+6), 32D= R1 (+7)
SMA		DLOAD	NORM		# THIS IS ESSENTIALLY A FLOATING POINT SUB
			14D		# C(SPLOC+1)=-N1
			SPLOC	+1	# SPLOC LATER WILL BE STORED IN X1 FOR SHF
		PDDL	NORM
			32D
			SPLOC		# C(SPLOC)=-N2
		SR1	DDV
		ABS	EXIT		# ABS(R1/R1A) (+2+N1-N2)
		CS	SPLOC	+1
		AD	SPLOC
		TS	SPLOC
		TS	CYR
		CA	CYR
		DOUBLE
		OVSK
		TCF	EVEN
ODD		CA	ONE
		TCF	STORETAG
EVEN		CA	ZERO
STORETAG	TS	SPLOC	+1	# A TAG TO DESIGNATE ADDITIONAL SHIFTRIGHT
		ADS	SPLOC		# C(SPLOC)=N1-N2+0 OR 1
		CA	SPLOC
		TS	SR
		AD	SR
		TS	SPLOC		# C(SPLOC)=3(N1-N2+0 OR 1)/2
		TC	INTPRET
		LXC,1	SR*
			SPLOC	+1
			0,1
		PUSH	LXA,2		# ABS(R1/R1A) (+2+N1-N2+0 OR 1)  PL DOWN 2
			SPLOC		# C(X2)=+3(N1-N2+0 OR 1)/2
		SQRT	DMP		# ARG TO THE 3/2 POWER,SCALED +3+(3/2)(N1
					# -N2 +0 OR 1)			 PL UP 2
		BOFF	DMP
			MOONSW
			+2
			ROOTMU
		STORE	12D		# 12D=SQRT(ABS(R1/R1A))ABS(R1/R1A)
		RVQ			# SCALED (+3 OR +7)+(3/2)(N1-N2+0 OR 1)
# SMA TO THE 3/2 POWER * ROOTMU IN 12D.
# IF LSW1 SET, INSIDE SPHERE AND 12D SCALED +7+C(X2)
# IF LSW1 OFF, OUTSIDE SPHERE AND 12D SCALED +3+C(X2)


## Page 940
# THIS IS KEPLERS EQUATION FOR TIME-OF-FLIGHT BETWEEN TWO POINTS ON A
# CONIC TRAJECTORY.  IT ASSUMES R1A (+6)=14D, P (+2)=34D, 1-CSD (+1,+10,-2
# =4D, SND (+1,+10,-2)=2D, D (+3,+12,0)=0D.

DELTIME		DLOAD	DMP		#				 PL AT 6D
			34D
			14D
		SL	BOV
			6
			SPEEDY
		ABS	SQRT
		DMP			#				 PL AT 4D
		DMP	TLOAD
			INDEP
			MPAC		# CHANGES MODE TO TP (00001).
		PDDL	DSU		# SQRT(P ABS(R1A))(1-CSD)COGA (+7 OR 16)
			14D		#				 PL AT 7D
			D1/64
		DMP
			2D
		TLOAD	PDDL		# (R1A-1)SND (+7 OR16)
			MPAC		# CHANGES MODE TO TP		 PL AT 10D
			0D
		SR4	TAD		# PL PUSHES UP 3 SINCE TAD GOVERNS INSTEAD
		TAD			# OF MODE. MODE REMAINS DP.	 PL AT 7D,4D
		NORM	SIGN
			X1
			14D
		DMP	XAD,1		# T (+(3 OR 7)+C(X2)+(7 OR 16)+C(X1))
			12D
			X2
		BON
			SMANGLSW
			THETASM
		BOFF	BOFF
			MOONSW
			NEARERTH
			ESCPSW
			+4
		SR*	GOTO
			0	-13D,1
			TMESTORE
		SR*	GOTO
			0	-4,1
			TMESTORE
NEARERTH	BOFF	SR*
			ESCPSW
			+4
			0	-9D,1
		GOTO
## Page 941
			TMESTORE
		SR*
			0,1
TMESTORE	BOV
			TIMELONG
		STORE	12D		# 12D=T (+10)
		SETPD	RVQ
			0D
			
			
THETASM		BOFF	SL4		# T (+7 +C(X1))
			ITERSW
			ERTHSFER
ERTHSFER	SR*	GOTO
			3,1
			TMESTORE
			
TIMELONG	DLOAD	GOTO
			NEARI
			TMESTORE +2
			
			
# T (+10) IN 12D  AND IN MPAC.


## Page 942
# THIS IS A GENERAL NEWTON ITERATOR WHEREIN A STARTING INDEPENDENT VARIABL
# IS INPUT AND THE CHANGE IN THE INDEPENDENT VARIABLE IS OUTPUT.  THE
# BOUNDS OF THE INDEPENDENT VARIABLE,MAXINDEP AND MININDEP, MUST BE AVAILA
# BLE AND SWITCH 7 MUST BE SET.  IF A GOOD GUESS TO INDEP IS KNOWN,
# TWEEKIT SHOULD BE SET TO A SMALL FRACTION,DEPENDING ON HOW WELL INDEP IS
# KNOWN.  OTHERWISE THE FIRST GUESS TO INDEP SHOULD BE .5(MAXINDEP+MININ-
# DEP) AND TWEEKIT SHOULD BE SET TO .25. IT IS ASSUMED THAT THE CRITERIA
# FOR EXITING FROM THE CALLING PROGRAMS LOOP IS IN THE CALLING PROGRAM.
# THE DEPENDENT VARIABLE MUST BE IN DEPVAR AND THE PREVIOUS ONE MUST BE IN
# PREVDEP.  THE SIGN OF TWEEKIT SOULD BE +/- ACCORDING TO WHETHER THE
# SINGLE-VALUED FUNCTION IS MONOTONICLY INCREASING OR DECREASING.


ITERATOR	BONCLR	DLOAD
			ITERSW
			FRSTTIME
			DEPVAR
		DSU	NORM
			PREVDEP
			X1
		PDDL	SR1		#				 PL DOWN 2
			DELDEP
		DDV			#				 PL UP 2
		DMP	SL*
			DELINDEP
			1,1
NEWDELTA	STORE	DELINDEP
		BMN	DLOAD		# NOW MUST CHECK TO SEE IF THIS DELTA CAN
			MINCHECK	# CAUSE THE INDEPENDENT VARIABLE TO EXCEED
			MAXINDEP	# ITS LIMITS.
		DSU	DSU
			INDEP
			DELINDEP
		BOV	BMN
			XEEDULMT
			XEEDULMT
		DLOAD	RVQ
			DELINDEP
			
			
FRSTTIME	DLOAD	DMP
			MININDEP
			TWEEKIT		# TWEEKIT SHOULD BE SET  .25  IF THE FIRST
					# GUESS OF INDEP WAS .5(MAXINDEP+MININDEP)
		PDDL	DMP		#				 DOWN 2D
			MAXINDEP
			TWEEKIT
		DSU			#				 UP 2D	
## Page 943
		SIGN	GOTO
			DELDEP
			NEWDELTA
MINCHECK	DLOAD	DSU
			MININDEP
			INDEP
		DSU	BOV
			DELINDEP
			XEEDLLMT
		BPL	DLOAD
			XEEDLLMT
			DELINDEP
		RVQ
		
		
XEEDULMT	DLOAD	DSU
			MAXINDEP
			INDEP
		STORE	DELINDEP
		RVQ
		
		
XEEDLLMT	DLOAD	DSU
			MININDEP
			INDEP
		STORE	DELINDEP
		RVQ
	
		
## Page 944
# ASSUMES 32D=R (+7), 34D=P (+2), TAG5 (+/-), 18D=COGA (+5), UNR1 (+1), R2
# VEC (+7) AVAILABLE.
INITV		DLOAD	NORM
			32D
			X1
		PDDL	SR1		# R1 (+7-N1)			 PL AT 2D
			34D
		DDV			# P/R1 (-4+N1)			 PL AT 0D
		BOFF	DMP
			MOONSW
			OUTSIDE
			MU
		SL*	GOTO
			0	-12D,1
			MAGVTAN
OUTSIDE		SL*
			0	-6,1
MAGVTAN		SQRT	PDVL		# V SIN(GAMMA) (+1)		 PL AT 2D

			UNR1
		VXSC	PDVL		# 2D=COGA UNR1 (+6)		 PL AT 8D
			18D
			UNNORM
		VXV	VSR4		# UNVTAN (+6)
			UNR1
		VAD	VXSC		#				 PL AT 2D,0D
		VXSC	VSL7
			VFACT		# SCALE FOR ASCENT STEERING AT +7
		STORE	V0VEC
		RVQ
		
# RETURNS WITH VELOCITY IN MPAC AND IN V0VEC SCALED (+1)


## Page 945
D1/1024		2DEC	.5	B-9

D1/64		2DEC	.5	B-5

D1/32		2DEC	.5	B-4

D1/4		2DEC	.5	B-1

D1/2		2DEC	.5

## The following line is "NEARZERO 2OCT B0" in the original program listing, but the yaYUL
## assembler does not syntactically support a bare exponent like "B0" in the operand,
## so it has been replaced by a numerical equivalent that the assembler does support. 
NEARZERO	2OCT	1

NEARI		2OCT	3777737777

BIGNO		2OCT	3775737777

PERCENT		2DEC	E-3

LN2/128		2DEC	.693147181 B-7

ROOTMU		2DEC	9.0249769 B-4

MU		2DEC	.0122774395 B+6

ABSOLMIN	2DEC	-.999511590

VFACT		2DEC	.761606218

TFACT		EQUALS	VFACT
DEPCRIT		2DEC	1.135	E-7	# 50 MS. SCALED BY TNORM
