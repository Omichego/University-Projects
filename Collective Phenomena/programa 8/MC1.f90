IMPLICIT NONE
integer*4 SEED,i,j,L,MCTOT,n,m,npas,DE
real*8 genrand_real2,E,energia,mag,magne,temp,x,y,delta,u,ebis,W(-8:8)
integer*2,allocatable:: S(:,:)
integer*4,allocatable:: PBC(:)

L=32
MCTOT=1000
npas=L*L
temp=1.1d0
allocate(S(1:L,1:L))
allocate(PBC(0:L+1))
SEED=76543

PBC(0)=L
PBC(L+1)=1
do i=1,L
PBC(i)=i
enddo

do DE=-8,8
W(DE)=exp(-dfloat(DE)/temp)
enddo

call init_genrand(SEED)

do i=1,L
do j=1,L
if (genrand_real2().lt.0.5D0) then
S(i,j)=1
else
S(i,j)=-1
endif
enddo
enddo

E=energia(S,L,PBC)
!ALGORITME DE METRÓPOLIS
do n=1,MCTOT

do m=1,npas
x=genrand_real2()
y=genrand_real2()
i=int(L*x)+1
j=int(L*y)+1

DE=2*S(I,J)*(S(PBC(I+1),J)+S(PBC(I-1),J)+S(I,PBC(J+1))+S(I,PBC(J-1)))

if (DE.le.0d0) then

E=E+DE
S(i,j)=-S(i,j)

else if (genrand_real2().le.W(DE)) then

E=E+DE
S(i,j)=-S(i,j)


endif
enddo


enddo

ebis=energia(S,L,PBC)
mag=magne(S,L)
print*,E,ebis,mag
END



!FUNCIO ENERGIA
real*8 function energia(S,L,PBC)
integer*4 I,J,L
integer*2 S(1:L,1:L)
integer*4 PBC(0:L+1)
real*8 ene
ene=0.0D0
do I =1,L
do J=1,L
ene=ene-S(i,j)*S(PBC(i+1),j)-S(i,j)*S(i,PBC(j+1))
enddo
enddo
energia=ene
return
END

SUBROUTINE energ(S,L,PBC,E)
integer*4 i,j,L
integer*2 S(1:L,1:L)
integer*4 PBC(0:L+1)
real*8 E
E=0.0D0
do I =1,L
do J=1,L
E=E-S(i,j)*S(PBC(i+1),i)-S(i,j)*S(i,PBC(j+1))
enddo
enddo
return
END

!FUNCIO MAGNETITZACIÓ
real*8 function magne(S,L)
integer L,i,j
integer*2 S(1:L,1:L)
real*8 mag
mag=0d0
do i=1,L
do j=1,L
mag=mag+S(i,j)
enddo
enddo
magne=mag
return
end



