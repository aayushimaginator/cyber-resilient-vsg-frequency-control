import numpy as np
from scipy.integrate import solve_ivp
n=4
E=np.array([[1,0,0],[-1,1,0],[0,-1,1],[0,0,-1]],float)
M=np.diag([1000.]*4); D=np.diag([13880.]*4)
Phi=np.diag([2e4,2e4,2e4])
psi=np.array([0.10,-0.05,0.08])
Pnet=E@Phi@np.sin(psi)
Minv=np.linalg.inv(M)
def run(beta,Kc,Hc,atk,scale=1.0,T=15,dP=0.0,mask=(1,1)):
    K=Kc*np.eye(n); H=Hc*np.eye(n)
    def att(t):
        if t<5 or t>12: return np.zeros(8)
        if atk=='sin':
            du=np.array([8*np.sin(t),7*np.sin(t+np.pi/2),5*np.sin(t+np.pi/3),3*np.sin(t+np.pi/2)])
            dx=np.array([10*np.sin(t),8.75*np.sin(t+np.pi/2),6.25*np.sin(t+np.pi/3),3.75*np.sin(t+np.pi/2)])
        elif atk=='bias':
            du=np.array([8,7,5,3.]); dx=np.array([10,8.75,6.25,3.75])
        elif atk=='square':
            s=np.sign(np.sin(2*np.pi*t/4))
            du=s*np.array([8,7,5,3.]); dx=s*np.array([10,8.75,6.25,3.75])
        return scale*np.r_[mask[0]*du,mask[1]*dx]
    def f(t,x):
        th,w,xi=x[:4],x[4:8],x[8:]
        a=att(t); P=Pnet.copy(); 
        if t>=2: P[3]+=dP
        dw=Minv@(-D@w+P-E@Phi@np.sin(E.T@th)+beta*K@xi+a[:4])
        dxi=-H@xi-beta*K.T@w+a[4:]
        return np.r_[w,dw,dxi]
    x0=np.r_[np.linalg.lstsq(E.T,psi,rcond=None)[0],np.zeros(8)]
    s=solve_ivp(f,[0,T],x0,method='LSODA',max_step=0.01,rtol=1e-8,atol=1e-10)
    return s
