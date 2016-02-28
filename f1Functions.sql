-- FUNCTION IS GOOD topthree:

create or replace function
	topthree(chosenRace int) returns Table(fi varchar, se varchar, th varchar) as $$
declare
begin
	return query select a.name AS "first", b.name AS "second", c.name 
	AS "third" from drivers a, drivers b, drivers c, race 
	where race.raceId = chosenRace and a.driverId = first and b.driverId = second 
	and c.driverId = third;
end
$$ language plpgsql;

-- END OF FUNCTION



-- FUNCTION IS GOOD (we need this function for the next function 
--	because we need the driverId's and not the driver's names):

-- NEVER MIND WE DONT NEED THIS I FIXED THE ADDUSERPOINTS FUNCTION
create or replace function
	topthreeDriverId(chosenRace int) returns Table(fi int, se int, th int) as $$
declare
begin
	return query select first, second, third from race 
	where race.raceId = chosenRace;
end
$$ language plpgsql;

-- END OF FUNCTION

-- FUNCTION GOOD adduserpoints
create or replace function
	adduserpoints(rid int, uid int) returns void as $$
declare	
begin
	if ((select first from picks where userId = uid and raceId = rid) = (select first from race where raceId = rid)) then
		update "user" set score = score + 25 where userId = uid;
		
	elseif ((select second from picks where userId = uid and raceId = rid) = (select second from race where raceId = rid)) then
		update "user" set score = score + 18  where userId = uid;
		
	elseif ((select third from picks where userId = uid and raceId = rid) = (select third from race where raceId = rid)) then
		update "user" set score = score + 15 where userId = uid;
    end if;
end
$$ language plpgsql;

-- FUNCTION adddriverpoints
create or replace function
	adddriverpoints(rid int) returns void as $$
declare
begin
	update drivers set points = points + 25 where driverId = (select first from race where raceId = rid);
	update drivers set points = points + 18 where driverId = (select second from race where raceId = rid);
	update drivers set points = points + 15 where driverId = (select third from race where raceId = rid);

end;
$$ language plpgsql;

-- END OF FUNCTION

-- FUNCTION GOOD favdriverpoints
create or replace function
	favdriverpoints(uid int, rid int) returns void as $$
declare
begin
	if((select first from race where raceId = rid) = (select driverId from favDriver where userId = uid)) 
	then
		update "user" set score = score + 25 where userId = uid;
	end if;
end;
$$ language plpgsql;

-- END OF FUNCTION

-- FUNCTION GOOD favteampoints
create or replace function
	favteampoints(uid int, rid int) returns void as $$
declare
begin
	if(((select first from race where raceId = rid) = (select driver1 from team, "user" where userId = uid and team.teamId = "user".favTeam))
	 or ((select first from race where raceId = rid) = (select driver2 from team, "user" where userId = uid and team.teamId = "user".favTeam)))
	then
		update "user" set score = score + 25 where userId = uid;
	end if;
end;
$$ language plpgsql;
--END OF FUNCTION



-- FUNCTION FOR THE TRIGGER
CREATE OR REPLACE FUNCTION update_team_points()
  RETURNS trigger AS
$BODY$
BEGIN
	update team set points = points + new.points where teamId = new.team;
	RETURN NEW;
END;
$BODY$ language plpgsql;
-- END OF FUNCTION

-- TRIGGER points_update
CREATE TRIGGER points_update AFTER UPDATE ON drivers
 FOR EACH ROW 
	EXECUTE PROCEDURE update_team_points();