!GENERADOR
subroutine init_genrand(s)
      integer s
      integer N
      integer DONE
      integer ALLBIT_MASK
      parameter (N=624)
      parameter (DONE=123456789)
      integer mti,initialized
      integer mt(0:N-1)
      common /mt_state1/ mti,initialized
      common /mt_state2/ mt
      common /mt_mask1/ ALLBIT_MASK

      call mt_initln
      mt(0)=iand(s,ALLBIT_MASK)
      do 100 mti=1,N-1
        mt(mti)=1812433253*ieor(mt(mti-1),ishft(mt(mti-1),-30))+mti
        mt(mti)=iand(mt(mti),ALLBIT_MASK)
  100 continue
      initialized=DONE

      return
      end

      subroutine init_by_array(init_key,key_length)
      integer init_key(0:*)
      integer key_length
      integer N
      integer ALLBIT_MASK
      integer TOPBIT_MASK
      parameter (N=624)
      integer i,j,k
      integer mt(0:N-1)
      common /mt_state2/ mt
      common /mt_mask1/ ALLBIT_MASK
      common /mt_mask2/ TOPBIT_MASK

      call init_genrand(19650218)
      i=1
      j=0
      do 100 k=max(N,key_length),1,-1
        mt(i)=ieor(mt(i),ieor(mt(i-1),ishft(mt(i-1),-30))*1664525)+init_key(j)+j
        mt(i)=iand(mt(i),ALLBIT_MASK)
        i=i+1
        j=j+1
        if(i.ge.N)then
          mt(0)=mt(N-1)
          i=1
        endif
        if(j.ge.key_length)then
          j=0
        endif
  100 continue
      do 200 k=N-1,1,-1
        mt(i)=ieor(mt(i),ieor(mt(i-1),ishft(mt(i-1),-30))*1566083941)-i
        mt(i)=iand(mt(i),ALLBIT_MASK)
        i=i+1
        if(i.ge.N)then
          mt(0)=mt(N-1)
          i=1
        endif
  200 continue
      mt(0)=TOPBIT_MASK

      return
      end


      function genrand_int32()
      integer genrand_int32
      integer N,M
      integer DONE
      integer UPPER_MASK,LOWER_MASK,MATRIX_A
      integer T1_MASK,T2_MASK
      parameter (N=624)
      parameter (M=397)
      parameter (DONE=123456789)
      integer mti,initialized
      integer mt(0:N-1)
      integer y,kk
      integer mag01(0:1)
      common /mt_state1/ mti,initialized
      common /mt_state2/ mt
      common /mt_mask3/ UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      common /mt_mag01/ mag01

      if(initialized.ne.DONE)then
        call init_genrand(21641)
      endif

      if(mti.ge.N)then
        do 100 kk=0,N-M-1
          y=ior(iand(mt(kk),UPPER_MASK),iand(mt(kk+1),LOWER_MASK))
          mt(kk)=ieor(ieor(mt(kk+M),ishft(y,-1)),mag01(iand(y,1)))
  100   continue
        do 200 kk=N-M,N-1-1
          y=ior(iand(mt(kk),UPPER_MASK),iand(mt(kk+1),LOWER_MASK))
          mt(kk)=ieor(ieor(mt(kk+(M-N)),ishft(y,-1)),mag01(iand(y,1)))
  200   continue
        y=ior(iand(mt(N-1),UPPER_MASK),iand(mt(0),LOWER_MASK))
        mt(kk)=ieor(ieor(mt(M-1),ishft(y,-1)),mag01(iand(y,1)))
        mti=0
      endif

      y=mt(mti)
      mti=mti+1

      y=ieor(y,ishft(y,-11))
      y=ieor(y,iand(ishft(y,7),T1_MASK))
      y=ieor(y,iand(ishft(y,15),T2_MASK))
      y=ieor(y,ishft(y,-18))

      genrand_int32=y
      return
      end

      function genrand_int31()
      integer genrand_int31
      integer genrand_int32
      genrand_int31=int(ishft(genrand_int32(),-1))
      return
      end

      function genrand_real1()
      double precision genrand_real1,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real1=r/4294967295.d0
      return
      end

      function genrand_real2()
      double precision genrand_real2,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real2=r/4294967296.d0
      return
      end

      function genrand_real3()
      double precision genrand_real3,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real3=(r+0.5d0)/4294967296.d0
      return
      end

      function genrand_res53()
      double precision genrand_res53
      integer genrand_int32
      double precision a,b
      a=dble(ishft(genrand_int32(),-5))
      b=dble(ishft(genrand_int32(),-6))
      if(a.lt.0.d0)a=a+2.d0**32
      if(b.lt.0.d0)b=b+2.d0**32
      genrand_res53=(a*67108864.d0+b)/9007199254740992.d0
      return
      end

      subroutine mt_initln
      integer ALLBIT_MASK
      integer TOPBIT_MASK
      integer UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      integer mag01(0:1)
      common /mt_mask1/ ALLBIT_MASK
      common /mt_mask2/ TOPBIT_MASK
      common /mt_mask3/ UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      common /mt_mag01/ mag01


      TOPBIT_MASK=1073741824
      TOPBIT_MASK=ishft(TOPBIT_MASK,1)
      ALLBIT_MASK=2147483647
      ALLBIT_MASK=ior(ALLBIT_MASK,TOPBIT_MASK)
      UPPER_MASK=TOPBIT_MASK
      LOWER_MASK=2147483647
      MATRIX_A=419999967
      MATRIX_A=ior(MATRIX_A,TOPBIT_MASK)
      T1_MASK=489444992
      T1_MASK=ior(T1_MASK,TOPBIT_MASK)
      T2_MASK=1875247104
      T2_MASK=ior(T2_MASK,TOPBIT_MASK)
      mag01(0)=0
      mag01(1)=MATRIX_A
      return


END

