function result = partial_settling_calib(value, fitting_coeff);
result = 0;
fit_order = length(fitting_coeff)-1;
for i = 1:fit_order+1
    result = fitting_coeff(i)*(value.^(i-1)) + result;
end