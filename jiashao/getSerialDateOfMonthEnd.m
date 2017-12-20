function serialDate = getSerialDateOfMonthEnd(year, month, bi)

% calculate the days in the given year
for m = 1 : length(month)
    serialDate(m) = sum(eomday(year, month(1:m)));
end

if bi == 1
    % plus serial number of the year
    serialDate = serialDate + datenum(num2str(year), 'yyyy');
end

end