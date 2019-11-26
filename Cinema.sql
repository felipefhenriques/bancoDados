use sakila;
select count(*) from rental;
select * from rental A, customer B where A.customer_id = B.customer_id order by rental_id;

select A.rental_id, A.customer_id, B.first_name from rental A, customer B 
where A.customer_id = B.customer_id order by rental_id;

select A.rental_id, A.customer_id, B.first_name from rental A, customer B 
where A.customer_id = B.customer_id and b.customer_id = 130 order by rental_id;

select rental.rental_id as 'Código da locação', rental.customer_id, customer.first_name 
from rental 
inner join customer 
on rental.customer_id = customer.customer_id 
and customer.customer_id = 130;

select rental.rental_id as 'Código da locação', rental.customer_id, customer.first_name,
inventory.film_id, film.title, film_category.category_id 
from rental 
inner join customer on rental.customer_id = customer.customer_id 
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
and customer.customer_id = 130;

select * from rental;
select * from payment;
-- O que está em comum entre esses dois é o rental_id, logo

create view /*caso queria alterar, é possível usar o 'or replace' após o create view*/ venda as 
/* é possível usar apenas o select para essas informações, mas criando
o view é possível referencia-la posteriormente apenas como "select * from venda" */
select rental.rental_id, rental.customer_id, amount, customer.first_name
from rental 
inner join payment on rental.rental_id = payment.rental_id
inner join customer on rental.customer_id = customer.customer_id;

select * from venda;

select first_name, count(*), sum(amount) from venda group by first_name;

create or replace view venda_staff as
select rental.rental_id, staff.staff_id, staff.first_name, amount 
from rental
inner join payment on rental.rental_id = payment.rental_id
inner join staff on rental.staff_id = staff.staff_id;

select staff_id, first_name, count(*) as 'Quantidade de vendas',
 sum(amount) as 'Valor de vendas' from venda_staff
group by staff_id;

create or replace view compras as
select rental.rental_id, amount * 0.05 as 'Reajuste', rental.customer_id
from rental
inner join payment on rental.rental_id = payment.rental_id;

select * from compras;

create or replace view clientesPais as
select count(*) as clientes, country.country as 'País'
from customer
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
group by country;

select * from clientesPais;


CREATE OR REPLACE VIEW pais_cliente AS
SELECT country.country AS Pais, COUNT(*) AS Clientes
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city
ON city.city_id = address.city_id
INNER JOIN country
ON country.country_id = city.country_id
GROUP BY country;

create or replace view idiomaFilme as
select language.name as 'Língua', count(*) as 'Quantidade filmes'
from film
inner join language on film.language_id = language.language_id
group by 'Língua';

SELECT * FROM pais_cliente;

select * from payment where payment_id = 3;




delimiter $$
create function valor(wid int(10))
returns decimal(10,2)
deterministic
begin 
declare wvalor decimal (10,2);
select amount into wvalor from payment where payment_id = wid;
return wvalor;
end;

select valor(5) as 'Valor pagamento';

select * from payment;

delimiter $$
create function comissao(wID int(10))
returns decimal (10,2)
deterministic
begin
declare wvalor decimal(10,2);
declare wretorno decimal (10,2);
select amount into wvalor from payment where payment_id = wID;
set wretorno = wvalor * 0.05;
return wretorno;
end;

 drop function comissao;
 
select comissao(9) as 'Comissão de 5%';

delimiter %%
create function comissaoTexto(parametro int(10))
returns varchar(255)
deterministic
begin
declare wvalor decimal(10,2);
declare wcomissao decimal(10,2);
declare texto varchar (255);
select amount into wvalor from payment where payment_id = parametro;
set wcomissao = wvalor *0.05;
set texto = concat('Para o pagamento de ', wvalor, ' a comissão é ', wcomissao);
return texto;
end;

drop function comissaoTexto;

select comissaoTexto(9) as 'Comissão em texto';

delimiter %%
create function comissaoNome(parametro int(10))
returns varchar(255)
deterministic
begin
declare wvalor decimal(10,2);
declare wcomissao decimal (10,2);
declare wnomefunc varchar(50);
declare texto varchar (255);
select amount into wvalor from payment where payment_id = parametro;
select staff.first_name into wnomefunc from payment
    inner join staff on payment.staff_id = staff.staff_id
    where payment_id = parametro;
set wcomissao = wvalor *0.05;
set texto = concat('Para o pagamento de ', wvalor, ' a comissão de ', wnomefunc, ' é ', wcomissao);
return texto;
end;

drop function comissaoNome;

select comissaoNome(9) as 'Comissao com nome';

delimiter %%
create function comissaoIF(parametro int(10))
returns varchar(255)
deterministic
begin
declare wvalor decimal(10,2);
declare wcomissao decimal (10,2);
declare wnomefunc varchar(50);
declare texto varchar (255);
select amount into wvalor from payment where payment_id = parametro;
select staff.first_name into wnomefunc from payment
    inner join staff on payment.staff_id = staff.staff_id
    where payment_id = parametro;


if wvalor > 5 then set wcomissao = wvalor *0.03;
else set wcomissao = wvalor*0.03;
end if;
set texto = concat('Para o pagamento de ', wvalor, ' a comissão de ', wnomefunc, ' é ', wcomissao);
return texto;
end;

drop function comissaoIF;

select comissaoIF(8);

delimiter $$
create function acessivel(valor decimal(10,2))
returns varchar(3)
deterministic
begin
declare aces varchar (6);
declare valor decimal (10,2);
select amount into valor from film_list.price;
if valor > 3 then set aces = 'Sim';
else aces = 'Não';
end if;
return aces;
end;

delimiter $$
create procedure listagem1(pesquisa varchar(50))
begin
select first_name from actor 
where first_name like pesquisa
order by first_name;

end;$$

drop procedure listagem1;

call listagem1('%F');

delimiter $$
create procedure listagem2(pesquisa varchar(50))
begin 
select concat(last_name,', ', first_name) as 'Nome completo' from actor
where first_name like pesquisa
order by first_name;
end;
$$

drop procedure listagem2;

call listagem2('%');

delimiter $$
create procedure listagem3(tipo int, pesquisa varchar(50))
begin 
if tipo = 1 then
select concat(last_name,', ', first_name) as 'Nome completo' from actor
where first_name like pesquisa
order by last_name;
else
select concat(first_name,' ', last_name) as 'Nome completo' from actor
where first_name like pesquisa
order by first_name;
end if;
end;
$$

drop procedure listagem3;

call listagem3(1, '%');
call listagem3(0, '%');



delimiter $$
create procedure listagem4(tipo int)
begin
declare atividade varchar(10);
if tipo = 1 then
set atividade = 'ativo(a)';
else if tipo = 0 then
     set atividade = 'inativo(a)'; 
     end if;
end if;
select concat(last_name, ', ', first_name, ' está ', atividade) as 'Atividade cliente' from customer
where active like tipo order by last_name;
end;
$$ 

drop procedure listagem4;

call listagem4(0);

