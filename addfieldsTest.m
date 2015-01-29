function tests = addfieldsTest
tests = functiontests(localfunctions);
end

function testParameterValue(testCase)

s0 = testCase.TestData.s0;
s = struct;
s.canis.dirus = 'Dire Wolf';
s.canis.lupus = 'Grey Wolf';
s.canis.nspecies = 2;
s.homo.sapien = 'Human';
s.homo.erectus = '(Extinct)';
s.ngenus = 2;

s2 = addfields(s0,'canis.dirus','Dire Wolf','homo.erectus','(Extinct)');
assert(isequal(s,s2))
end

function testParameterValueCaseInsensitive(testCase)
s0 = testCase.TestData.s0;
s = struct;
s.canis.dirus = 'Dire Wolf';
s.canis.lupus = 'Grey Wolf';
s.canis.nspecies = 2;
s.homo.sapien = 'Human';
s.homo.erectus = '(Extinct)';
s.ngenus = 2;

s2 = addfields(s0,'canis.dirus','Dire Wolf','homo.Erectus','(Extinct)');
assert(isequal(s,s2))
end

function testCells(testCase)
s0 = testCase.TestData.s0;
s = struct;
s.canis.dirus = 'Dire Wolf';
s.canis.lupus = 'Grey Wolf';
s.canis.nspecies = 2;
s.homo.sapien = 'Human';
s.homo.erectus = '(Extinct)';
s.ngenus = 2;
s2 = addfields(s0,{'canis.dirus','homo.erectus'},{'Dire Wolf','(Extinct)'});
assert(isequal(s,s2))
end

function testStruct(testCase)
s0 = testCase.TestData.s0;
s = struct;
s.canis.dirus = 'Dire Wolf';
s.canis.lupus = 'Grey Wolf';
s.canis.nspecies = 2;
s.homo.sapien = 'Human';
s.homo.erectus = '(Extinct)';
s.ngenus = 2;

s1 = struct;
s1.canis.dirus = 'Dire Wolf';
s1.homo.erectus = '(Extinct)';

s2 = addfields(s0,s1);
assert(isequal(s,s2))
end




function setupOnce(testCase)

s0 = struct;
s0.canis.dirus = '';
s0.canis.lupus = 'Grey Wolf';
s0.canis.nspecies = 2;
s0.homo.sapien = 'Human';
s0.homo.erectus = '';
s0.ngenus = 2;

testCase.TestData.s0 = s0;

end
