% Mulhauser remy
% Wolkowicz michel

:- op(20,xfy,?=).

% Pr仕icats d'affichage fournis

% set_echo: ce pr仕icat active l'affichage par le pr仕icat echo
set_echo :- assert(echo_on).

% clr_echo: ce pr仕icat inhibe l'affichage par le pr仕icat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionn�, echo(T) affiche le terme T
%          sinon, echo(T) r志ssit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).
