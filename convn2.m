function B = convn2(A,k)
nanmsk = isnan(A);
A(nanmsk) = 0;
B = convn(A,k,'same')./convn(~nanmsk,k,'same');
