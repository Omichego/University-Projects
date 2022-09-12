      PROGRAM MAIN                                                     
      IMPLICIT REAL*8(A-H,O-Z)
      dimension xr(1000),frev(1000),freo(1000),fred(1000),xmu(1000),
     1  fren(1000),den(1000),u(1000)
C     AA=10000. NUmber of atoms
c     N1 numbre of integration steps in r-grid
c     step, integration step in r-space
c     a0 scattering length in h.o. units
c     alpha , the starting parameter for the h.o. function
c     time , the step in time
c     iter, number of iterations

c     se abre un fichero des del que se leen los parámetros
c     del problema, y otro en el que se escribirá el resultado
      open(12,file="input.dat")
      open(13,file="output.dat")
      read(12,*)a0,n1,step,aa,time,alpha,iter
 340  format(2d15.5)
      WRITE(6,1000)AA,N1,step,a0,ALPHA,time,iter
 1000 FORMAT(/5X,'* ',F10.0,' BOSONS IN A SPHERICAL TRAP *'/               
     1 5X,'* r-GRID IN N1=',I4,' POINTS', ' r-step',f8.3/
     1 5X,'* A0=',E12.4,2X,' ALPHA=',E12.4/
     1 5x,'* time=',e12.4,'  number-iter =',i8/)
c     se definen otras constantes y parámetros útiles
      pi=4.d0*DATAN(1.d0)
      piin=1.d0/(4.d0*pi)
      pi2in=dsqrt(piin)
      alpha2=alpha*alpha
      cvar=2.d0*dsqrt(alpha)**3/dsqrt(dsqrt(pi))
c     Se construye la función de onda inicial, Phi(r)=R(r)/r*Y00
      do i=1,n1
      xr(i)=step*dfloat(i-1)
      xr2=xr(i)*xr(i)
      frev(i)=1d0*cvar*xr(i)*dexp(-0.5d0*alpha2*xr2)
      freo(i)=1d0*frev(i)
      enddo
c     starting the convergence process
****************************************
c to reduce to the armonic oscillator cequ=0
************************************
      cequ=a0*aa*1d0
c     cequ controla el peso del potencial de interaccion
c     si se multiplica por cero se recupera el oscilador
c     armónico
      as3n=aa*a0*a0*a0
c     
      itw=0
      do 2340 it=1,iter
      itw=itw+1
 500     xnorm=0.d0
      ene0=0.d0
c     se calcula la derivada segunda respecto a r.
c     si se quiere eliminar el término cinético de la 
c     ecuación, hay que ponerla a 0
      do i=2,n1-1
      fred(i)=0d0*(freo(i-1)+freo(i+1)-2.d0*freo(i))/(step*step)
      enddo
      fred(n1)=0d0*(freo(n1-1)-2.d0*freo(i))/(step*step)
      
c     se inicia el algoritmo de convergencia
      do i=1,n1
      xr2=xr(i)*xr(i)
      if(i .eq. 1)then
      xmu(i)=1.d0
      else 
c     equación de Gross-Pitaevskii:   
      ene0=ene0-freo(i)*fred(i)*0.5d0*1d0
     1 +0.5d0*xr2*freo(i)*freo(i)
     1 +0.5d0*cequ*xr2*(freo(i)/xr(i))**4
      xmu(i)=-0.5d0*fred(i)/freo(i)*1d0
     1 +0.5d0*xr2+cequ*(freo(i)/xr(i))**2
      endif
      fren(i)=(freo(i)-time*xmu(i)*freo(i))*1d0
      xnorm=xnorm+fren(i)*fren(i)
      enddo
      xnorm=dsqrt(xnorm*step)
      ene0=ene0*step
c     cada 200 iteraciones se escribe el valor de la energía
      if (itw .eq. 200)then
      write(6,*) 'ene0 =',ene0
      itw=0
      endif
c     se define la nueva función de onda
      do i=1,n1
      freo(i)=fren(i)/xnorm   
      enddo
      if ( it .eq. iter)then
      write(10,340)(xr(i),xmu(i),i=2,n1)
      else
      endif
 2340 continue    
c     calculation ofthe radious, potential and kinetic energy, density and 
c     single particle potential
      do i=2,n1-1
      fred(i)=0d0*(freo(i-1)+freo(i+1)-2.d0*freo(i))/(step*step)
      enddo
      fred(n1)=0d0*(freo(n1-1)-2.d0*freo(i))/(step*step)

      radious=0.d0
      xkin=0.d0
      potho=0.d0
      potself=0.d0
      chem=0.d0
      xaver=0.d0
      xnormden=0.d0
      do i=2,n1
      xr2=xr(i)*xr(i)
      radious=radious+xr2*freo(i)*freo(i)
      xkin=((xkin+freo(i)*fred(i)))*1d0
      poth0=poth0+xr2*freo(i)*freo(i)
      potself=potself+xr2*(freo(i)/xr(i))**4
      chem=chem+xmu(i)*freo(i)*freo(i)
      u(i)=0.5d0*xr2+cequ*(freo(i)/xr(i))**2
      den(i)=(freo(i)/xr(i))**2
      xnormden=xnormden+den(i)*xr2
      xaver=xaver+freo(i)*freo(i)*as3n*den(i)
      enddo
c     una vez terminada la convergencia se calculan las energías
c     y el potencial químico
      radious2=radious*step
      radious=dsqrt(radious*step)
      xaver=xaver*step
      chem=chem*step
      xkin=-xkin*step*0.5D0
      poth0=0.5d0*poth0*step
      potself=potself*step*cequ*0.5d0
      pot=potself+poth0
      xnormden=xnormden*step
c     se escriben los resultados por la consola y en el fichero de salida
      write(6,*) ' xnormden = ', xnormden
      write(6,740)ene0,chem,xkin,pot,poth0,potself,radious,radious2
      write(13,740)ene0,chem,xkin,pot,poth0,potself,radious,radious2
  740 FORMAT(/5X,'* ener',e12.5, '   average chemical=', e12.5/               
     1 5X,'* kin-ener=',e12.5,'     total-pot= ', e12.5,/
     1 5X,'* potho=',E12.7X,'     potint =',E12.7/
     1 5x,'* radious =',e12.4, 5x, ' radious2 =',e15.7, /)
c     se escribe un fichero con los datos de la densidad para la posterior
c     representación
      do i=2,n1
      write(10,'(2e15.5)') xr(i),den(i)
      enddo
      write(6,*) 'Virial = ',2*xkin+3*potself-2*poth0
 345  continue
      close(12)
      close(13)
      stop
      end
       
