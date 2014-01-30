SHOW PROCESSLIST;


SET GLOBAL event_scheduler = ON;
SET @@global.event_scheduler = ON;
SET GLOBAL event_scheduler = 1;
SET @@global.event_scheduler = 1;


DROP TABLE IF EXISTS `agent_filters`;


DROP EVENT IF EXISTS clearmessagequeue;


CREATE EVENT clearmessagequeue
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
    DO
      delete from `messagequeue` where status_id = 3;
	

DROP EVENT IF EXISTS `clearerrorlog`;

CREATE EVENT `clearerrorlog`
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 7 DAY
    DO
      delete from `error_log`;
	
	
DROP EVENT IF EXISTS `archivezitlog`;

CREATE EVENT `archivezitlog`
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 DAY
    DO
      update `zit_log` set archived = 1 where archived = 0;