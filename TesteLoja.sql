create database loja;
use loja;

create table produto(
cod_prod int not null auto_increment,
desc_prod varchar(20) not null,
qtd int not null,
primary key(cod_prod));

drop table produto;

create table venda(
num_nota int not null auto_increment,
cod_prod int not null,
qtd_vendida int not null,
primary key (num_nota));

create table compra(
num_compra int not null auto_increment,
desc_prod varchar(20) not null,
qtd_comp int not null,
primary key(num_compra));

drop table produto;
drop table venda;
drop table compra;

insert into produto(desc_prod,qtd)
values('lapis', 20);

select * from produto;


delimiter $$
create trigger atualiza_venda after insert on venda for each row
begin
update produto set qtd = qtd - new.qtd_vendida where cod_prod = new.cod_prod;
end $$

drop trigger atualiza_venda;

select * from venda;

insert into venda(cod_prod, qtd_vendida) 
values(2, 3);

delete from venda where cod_prod = 1;

delimiter $$
create trigger atualiza_compra after insert on compra for each row
begin
update produto set qtd = qtd + new.qtd_comp where produto.cod_prod = new.cod_prod;
end $$

select * from produto;

drop trigger atualiza_compra;

select * from compra;

insert into compra(desc_prod, qtd_comp)
values('lapis', 10);

/*create table copiaproduto(          //Auditoria, essa parte pode ser ignorada
codigo int,
dsc_prod varchar(20),
qtd int,
data_atual date);

delimiter $$
create trigger auditoria before update on produto for each row
begin
if new.dsc_prod <> old.dsc_prod
	insert into copiaproduto(codigo, dsc_prod, qtd)
		values(old.codigo,old.
end if
end*/

