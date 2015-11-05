function touri_methods_hw4

%{
Q4:
a) Generate N=1000 iid uniformly random variables on [0,1] and compute the
empirical average Ak of the first k numbers plot A_k as a function of k

b)Repeat part (a) 100 times and plot corresponding empirical avgs as a
function of k in one-plot

c) Repeate (a) and (b) and average by sqrt(k)

%}

N = 1000;

for iter = 1:100
X = rand(1,N);
A = X;
B = zeros(size(X);
for i = 2:N
    A(i) = A(i) + A(i-1);
    empAvg(i) = 1/i;
    sqrtAvg(i) = 1/sqrt(i);
end
empAvg_A(iter,:) = A.*empAvg;
sqrtAvg_A(iter,:) = A.*sqrtAvg;
end
fig1 = figure(1)
subplot(2,2,1)
plot(empAvg_A)
subplot(2,2,2)
plot(sqrtAvg_A)
