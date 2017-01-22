%% biphaseL()

msg1 = 1;
enc1 = [1 0];

msg2 = 0;
enc2 = [0 1];

msg3 = [1 0];
enc3 = [1 0 0 1];

assert(isequal(biphaseL(msg1,'encode'),enc1))
assert(isequal(biphaseL(msg2,'encode'),enc2))
assert(isequal(biphaseL(msg3,'encode'),enc3))

assert(isequal(biphaseL(enc1,'decode'),msg1))
assert(isequal(biphaseL(enc2,'decode'),msg2))
assert(isequal(biphaseL(enc3,'decode'),msg3))

disp('biphaseL() tests passed!')
