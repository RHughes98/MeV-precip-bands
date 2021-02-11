function [response] = getPBinput()

% collect user evaluation
response = input('Does this look like a precipitation band?\n','s');

switch response
    case {'Y','y'}
        response = 1;
    case {'N','n'}
        response = 0;
    otherwise
        warning('Unexpected input. Response must be Y or N.')
        getPBinput()
end

end