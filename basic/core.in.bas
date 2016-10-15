
REM DO_FUNCTION(F, AR)
DO_FUNCTION:
  REM Get the function number
  FF=Z%(F,1)

  REM Get argument values
  R=AR+1:GOSUB DEREF_R:AA=R
  R=Z%(AR,1)+1:GOSUB DEREF_R:AB=R

  REM Switch on the function number
  IF FF>58 THEN ER=-1:ER$="unknown function"+STR$(FF):RETURN
  ON FF/10+1 GOTO DO_1_9,DO_10_19,DO_20_29,DO_30_39,DO_40_49,DO_50_59

  DO_1_9:
  ON FF GOTO DO_EQUAL_Q,DO_THROW,DO_NIL_Q,DO_TRUE_Q,DO_FALSE_Q,DO_STRING_Q,DO_SYMBOL,DO_SYMBOL_Q,DO_KEYWORD
  DO_10_19:
  ON FF-9 GOTO DO_KEYWORD_Q,DO_PR_STR,DO_STR,DO_PRN,DO_PRINTLN,DO_READ_STRING,DO_READLINE,DO_SLURP,DO_LT,DO_LTE
  DO_20_29:
  ON FF-19 GOTO DO_GT,DO_GTE,DO_ADD,DO_SUB,DO_MULT,DO_DIV,DO_TIME_MS,DO_LIST,DO_LIST_Q,DO_VECTOR
  DO_30_39:
  ON FF-29 GOTO DO_VECTOR_Q,DO_HASH_MAP,DO_MAP_Q,DO_THROW,DO_THROW,DO_THROW,DO_THROW,DO_THROW,DO_THROW,DO_SEQUENTIAL_Q
  DO_40_49:
  ON FF-39 GOTO DO_CONS,DO_CONCAT,DO_NTH,DO_FIRST,DO_REST,DO_EMPTY_Q,DO_COUNT,DO_APPLY,DO_MAP,DO_THROW
  DO_50_59:
  ON FF-49 GOTO DO_THROW,DO_THROW,DO_THROW,DO_ATOM,DO_ATOM_Q,DO_DEREF,DO_RESET_BANG,DO_SWAP_BANG,DO_EVAL

  DO_EQUAL_Q:
    A=AA:B=AB:GOSUB EQUAL_Q
    R=R+1
    RETURN
  DO_THROW:
    ER=AA
    Z%(ER,0)=Z%(ER,0)+16
    R=0
    RETURN
  DO_NIL_Q:
    R=1
    IF AA=0 THEN R=2
    RETURN
  DO_TRUE_Q:
    R=1
    IF AA=2 THEN R=2
    RETURN
  DO_FALSE_Q:
    R=1
    IF AA=1 THEN R=2
    RETURN
  DO_STRING_Q:
    R=1
    IF (Z%(AA,0)AND15)=4 THEN R=2
    RETURN
  DO_SYMBOL:
    T=5:L=Z%(AA,1):GOSUB ALLOC
    RETURN
  DO_SYMBOL_Q:
    R=1
    IF (Z%(AA,0)AND15)=5 THEN R=2
    RETURN
  DO_KEYWORD:
    A=Z%(AA,1)
    AS$=S$(A)
    IF MID$(AS$,1,1)<>CHR$(127) THEN AS$=CHR$(127)+AS$
    GOSUB STRING_
    T=4:L=R:GOSUB ALLOC
    RETURN
  DO_KEYWORD_Q:
    R=1
    IF (Z%(AA,0)AND15)<>4 THEN RETURN
    IF MID$(S$(Z%(AA,1)),1,1)<>CHR$(127) THEN RETURN
    R=2
    RETURN

  DO_PR_STR:
    AZ=AR:PR=1:SE$=" ":GOSUB PR_STR_SEQ
    AS$=R$:T=4:GOSUB STRING
    RETURN
  DO_STR:
    AZ=AR:PR=0:SE$="":GOSUB PR_STR_SEQ
    AS$=R$:T=4:GOSUB STRING
    RETURN
  DO_PRN:
    AZ=AR:PR=1:SE$=" ":GOSUB PR_STR_SEQ
    PRINT R$
    R=0
    RETURN
  DO_PRINTLN:
    AZ=AR:PR=0:SE$=" ":GOSUB PR_STR_SEQ
    PRINT R$
    R=0
    RETURN
  DO_READ_STRING:
    A$=S$(Z%(AA,1))
    GOSUB READ_STR
    RETURN
  DO_READLINE:
    A$=S$(Z%(AA,1)):GOSUB READLINE
    IF EOF=1 THEN EOF=0:R=0:RETURN
    AS$=R$:T=4:GOSUB STRING
    RETURN
  DO_SLURP:
    R$=""
    REM OPEN 1,8,2,S$(Z%(AA,1))+",SEQ,R"
    REM OPEN 1,8,2,S$(Z%(AA,1))
    OPEN 1,8,0,S$(Z%(AA,1))
    DO_SLURP_LOOP:
      A$=""
      GET#1,A$
      IF ASC(A$)=10 THEN R$=R$+CHR$(13)
      IF (ASC(A$)<>10) AND (A$<>"") THEN R$=R$+A$
      IF (ST AND 64) THEN GOTO DO_SLURP_DONE
      IF (ST AND 255) THEN ER=-1:ER$="File read error "+STR$(ST):RETURN
      GOTO DO_SLURP_LOOP
    DO_SLURP_DONE:
      CLOSE 1
      AS$=R$:T=4:GOSUB STRING
      RETURN

  DO_LT:
    R=1
    IF Z%(AA,1)<Z%(AB,1) THEN R=2
    RETURN
  DO_LTE:
    R=1
    IF Z%(AA,1)<=Z%(AB,1) THEN R=2
    RETURN
  DO_GT:
    R=1
    IF Z%(AA,1)>Z%(AB,1) THEN R=2
    RETURN
  DO_GTE:
    R=1
    IF Z%(AA,1)>=Z%(AB,1) THEN R=2
    RETURN

  DO_ADD:
    T=2:L=Z%(AA,1)+Z%(AB,1):GOSUB ALLOC
    RETURN
  DO_SUB:
    T=2:L=Z%(AA,1)-Z%(AB,1):GOSUB ALLOC
    RETURN
  DO_MULT:
    T=2:L=Z%(AA,1)*Z%(AB,1):GOSUB ALLOC
    RETURN
  DO_DIV:
    T=2:L=Z%(AA,1)/Z%(AB,1):GOSUB ALLOC
    RETURN
  DO_TIME_MS:
    R=0
    RETURN

  DO_LIST:
    R=AR
    Z%(R,0)=Z%(R,0)+16
    RETURN
  DO_LIST_Q:
    A=AA:GOSUB LIST_Q
    R=R+1: REM map to mal false/true
    RETURN
  DO_VECTOR:
    A=AR:T=7:GOSUB FORCE_SEQ_TYPE
    RETURN
  DO_VECTOR_Q:
    R=1
    IF (Z%(AA,0)AND15)=7 THEN R=2
    RETURN
  DO_HASH_MAP:
    A=AR:T=8:GOSUB FORCE_SEQ_TYPE
    RETURN
  DO_MAP_Q:
    R=1
    IF (Z%(AA,0)AND15)=8 THEN R=2
    RETURN

  DO_SEQUENTIAL_Q:
    R=1
    IF (Z%(AA,0)AND15)=6 OR (Z%(AA,0)AND15)=7 THEN R=2
    RETURN
  DO_CONS:
    T=6:L=AB:N=AA:GOSUB ALLOC
    RETURN
  DO_CONCAT:
    REM if empty arguments, return empty list
    IF Z%(AR,1)=0 THEN R=3:Z%(R,0)=Z%(R,0)+16:RETURN

    REM single argument
    IF Z%(Z%(AR,1),1)<>0 THEN GOTO DO_CONCAT_MULT
      REM force to list type
      A=AA:T=6:GOSUB FORCE_SEQ_TYPE
      RETURN

    REM multiple arguments
    DO_CONCAT_MULT:
      CZ%=X: REM save current stack position
      REM push arguments onto the stack
      DO_CONCAT_STACK:
        R=AR+1:GOSUB DEREF_R
        X=X+1:S%(X)=R: REM push sequence
        AR=Z%(AR,1)
        IF Z%(AR,1)<>0 THEN GOTO DO_CONCAT_STACK

    REM pop last argument as our seq to prepend to
    AB=S%(X):X=X-1
    REM last arg/seq is not copied so we need to inc ref to it
    Z%(AB,0)=Z%(AB,0)+16
    DO_CONCAT_LOOP:
      IF X=CZ% THEN R=AB:RETURN
      AA=S%(X):X=X-1: REM pop off next seq to prepend
      IF Z%(AA,1)=0 THEN GOTO DO_CONCAT_LOOP: REM skip empty seqs
      A=AA:B=0:C=-1:GOSUB SLICE

      REM release the terminator of new list (we skip over it)
      AY=Z%(R6,1):GOSUB RELEASE
      REM attach new list element before terminator (last actual
      REM element to the next sequence
      Z%(R6,1)=AB

      AB=R
      GOTO DO_CONCAT_LOOP
  DO_NTH:
    B=Z%(AB,1)
    A=AA:GOSUB COUNT
    IF R<=B THEN R=0:ER=-1:ER$="nth: index out of range":RETURN
    DO_NTH_LOOP:
      IF B=0 THEN GOTO DO_NTH_DONE
      B=B-1
      AA=Z%(AA,1)
      GOTO DO_NTH_LOOP
    DO_NTH_DONE:
      R=Z%(AA+1,1)
      Z%(R,0)=Z%(R,0)+16
      RETURN
  DO_FIRST:
    IF AA=0 THEN R=0:RETURN
    IF Z%(AA,1)=0 THEN R=0
    IF Z%(AA,1)<>0 THEN R=AA+1:GOSUB DEREF_R
    IF R<>0 THEN Z%(R,0)=Z%(R,0)+16
    RETURN
  DO_REST:
    IF AA=0 THEN R=3:Z%(R,0)=Z%(R,0)+16:RETURN
    IF Z%(AA,1)=0 THEN A=AA
    IF Z%(AA,1)<>0 THEN A=Z%(AA,1)
    T=6:GOSUB FORCE_SEQ_TYPE
    RETURN
  DO_EMPTY_Q:
    R=1
    IF Z%(AA,1)=0 THEN R=2
    RETURN
  DO_COUNT:
    A=AA:GOSUB COUNT
    T=2:L=R:GOSUB ALLOC
    RETURN
  DO_APPLY:
    F=AA
    AR=Z%(AR,1)
    A=AR:GOSUB COUNT:R4=R

    A=Z%(AR+1,1)
    REM no intermediate args, but not a list, so convert it first
    IF R4<=1 AND (Z%(A,0)AND15)<>6 THEN :T=6:GOSUB FORCE_SEQ_TYPE:GOTO DO_APPLY_2
    REM no intermediate args, just call APPLY directly
    IF R4<=1 THEN AR=A:GOSUB APPLY:RETURN

    REM prepend intermediate args to final args element
    A=AR:B=0:C=R4-1:GOSUB SLICE
    REM release the terminator of new list (we skip over it)
    AY=Z%(R6,1):GOSUB RELEASE
    REM attach end of slice to final args element
    Z%(R6,1)=Z%(A+1,1)
    Z%(Z%(A+1,1),0)=Z%(Z%(A+1,1),0)+16

    DO_APPLY_2:
      X=X+1:S%(X)=R: REM push/save new args for release
      AR=R:GOSUB APPLY
      AY=S%(X):X=X-1:GOSUB RELEASE: REM pop/release new args
      RETURN
  DO_MAP:
    F=AA

    REM first result list element
    T=6:L=0:N=0:GOSUB ALLOC

    REM push future return val, prior entry, F and AB
    X=X+4:S%(X-3)=R:S%(X-2)=0:S%(X-1)=F:S%(X)=AB

    DO_MAP_LOOP:
      REM set previous to current if not the first element
      IF S%(X-2)<>0 THEN Z%(S%(X-2),1)=R
      REM update previous reference to current
      S%(X-2)=R

      IF Z%(AB,1)=0 THEN GOTO DO_MAP_DONE

      REM create argument list for apply call
      Z%(3,0)=Z%(3,0)+16
      REM inc ref cnt of referred argument
      T=6:L=3:N=Z%(AB+1,1):GOSUB ALLOC

      REM push argument list
      X=X+1:S%(X)=R

      AR=R:GOSUB APPLY

      REM pop apply args are release them
      AY=S%(X):X=X-1:GOSUB RELEASE

      REM set the result value
      Z%(S%(X-2)+1,1)=R

      REM restore F
      F=S%(X-1)

      REM update AB to next source element
      S%(X)=Z%(S%(X),1)
      AB=S%(X)

      REM allocate next element
      T=6:L=0:N=0:GOSUB ALLOC

      GOTO DO_MAP_LOOP

    DO_MAP_DONE:
      REM get return val
      R=S%(X-3)
      REM pop everything off stack
      X=X-4
      RETURN

  DO_ATOM:
    T=12:L=AA:GOSUB ALLOC
    RETURN
  DO_ATOM_Q:
    R=1
    IF (Z%(AA,0)AND15)=12 THEN R=2
    RETURN
  DO_DEREF:
    R=Z%(AA,1):GOSUB DEREF_R
    Z%(R,0)=Z%(R,0)+16
    RETURN
  DO_RESET_BANG:
    R=AB
    REM release current value
    AY=Z%(AA,1):GOSUB RELEASE
    REM inc ref by 2 for atom ownership and since we are returning it
    Z%(R,0)=Z%(R,0)+32
    REM update value
    Z%(AA,1)=R
    RETURN
  DO_SWAP_BANG:
    F=AB

    REM add atom to front of the args list
    T=6:L=Z%(Z%(AR,1),1):N=Z%(AA,1):GOSUB ALLOC: REM cons
    AR=R

    REM push args for release after
    X=X+1:S%(X)=AR

    REM push atom
    X=X+1:S%(X)=AA

    GOSUB APPLY

    REM pop atom
    AA=S%(X):X=X-1

    REM pop and release args
    AY=S%(X):X=X-1:GOSUB RELEASE

    REM use reset to update the value
    AB=R:GOSUB DO_RESET_BANG

    REM but decrease ref cnt of return by 1 (not sure why)
    AY=R:GOSUB RELEASE

    RETURN

  DO_PR_MEMORY:
    P1%=ZT%:P2%=-1:GOSUB PR_MEMORY
    RETURN
  DO_PR_MEMORY_SUMMARY:
    GOSUB PR_MEMORY_SUMMARY
    RETURN

  DO_EVAL:
    A=AA:E=RE%:GOSUB EVAL
    RETURN

INIT_CORE_SET_FUNCTION:
  GOSUB NATIVE_FUNCTION
  V=R:GOSUB ENV_SET_S
  RETURN

REM INIT_CORE_NS(E)
INIT_CORE_NS:
  REM create the environment mapping
  REM must match DO_FUNCTION mappings

  K$="=":A=1:GOSUB INIT_CORE_SET_FUNCTION
  K$="throw":A=2:GOSUB INIT_CORE_SET_FUNCTION
  K$="nil?":A=3:GOSUB INIT_CORE_SET_FUNCTION
  K$="true?":A=4:GOSUB INIT_CORE_SET_FUNCTION
  K$="false?":A=5:GOSUB INIT_CORE_SET_FUNCTION
  K$="string?":A=6:GOSUB INIT_CORE_SET_FUNCTION
  K$="symbol":A=7:GOSUB INIT_CORE_SET_FUNCTION
  K$="symbol?":A=8:GOSUB INIT_CORE_SET_FUNCTION
  K$="keyword":A=9:GOSUB INIT_CORE_SET_FUNCTION
  K$="keyword?":A=10:GOSUB INIT_CORE_SET_FUNCTION

  K$="pr-str":A=11:GOSUB INIT_CORE_SET_FUNCTION
  K$="str":A=12:GOSUB INIT_CORE_SET_FUNCTION
  K$="prn":A=13:GOSUB INIT_CORE_SET_FUNCTION
  K$="println":A=14:GOSUB INIT_CORE_SET_FUNCTION
  K$="read-string":A=15:GOSUB INIT_CORE_SET_FUNCTION
  K$="readline":A=16:GOSUB INIT_CORE_SET_FUNCTION
  K$="slurp":A=17:GOSUB INIT_CORE_SET_FUNCTION

  K$="<":A=18:GOSUB INIT_CORE_SET_FUNCTION
  K$="<=":A=19:GOSUB INIT_CORE_SET_FUNCTION
  K$=">":A=20:GOSUB INIT_CORE_SET_FUNCTION
  K$=">=":A=21:GOSUB INIT_CORE_SET_FUNCTION
  K$="+":A=22:GOSUB INIT_CORE_SET_FUNCTION
  K$="-":A=23:GOSUB INIT_CORE_SET_FUNCTION
  K$="*":A=24:GOSUB INIT_CORE_SET_FUNCTION
  K$="/":A=25:GOSUB INIT_CORE_SET_FUNCTION
  K$="time-ms":A=26:GOSUB INIT_CORE_SET_FUNCTION

  K$="list":A=27:GOSUB INIT_CORE_SET_FUNCTION
  K$="list?":A=28:GOSUB INIT_CORE_SET_FUNCTION
  K$="vector":A=29:GOSUB INIT_CORE_SET_FUNCTION
  K$="vector?":A=30:GOSUB INIT_CORE_SET_FUNCTION
  K$="hash-map":A=31:GOSUB INIT_CORE_SET_FUNCTION
  K$="map?":A=32:GOSUB INIT_CORE_SET_FUNCTION
  K$="assoc":A=33:GOSUB INIT_CORE_SET_FUNCTION
  K$="dissoc":A=34:GOSUB INIT_CORE_SET_FUNCTION
  K$="get":A=35:GOSUB INIT_CORE_SET_FUNCTION
  K$="contains?":A=36:GOSUB INIT_CORE_SET_FUNCTION
  K$="keys":A=37:GOSUB INIT_CORE_SET_FUNCTION
  K$="vals":A=38:GOSUB INIT_CORE_SET_FUNCTION

  K$="sequential?":A=39:GOSUB INIT_CORE_SET_FUNCTION
  K$="cons":A=40:GOSUB INIT_CORE_SET_FUNCTION
  K$="concat":A=41:GOSUB INIT_CORE_SET_FUNCTION
  K$="nth":A=42:GOSUB INIT_CORE_SET_FUNCTION
  K$="first":A=43:GOSUB INIT_CORE_SET_FUNCTION
  K$="rest":A=44:GOSUB INIT_CORE_SET_FUNCTION
  K$="empty?":A=45:GOSUB INIT_CORE_SET_FUNCTION
  K$="count":A=46:GOSUB INIT_CORE_SET_FUNCTION
  K$="apply":A=47:GOSUB INIT_CORE_SET_FUNCTION
  K$="map":A=48:GOSUB INIT_CORE_SET_FUNCTION

  K$="with-meta":A=51:GOSUB INIT_CORE_SET_FUNCTION
  K$="meta":A=52:GOSUB INIT_CORE_SET_FUNCTION
  K$="atom":A=53:GOSUB INIT_CORE_SET_FUNCTION
  K$="atom?":A=54:GOSUB INIT_CORE_SET_FUNCTION
  K$="deref":A=55:GOSUB INIT_CORE_SET_FUNCTION
  K$="reset!":A=56:GOSUB INIT_CORE_SET_FUNCTION
  K$="swap!":A=57:GOSUB INIT_CORE_SET_FUNCTION

  K$="eval":A=58:GOSUB INIT_CORE_SET_FUNCTION

  RETURN