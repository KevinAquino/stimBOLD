function out = ybold(v,q)

V0 = 0.02;
k1 = 7*0.34;
k2 = 1.43*0.34;
k3 = 0.43;

out = V0*(k1*(1-q) + k2*(v-q) - k3*(1-v));