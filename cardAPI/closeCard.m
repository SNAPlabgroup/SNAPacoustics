function closeCard(card)

% Clear circuit configuration from RZ6
invoke(card.RZ, 'ClearCOF');

% Close activeX window
close(card.f1RZ);

