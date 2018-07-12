CREATE TABLE MWC_DATA
  AS SELECT base.id, auser.username AS username,
  COALESCE(auser.firstname,'') || ' ' || COALESCE(auser.lastname,'') AS fullname,
  COALESCE(auser.firstname,'') AS firstname, COALESCE(auser.lastname,'') AS lastname,
  auser.email
  AS user_email,
  CASE WHEN user_7.data = '' THEN NULL ELSE CAST(user_7.data AS BIGINT) END AS hire_date,
  auser.id AS totara_id,
  auser.idnumber AS oracle_idnumber,
  course.fullname AS course_fullname,
  course.shortname AS course_shortname,
  course.id AS course_id,
  base.timeenrolled AS course_completion_enrolleddate,
  base.status AS course_completion_status,
  b.managerid AS manager_id,
  b.managerpath AS manager_hierarchy,
  b.userid AS userid
  FROM mdl_course_completions base
  LEFT JOIN mdl_user auser ON auser.id = base.userid
  INNER JOIN mdl_course course ON course.id = base.course
  LEFT JOIN mdl_user_info_data user_7 ON user_7.userid = auser.id AND user_7.fieldid = 7
  LEFT JOIN mdl_pos_assignment b ON b.userid = auser.id
  WHERE ( 1=1 )
  ORDER BY fullname ASC, base.id;
CREATE TABLE MWC_MANAGER_ROLLUP
  AS SELECT mdl_pos_assignment.managerid,
  mdl_pos_assignment.userid AS direct_report_id,
  mdl_pos_assignment.managerpath,
  mdl_user.id AS manager_id,
  mdl_user.username AS manager_username,
  mdl_user.idnumber AS manager_oracle_id,
  mdl_user.firstname AS manager_firstname,
  mdl_user.lastname AS manager_lastname,
  mdl_user.email AS manager_email
  FROM mdl_pos_assignment
  LEFT JOIN mdl_user
  ON mdl_user.id = mdl_pos_assignment.managerid
  ORDER BY managerid ASC;
CREATE TABLE MWC_HIERARCHY AS SELECT mwc_manager_rollup.managerid AS manager_id,
  mwc_manager_rollup.manager_username,
  mwc_manager_rollup.manager_firstname,
  mwc_manager_rollup.manager_lastname,
  mwc_manager_rollup.manager_email,
  mwc_manager_rollup.managerpath AS manager_path,
  mwc_manager_rollup.direct_report_id AS user_id,
  mdl_user.username, mdl_user.firstname,
  mdl_user.lastname, mdl_user.email,
  mdl_user.idnumber AS oracle_id,
  mdl_user.deleted AS deleted,
  mdl_user.suspended AS suspended
  FROM mwc_manager_rollup
  LEFT JOIN mdl_user
  ON mdl_user.id = mwc_manager_rollup.direct_report_id
  ORDER BY managerid ASC;
CREATE TABLE COURSE_STATUS_REPORT AS
SELECT base.id,
      COALESCE(auser.firstname,'') || ' ' || COALESCE(auser.lastname,'')  AS user_firstLast,
     auser.id AS userid,
     COALESCE(auser.firstname,'') AS firstname,
     COALESCE(auser.lastname,'') AS lastname,
     user_3.data AS Learner_egion,
     user_18.data AS RH_office,
     auser.email AS user_email,
     course_category.name AS portfolio,
     course.fullname AS course,
     course.id AS course_id,
     course.shortname AS course_code,
     base.status AS course_completion_status,
     base.timeenrolled AS enrollmentdate,
     course_21.data AS mode_of_delivery,
     base.timecompleted AS coursecompletiondate,
     course_15.data AS duration,
     position_assignment.managerpath AS managerhierarchy,
     user_21.data AS Learner_Job_title,
     auser.deleted AS deleted,
     auser.suspended AS suspended
 FROM mdl_course_completions base
    LEFT JOIN mdl_user auser
        ON auser.id = base.userid
    INNER JOIN mdl_course course
        ON course.id = base.course
    LEFT JOIN mdl_pos_assignment position_assignment
        ON (position_assignment.userid = base.userid AND position_assignment.type = 1)
    LEFT JOIN mdl_user_info_data user_3
        ON user_3.userid = auser.id AND user_3.fieldid = 3
    LEFT JOIN mdl_user_info_data user_18
        ON user_18.userid = auser.id AND user_18.fieldid = 18
    LEFT JOIN mdl_course_categories course_category
        ON course_category.id = course.category
    LEFT JOIN mdl_course_info_data course_21
        ON course_21.courseid = course.id AND course_21.fieldid = 21
    LEFT JOIN mdl_course_info_data course_15
        ON course_15.courseid = course.id AND course_15.fieldid = 15
    LEFT JOIN mdl_course_info_data course_14
        ON course_14.courseid = course.id AND course_14.fieldid = 14
    LEFT JOIN mdl_user_info_data user_21
        ON user_21.userid = auser.id AND user_21.fieldid = 21
 WHERE ( 1=1 )
   ORDER BY user_firstlast ASC, base.id;
   CREATE TABLE INSTRUCTOR_LED_CLASS_SUMMARY AS
   SELECT
        course.audiencevisible AS audience_visible,
        min(base.id) AS facetoface_id,
        course.id AS course_id,
        course_14.data AS content_owner,
        sessions.id AS signup_id,
        facetoface_session_6.data AS private,
        facetoface_session_7.data AS facilitator,
        facetoface_session_8.data AS producer,
        course_category.name AS course_category_name,
        course.shortname AS course_code,
        base.name AS course_name,
        facetoface_session_1.data AS mode_of_delivery,
        agg_sessiondate.timestart AS class_start_time,
        agg_sessiondate.timefinish AS class_end_time,
        agg_sessiondate.sessiontimezone AS timezone,
        facetoface_session_2.jsondata AS class_region,
        facetoface_session_4.data AS class_city,
        facetoface_session_3.data AS class_country,
        room.name AS room_name,
        course_15.data AS duration,
        sessions.capacity AS session_capacity,
        COUNT((CASE WHEN attendees.statuscode = 100 THEN 1 ELSE NULL END)) AS session_fullyattended,
        COUNT((CASE WHEN attendees.statuscode = 80 THEN 1 ELSE NULL END)) AS session_noshowattendees,
        base.id AS facetofaceid
    FROM mdl_facetoface base
       INNER JOIN mdl_facetoface_sessions sessions
           ON sessions.facetoface = base.id
       LEFT JOIN mdl_course course
           ON course.id = base.course
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_7
           ON facetoface_session_7.facetofacesessionid = sessions.id AND facetoface_session_7.fieldid = 7
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_8
           ON facetoface_session_8.facetofacesessionid = sessions.id AND facetoface_session_8.fieldid = 8
       LEFT JOIN mdl_course_categories course_category
           ON course_category.id = course.category
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_1
           ON facetoface_session_1.facetofacesessionid = sessions.id AND facetoface_session_1.fieldid = 1
      LEFT JOIN (SELECT sessionid,
                            GROUP_CONCAT( CAST(timestart AS VARCHAR) , ',', FALSE)  AS timestart,
                            GROUP_CONCAT( CAST(timefinish AS VARCHAR) , ',', FALSE)  AS timefinish,
                           sessiontimezone,
                           MIN(timestart) AS mintimestart,
                           MAX(timefinish) AS maxtimefinish,
                            GROUP_CONCAT( CAST((sessiondate.timefinish-sessiondate.timestart)/60 AS VARCHAR) , ',', FALSE)  AS session_duration
                      FROM mdl_facetoface_sessions_dates sessiondate
                      GROUP BY sessionid, sessiontimezone) agg_sessiondate
               ON agg_sessiondate.sessionid = sessions.id
       LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                    cfid.facetofacesessionid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                               FROM mdl_facetoface_session_info_data cfid
                               LEFT JOIN mdl_facetoface_session_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                              WHERE cfid.fieldid = 2
                              GROUP BY cfid.facetofacesessionid,  CAST(cfid.data AS VARCHAR) ) facetoface_session_2
           ON facetoface_session_2.joinid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_3
           ON facetoface_session_3.facetofacesessionid = sessions.id AND facetoface_session_3.fieldid = 3
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_4
           ON facetoface_session_4.facetofacesessionid = sessions.id AND facetoface_session_4.fieldid = 4
       LEFT JOIN mdl_course_info_data course_15
           ON course_15.courseid = course.id AND course_15.fieldid = 15
       LEFT JOIN mdl_course_info_data course_14
           ON course_14.courseid = course.id AND course_14.fieldid = 14
       LEFT JOIN (SELECT su.sessionid, su.userid, ss.id AS ssid, ss.statuscode
                       FROM mdl_facetoface_signups su

                       JOIN mdl_facetoface_signups_status ss
                           ON su.id = ss.signupid
                       WHERE ss.superceded = 0) attendees
           ON attendees.sessionid = sessions.id
       LEFT JOIN mdl_facetoface_signups signups
           ON signups.sessionid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_10
           ON facetoface_session_10.facetofacesessionid = sessions.id AND facetoface_session_10.fieldid = 10
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_9
           ON facetoface_session_9.facetofacesessionid = sessions.id AND facetoface_session_9.fieldid = 9
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_6
           ON facetoface_session_6.facetofacesessionid = sessions.id AND facetoface_session_6.fieldid = 6
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_11
           ON facetoface_session_11.facetofacesessionid = sessions.id AND facetoface_session_11.fieldid = 11
       LEFT JOIN mdl_facetoface_room room
           ON sessions.roomid = room.id
    WHERE ( 1=1 )
     GROUP BY signups.sessionid, facetoface_session_6.data, facetoface_session_7.data, facetoface_session_8.data, course_category.name, course.shortname, base.name, sessions.facetoface, facetoface_session_1.data, agg_sessiondate.timestart, agg_sessiondate.timefinish, agg_sessiondate.sessiontimezone, agg_sessiondate.mintimestart, agg_sessiondate.sessiontimezone, agg_sessiondate.timestart, agg_sessiondate.timefinish, agg_sessiondate.sessiontimezone, facetoface_session_2.data, facetoface_session_2.jsondata, facetoface_session_4.data, facetoface_session_3.data, room.name,  course_14.data, course_15.data, sessions.capacity, facetoface_session_10.data, facetoface_session_9.data, facetoface_session_9.id, CASE WHEN ( facetoface_session_6.data IS NULL OR facetoface_session_6.data = '' ) THEN 0 ELSE  CAST(facetoface_session_6.data AS BIGINT)  END, CASE WHEN ( facetoface_session_11.data IS NULL OR facetoface_session_11.data = '' ) THEN 0 ELSE  CAST(facetoface_session_11.data AS BIGINT)  END, sessions.id, course.id, base.id
     ORDER BY min(base.id);
CREATE TABLE AUDIENCE AS
SELECT base.id,
     cohort.name AS audience,
      COALESCE(auser.firstname,'') || ' ' || COALESCE(auser.lastname,'')  AS user_fullname,
     COALESCE(auser.firstname,'') AS firstname,
     COALESCE(auser.lastname,'') AS lastname,
     auser.id AS totara_id,
     auser.idnumber AS oracle_id,
     auser.email AS user_email,
     user_21.data AS user_job_title,
     user_3.data AS user_region,
     user_6.data AS user_cost_center,
     user_18.data AS user_office,
     auser.country AS user_country,
     position_assignment.managerpath AS user_managerhierarchy
 FROM mdl_cohort_members base
    INNER JOIN mdl_cohort cohort
        ON base.cohortid = cohort.id
    LEFT JOIN mdl_user auser
        ON auser.id = base.userid
    LEFT JOIN mdl_pos_assignment position_assignment
        ON (position_assignment.userid = base.userid AND position_assignment.type = 1)
    LEFT JOIN mdl_user_info_data user_21
        ON user_21.userid = auser.id AND user_21.fieldid = 21
    LEFT JOIN mdl_user_info_data user_3
        ON user_3.userid = auser.id AND user_3.fieldid = 3
    LEFT JOIN mdl_user_info_data user_6
        ON user_6.userid = auser.id AND user_6.fieldid = 6
    LEFT JOIN mdl_user_info_data user_5
        ON user_5.userid = auser.id AND user_5.fieldid = 5
    LEFT JOIN mdl_user_info_data user_18
        ON user_18.userid = auser.id AND user_18.fieldid = 18
    LEFT JOIN mdl_user_info_data user_8
        ON user_8.userid = auser.id AND user_8.fieldid = 8
    LEFT JOIN mdl_user_info_data user_14
        ON user_14.userid = auser.id AND user_14.fieldid = 14
    LEFT JOIN mdl_user_info_data user_15
        ON user_15.userid = auser.id AND user_15.fieldid = 15
    LEFT JOIN mdl_user_info_data user_16
        ON user_16.userid = auser.id AND user_16.fieldid = 16
 WHERE ( 1=1 )
   ORDER BY base.id;
CREATE TABLE course_catalog AS
SELECT base.id,
     course_category.name AS course_category,
     course_14.data AS content_owner,
     base.fullname AS course_name,
     base.id AS course_id,
     base.visible AS course_visability,
     base.audiencevisible AS audience_visability,
     base.shortname AS course_shortname,
     base.summary AS course_summary,
     base.id AS record_id,
     course_21.data AS mode_of_delivery,
     course_15.data AS duration,
     course_1.data AS ce_credits,
     course_3.data AS course_capacity,
     CASE WHEN course_7.data = '' THEN NULL ELSE  CAST(course_7.data AS BIGINT)  END AS last_review_date,
     CASE WHEN course_8.data = '' THEN NULL ELSE  CAST(course_8.data AS BIGINT)  END AS next_review_date,
     course_19.data AS business_owner,
     course_20.data AS content_provider,
     course_9.data AS point_of_contact,
     base.audiencevisible AS audience_visible,
     base.startdate AS course_startdate,
     CASE WHEN course_16.data = '' THEN NULL ELSE  CAST(course_16.data AS BIGINT)  END AS course_enddate,
     course_6.jsondata AS course_competencies,
     ctx.id AS ctx_id,
     base.category AS base_category,
     base.id AS visibility_id,
     base.visible AS visibility_visible,
     base.audiencevisible AS visibility_audiencevisible
 FROM mdl_course base
    LEFT JOIN mdl_course_categories course_category
        ON course_category.id = base.category
    LEFT JOIN mdl_course_info_data course_14
        ON course_14.courseid = base.id AND course_14.fieldid = 14
    LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                 cfid.courseid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                            FROM mdl_course_info_data cfid
                            LEFT JOIN mdl_course_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                           WHERE cfid.fieldid = 2
                           GROUP BY cfid.courseid,  CAST(cfid.data AS VARCHAR) ) course_2
        ON course_2.joinid = base.id
    LEFT JOIN mdl_course_info_data course_21
        ON course_21.courseid = base.id AND course_21.fieldid = 21
    LEFT JOIN mdl_course_info_data course_15
        ON course_15.courseid = base.id AND course_15.fieldid = 15
    LEFT JOIN mdl_course_info_data course_1
        ON course_1.courseid = base.id AND course_1.fieldid = 1
    LEFT JOIN mdl_course_info_data course_3
        ON course_3.courseid = base.id AND course_3.fieldid = 3
    LEFT JOIN mdl_course_info_data course_7
        ON course_7.courseid = base.id AND course_7.fieldid = 7
    LEFT JOIN mdl_course_info_data course_8
        ON course_8.courseid = base.id AND course_8.fieldid = 8
    LEFT JOIN mdl_course_info_data course_19
        ON course_19.courseid = base.id AND course_19.fieldid = 19
    LEFT JOIN mdl_course_info_data course_20
        ON course_20.courseid = base.id AND course_20.fieldid = 20
    LEFT JOIN mdl_course_info_data course_9
        ON course_9.courseid = base.id AND course_9.fieldid = 9
    LEFT JOIN mdl_course_info_data course_16
        ON course_16.courseid = base.id AND course_16.fieldid = 16
    LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                 cfid.courseid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                            FROM mdl_course_info_data cfid
                            LEFT JOIN mdl_course_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                           WHERE cfid.fieldid = 6
                           GROUP BY cfid.courseid,  CAST(cfid.data AS VARCHAR) ) course_6
        ON course_6.joinid = base.id
    LEFT JOIN mdl_course_info_data course_11
        ON course_11.courseid = base.id AND course_11.fieldid = 11
    LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                 cfid.courseid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                            FROM mdl_course_info_data cfid
                            LEFT JOIN mdl_course_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                           WHERE cfid.fieldid = 13
                           GROUP BY cfid.courseid,  CAST(cfid.data AS VARCHAR) ) course_13
        ON course_13.joinid = base.id
    INNER JOIN mdl_context ctx
        ON ctx.instanceid = base.id AND ctx.contextlevel = 50
 WHERE ( 1=1 )
   ORDER BY course_category ASC, base.id;
CREATE TABLE INSTRUCTOR_LED_CLASS_DETAIL AS
   SELECT base.id,
        auser.email AS user_email,
        position.userid AS user_id,
        position.managerid AS manager_id,
        position.managerpath AS manager_hierarchy,
        course.fullname AS course_fullname,
        course.shortname AS course_code,
        course_14.data AS content_owner,
        agg_sessiondate.mintimestart AS startdate,
        agg_sessiondate.sessiontimezone AS timezone,
        facetoface_session_7.data AS facilitator,
        facetoface_session_2.jsondata AS class_region,
        facetoface_session_4.data AS class_city,
        status.statuscode AS attendence_status,
        facetoface_signup_1.data AS signup_note,
        room.name AS room_name,
        course_21.data AS course_custom_field_21,
        course.id AS visibility_id,
        course.visible AS visibility_visible,
        course.audiencevisible AS visibility_audiencevisible,
        ctx.id AS ctx_id
    FROM mdl_facetoface_signups base
       LEFT JOIN mdl_user auser
           ON auser.id = base.userid
       LEFT JOIN mdl_pos_assignment position
           ON position.userid = auser.id
       LEFT JOIN mdl_facetoface_sessions sessions
           ON sessions.id = base.sessionid
       LEFT JOIN mdl_facetoface_signups_status status
           ON (status.signupid = base.id AND status.superceded = 0)
       LEFT JOIN mdl_facetoface_signup_info_data facetoface_signup_1
           ON facetoface_signup_1.facetofacesignupid = base.id AND facetoface_signup_1.fieldid = 1
       LEFT JOIN mdl_facetoface facetoface
           ON facetoface.id = sessions.facetoface
       LEFT JOIN (SELECT sessionid,
                        GROUP_CONCAT( CAST(timestart AS VARCHAR) , ',', FALSE)  AS timestart,
                        GROUP_CONCAT( CAST(timefinish AS VARCHAR) , ',', FALSE)  AS timefinish,
                       sessiontimezone,
                       MIN(timestart) AS mintimestart,
                       MAX(timefinish) AS maxtimefinish,
                        GROUP_CONCAT( CAST((sessiondate.timefinish-sessiondate.timestart)/60 AS VARCHAR) , ',', FALSE)  AS session_duration
                       FROM mdl_facetoface_sessions_dates sessiondate
                       GROUP BY sessionid, sessiontimezone) agg_sessiondate
           ON agg_sessiondate.sessionid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_7
           ON facetoface_session_7.facetofacesessionid = sessions.id AND facetoface_session_7.fieldid = 7
       LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                    cfid.facetofacesessionid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                               FROM mdl_facetoface_session_info_data cfid
                               LEFT JOIN mdl_facetoface_session_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                              WHERE cfid.fieldid = 2
                              GROUP BY cfid.facetofacesessionid,  CAST(cfid.data AS VARCHAR) ) facetoface_session_2
           ON facetoface_session_2.joinid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_4
           ON facetoface_session_4.facetofacesessionid = sessions.id AND facetoface_session_4.fieldid = 4
       LEFT JOIN mdl_facetoface_room room
           ON sessions.roomid = room.id
       INNER JOIN mdl_course course
           ON course.id = facetoface.course
       LEFT JOIN mdl_course_info_data course_14
           ON course_14.courseid = course.id AND course_14.fieldid = 14
       LEFT JOIN mdl_course_info_data course_21
           ON course_21.courseid = course.id AND course_21.fieldid = 21
       INNER JOIN mdl_context ctx
           ON ctx.instanceid = course.id AND ctx.contextlevel = 50
    WHERE ( 1=1 )
       AND 1=1
      ORDER BY base.id;
CREATE TABLE INSTRUCTOR_LED_CLASS_DETAIL_HIERARCHY AS
      SELECT
      manager_hierarchy [2] AS Manager1,
      manager_hierarchy [3] AS Manager2,
      manager_hierarchy [4] AS Manager3,
      manager_hierarchy [5] AS Manager4,
      manager_hierarchy [6] AS Manager5,
      manager_hierarchy [7] AS Manager6,
      manager_hierarchy [8] AS Manager7,
      manager_hierarchy [9] AS Manager8,
      manager_hierarchy [10] AS Manager9,
      manager_hierarchy [11] AS Manager10
      FROM (select regexp_split_to_array(manager_hierarchy, '/')
      from instructor_led_class_detail) as dt(manager_hierarchy);
CREATE TABLE Capacity_MGMT_MANAGER4_working_tbl AS
  SELECT user_id,
        user_email,
        course_fullname,
        course_code,
        startdate,
        attendence_status,
        course_custom_field_21,
        split_part(manager_hierarchy,'/',5) AS Manager4
      FROM instructor_led_class_detail;
CREATE TABLE Capacity_MGMT_MANAGER3_working_tbl AS
  SELECT user_id,
        user_email,
        course_fullname,
        course_code,
        startdate,
        attendence_status,
        course_custom_field_21,
        split_part(manager_hierarchy,'/',4) AS Manager3
      FROM instructor_led_class_detail;
CREATE TABLE capacity_mgmt_manager3 AS
  SELECT user_id,
        user_email,
        course_fullname,
        course_code,
        startdate,
        attendence_status,
        course_custom_field_21 AS delivery_mode,
        Manager3,
        auser.email As manager_email,
        auser.firstname As manager3_firstname,
        auser.lastname AS manager3_lastname
      FROM Capacity_MGMT_MANAGER3_working_tbl
      Inner Join mdl_user auser
          ON CAST(Capacity_mgmt_manager3_working_tbl.manager3 AS VARCHAR) = CAST(auser.id AS VARCHAR);
CREATE TABLE capacity_mgmt_manager4 AS
  SELECT user_id,
        user_email,
        course_fullname,
        course_code,
        startdate,
        attendence_status,
        course_custom_field_21 AS delivery_mode,
        manager4,
        auser.email As manager_email,
        auser.firstname As manager4_firstname,
        auser.lastname AS manager4_lastname
      FROM Capacity_MGMT_MANAGER4_working_tbl
      Inner Join mdl_user auser
      ON CAST(Capacity_mgmt_manager4_working_tbl.manager4 AS VARCHAR) = CAST(auser.id AS VARCHAR);
CREATE TABLE Program_status_report AS
  SELECT base.id,
           base.fullname AS program_fullname,
            COALESCE(auser.firstname,'') || ' ' || COALESCE(auser.lastname,'')  AS user_fullname,
           COALESCE(auser.firstname,'') AS firstname,
           COALESCE(auser.lastname,'') AS lastname,
           auser.email AS user_email,
           CASE WHEN manager.id IS NULL THEN NULL ELSE  COALESCE(manager.firstname,'') || ' ' || COALESCE(manager.lastname,'')  END AS user_managername,
           COALESCE(manager.firstname,'') AS manager_firstname,
           COALESCE(manager.lastname,'') AS manager_lastname,
           manager.email AS user_manageremail,
           program_completion.timestarted AS program_completion_starteddate,
           user_3.data AS user_region,
           user_4.data AS user_country,
           user_18.data AS user_office,
           program_completion.status AS program_completion_status,
           base.id AS programid,
           program_completion.userid AS userid,
           program_completion.timecompleted AS program_completion_completeddate,
           position_assignment.managerpath AS user_managerhierarchy,
           ctx.id AS ctx_id,
           base.id AS visibility_id,
           base.visible AS visibility_visible,
           base.audiencevisible AS visibility_audiencevisible,
           base.available AS base_available,
           base.availablefrom AS base_availablefrom,
           base.availableuntil AS base_availableuntil,
           program_completion.status AS visibility_completionstatus
    FROM mdl_prog base
      INNER JOIN mdl_prog_completion program_completion
          ON base.id = program_completion.programid AND program_completion.coursesetid = 0
      INNER JOIN mdl_context ctx
          ON ctx.instanceid = base.id AND ctx.contextlevel = 45
      LEFT JOIN mdl_user auser
          ON auser.id = program_completion.userid
      LEFT JOIN mdl_pos_assignment position_assignment
          ON (position_assignment.userid = program_completion.userid AND position_assignment.type = 1)
      LEFT JOIN mdl_role_assignments manager_role_assignment
          ON (manager_role_assignment.id = position_assignment.reportstoid AND manager_role_assignment.roleid = 9)
      LEFT JOIN mdl_user_info_data user_3
          ON user_3.userid = auser.id AND user_3.fieldid = 3
      LEFT JOIN mdl_user_info_data user_4
          ON user_4.userid = auser.id AND user_4.fieldid = 4
      LEFT JOIN mdl_user_info_data user_18
          ON user_18.userid = auser.id AND user_18.fieldid = 18
      LEFT JOIN mdl_user manager
          ON manager.id = manager_role_assignment.userid
      WHERE ( 1=1 )
          AND base.certifid IS NULL
      ORDER BY program_fullname ASC, base.id;
Create TABLE Scheduling AS
SELECT facetoface_session_9.data AS ticket_id,
        base.name AS course_name,
        facetoface_session_6.data AS private,
        min(base.id) AS facetoface_id,
        course.id AS course_id,
        course_14.data AS content_owner,
        split_part(agg_sessiondate.timestart,',',1) AS class_Start_time_1,
        split_part(agg_sessiondate.timestart,',',2) AS class_Start_time_2,
        split_part(agg_sessiondate.timefinish,',',1) AS class_end_time_1,
        split_part(agg_sessiondate.timefinish,',',2) AS class_end_time_2,
        facetoface_session_7.data AS facilitator,
        facetoface_session_8.data AS producer,
        course_category.name AS course_category_name,
        course.shortname AS course_code,
        facetoface_session_1.data AS mode_of_delivery,
        agg_sessiondate.sessiontimezone AS timezone,
        facetoface_session_4.data AS class_location,
        course_15.data AS duration,
        sessions.capacity AS session_capacity,
        COUNT((CASE WHEN attendees.statuscode = 100 THEN 1 ELSE NULL END)) AS session_fullyattended,
        COUNT((CASE WHEN attendees.statuscode = 80 THEN 1 ELSE NULL END)) AS session_noshowattendees,
        base.id AS facetofaceid,
        room.name AS room_name
    FROM mdl_facetoface base
       INNER JOIN mdl_facetoface_sessions sessions
           ON sessions.facetoface = base.id
       LEFT JOIN mdl_course course
           ON course.id = base.course
      LEFT JOIN mdl_facetoface_session_info_data facetoface_session_6
            ON facetoface_session_6.facetofacesessionid = sessions.id AND facetoface_session_6.fieldid = 6
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_7
           ON facetoface_session_7.facetofacesessionid = sessions.id AND facetoface_session_7.fieldid = 7
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_8
           ON facetoface_session_8.facetofacesessionid = sessions.id AND facetoface_session_8.fieldid = 8
       LEFT JOIN mdl_course_categories course_category
           ON course_category.id = course.category
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_1
           ON facetoface_session_1.facetofacesessionid = sessions.id AND facetoface_session_1.fieldid = 1
       LEFT JOIN (SELECT sessionid,
                        GROUP_CONCAT( CAST(timestart AS VARCHAR) , ',', FALSE)  AS timestart,
                        GROUP_CONCAT( CAST(timefinish AS VARCHAR) , ',', FALSE)  AS timefinish,
                       sessiontimezone,
                       MIN(timestart) AS mintimestart,
                       MAX(timefinish) AS maxtimefinish,
                        GROUP_CONCAT( CAST((sessiondate.timefinish-sessiondate.timestart)/60 AS VARCHAR) , ',', FALSE)  AS session_duration
                       FROM mdl_facetoface_sessions_dates sessiondate
                       GROUP BY sessionid, sessiontimezone) agg_sessiondate
           ON agg_sessiondate.sessionid = sessions.id
       LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                    cfid.facetofacesessionid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                               FROM mdl_facetoface_session_info_data cfid
                               LEFT JOIN mdl_facetoface_session_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                              WHERE cfid.fieldid = 2
                              GROUP BY cfid.facetofacesessionid,  CAST(cfid.data AS VARCHAR) ) facetoface_session_2
           ON facetoface_session_2.joinid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_4
           ON facetoface_session_4.facetofacesessionid = sessions.id AND facetoface_session_4.fieldid = 4
       LEFT JOIN mdl_course_info_data course_15
           ON course_15.courseid = course.id AND course_15.fieldid = 15
       LEFT JOIN mdl_course_info_data course_14
           ON course_14.courseid = course.id AND course_14.fieldid = 14
       LEFT JOIN (SELECT su.sessionid, su.userid, ss.id AS ssid, ss.statuscode
                       FROM mdl_facetoface_signups su

                       JOIN mdl_facetoface_signups_status ss
                           ON su.id = ss.signupid
                       WHERE ss.superceded = 0) attendees
           ON attendees.sessionid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_10
           ON facetoface_session_10.facetofacesessionid = sessions.id AND facetoface_session_10.fieldid = 10
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_9
           ON facetoface_session_9.facetofacesessionid = sessions.id AND facetoface_session_9.fieldid = 9
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_11
           ON facetoface_session_11.facetofacesessionid = sessions.id AND facetoface_session_11.fieldid = 11
       LEFT JOIN mdl_facetoface_room room
           ON sessions.roomid = room.id
    WHERE ( 1=1 )
     GROUP BY room.id, facetoface_session_6.data, facetoface_session_7.data, facetoface_session_8.data, course_category.name, course.shortname, base.name, sessions.facetoface, facetoface_session_1.data, agg_sessiondate.timestart, agg_sessiondate.timefinish, agg_sessiondate.sessiontimezone, agg_sessiondate.mintimestart, agg_sessiondate.sessiontimezone, agg_sessiondate.timestart, agg_sessiondate.timefinish, agg_sessiondate.sessiontimezone, facetoface_session_2.data, facetoface_session_2.jsondata, facetoface_session_4.data,  course_14.data, course_15.data, sessions.capacity, facetoface_session_10.data, facetoface_session_9.data, facetoface_session_9.id, CASE WHEN ( facetoface_session_6.data IS NULL OR facetoface_session_6.data = '' ) THEN 0 ELSE  CAST(facetoface_session_6.data AS BIGINT)  END, CASE WHEN ( facetoface_session_11.data IS NULL OR facetoface_session_11.data = '' ) THEN 0 ELSE  CAST(facetoface_session_11.data AS BIGINT)  END, sessions.id, course.id, base.id
     ORDER BY min(base.id);
Create table headcount as
SELECT base.id,
  COALESCE(base.firstname,'') || ' ' || COALESCE(base.lastname,'')  AS user_fullname,
  COALESCE(base.firstname,'') AS firstname,
  COALESCE(base.lastname,'') AS lastname,
     base.username AS user_username,
     base.email AS user_email,
     user_23.data AS user_RHN_ID,
     user_21.data AS user_job_title,
     user_3.data AS user_region,
     user_18.data AS user_office,
     CASE WHEN user_7.data = '' THEN NULL ELSE  CAST(user_7.data AS BIGINT)  END AS user_hire_date,
     user_16.data AS is_manager,
     user_9.data AS learner_type,
     CASE WHEN manager.id IS NULL THEN NULL ELSE  COALESCE(manager.firstname,'') || ' ' || COALESCE(manager.lastname,'')  END AS user_managername,
     user_6.data AS user_cost_center,
     position_assignment.managerpath AS user_managerhierarchy,
     CAST(split_part(position_assignment.managerpath,'/',4) AS text) AS manager3,
     CAST(split_part(position_assignment.managerpath,'/',5) AS text) AS manager4,
     user_5.data AS organization,
     CASE WHEN user_15.data = '' THEN NULL ELSE  CAST(user_15.data AS BIGINT)  END AS tenure_start_date,
     base.idnumber AS oracle_idnumber,
     COALESCE(course_completions_courses_started.number,0) AS statistics_coursesstarted,
     CASE WHEN base.deleted = 0 and base.suspended = 1 THEN 2 ELSE base.deleted END AS user_deleted,
     user_17.data AS technical_designation,
     base.country AS user_country,
     user_25.data AS is_team_lead,
     base.currentlogin AS user_lastlogin
 FROM mdl_user base
    LEFT JOIN mdl_user_info_data user_23
        ON user_23.userid = base.id AND user_23.fieldid = 23
    LEFT JOIN mdl_user_info_data user_21
        ON user_21.userid = base.id AND user_21.fieldid = 21
    LEFT JOIN mdl_user_info_data user_3
        ON user_3.userid = base.id AND user_3.fieldid = 3
    LEFT JOIN mdl_user_info_data user_18
        ON user_18.userid = base.id AND user_18.fieldid = 18
    LEFT JOIN mdl_user_info_data user_7
        ON user_7.userid = base.id AND user_7.fieldid = 7
    LEFT JOIN mdl_user_info_data user_16
        ON user_16.userid = base.id AND user_16.fieldid = 16
    LEFT JOIN mdl_user_info_data user_9
        ON user_9.userid = base.id AND user_9.fieldid = 9
    LEFT JOIN mdl_pos_assignment position_assignment
        ON (position_assignment.userid = base.id AND position_assignment.type = 1)
    LEFT JOIN mdl_user_info_data user_6
        ON user_6.userid = base.id AND user_6.fieldid = 6
    LEFT JOIN mdl_user_info_data user_14
        ON user_14.userid = base.id AND user_14.fieldid = 14
    LEFT JOIN mdl_user_info_data user_5
        ON user_5.userid = base.id AND user_5.fieldid = 5
    LEFT JOIN mdl_user_info_data user_15
        ON user_15.userid = base.id AND user_15.fieldid = 15
    LEFT JOIN (SELECT userid, COUNT(id) as number
                    FROM mdl_course_completions
                    WHERE timestarted > 0 OR timecompleted > 0
                    GROUP BY userid) course_completions_courses_started
        ON base.id = course_completions_courses_started.userid
    LEFT JOIN mdl_user_info_data user_17
        ON user_17.userid = base.id AND user_17.fieldid = 17
    LEFT JOIN mdl_user_info_data user_25
        ON user_25.userid = base.id AND user_25.fieldid = 25
    LEFT JOIN mdl_role_assignments manager_role_assignment
        ON (manager_role_assignment.id = position_assignment.reportstoid AND manager_role_assignment.roleid = 9)
    LEFT JOIN mdl_user manager
        ON manager.id = manager_role_assignment.userid
 WHERE user_9.fieldid = 9 AND base.deleted = 0 AND base.suspended = 0
   ORDER BY user_email ASC, base.id;
CREATE TABLE CE_Credits_this_FY As
SELECT base.id,
      COALESCE(auser.firstname,'') || ' ' || COALESCE(auser.lastname,'')  AS user_fullname,
      auser.id AS user_id,
      auser.idnumber AS oracle_id,
     COALESCE(auser.firstname,'') AS firstname,
     COALESCE(auser.lastname,'') AS lastname,
     auser.email AS user_email,
     user_3.data AS user_region,
     base.timeearned AS cecredit_timeearned,
     base.instancetype AS cecredit_type,
     course.fullname AS course_fullname,
     evidence.name AS evidence_name,
     base.credits AS cecredit_credits,
     position_assignment.managerpath AS user_managerhierarchy
 FROM mdl_local_cecredit_earned base
    LEFT JOIN mdl_user auser
        ON auser.id = base.userid
    LEFT JOIN mdl_course course
        ON base.instanceid = course.id AND base.instancetype = 100
    LEFT JOIN mdl_dp_plan_evidence evidence
        ON base.instanceid = evidence.id AND base.instancetype = 50
    LEFT JOIN mdl_pos_assignment position_assignment
        ON (position_assignment.userid = base.userid AND position_assignment.type = 1)
    LEFT JOIN mdl_user_info_data user_3
        ON user_3.userid = auser.id AND user_3.fieldid = 3
 WHERE (EXISTS (SELECT 1 FROM mdl_cohort_members WHERE cohortid = 1 AND userid = base.userid)
    AND (base.timeearned >= 1491019200 AND base.timeearned < 1522555200))
   ORDER BY base.timeearned DESC, base.id;
CREATE TABLE CAPACITY_MGMT_FOR_TABLEAU AS
SELECT base.id,
        auser.email AS user_email,
        position.userid AS user_id,
        position.managerid AS manager_id,
        CAST(split_part(position.managerpath,'/',4) AS text) AS manager3,
        CAST(split_part(position.managerpath,'/',5) AS text) AS manager4,
        course.fullname AS course_fullname,
        course.shortname AS course_code,
        course_14.data AS content_owner,
        CASE WHEN ( facetoface_session_11.data IS NULL OR facetoface_session_11.data = '' )
        THEN 0 ELSE  CAST(facetoface_session_11.data AS BIGINT)  END AS exclude_from_capacity_mgmt,
        agg_sessiondate.mintimestart AS startdate,
        agg_sessiondate.sessiontimezone AS timezone,
        facetoface_session_7.data AS facilitator,
        facetoface_session_2.jsondata AS class_region,
        facetoface_session_4.data AS class_city,
        status.statuscode AS attendence_status,
        facetoface_signup_1.data AS signup_note,
        room.name AS room_name,pg
        course_21.data AS mode_of_delivery,
        NULLIF(course_22.data,'')::INT AS course_cost,
        course_23.data AS offering_type
    FROM mdl_facetoface_signups base
       LEFT JOIN mdl_user auser
           ON auser.id = base.userid
       LEFT JOIN mdl_pos_assignment position
           ON position.userid = auser.id
       LEFT JOIN mdl_facetoface_sessions sessions
           ON sessions.id = base.sessionid
       LEFT JOIN mdl_facetoface_signups_status status
           ON (status.signupid = base.id AND status.superceded = 0)
       LEFT JOIN mdl_facetoface_signup_info_data facetoface_signup_1
           ON facetoface_signup_1.facetofacesignupid = base.id AND facetoface_signup_1.fieldid = 1
       LEFT JOIN mdl_facetoface facetoface
           ON facetoface.id = sessions.facetoface
       LEFT JOIN (SELECT sessionid,
                        GROUP_CONCAT( CAST(timestart AS VARCHAR) , ',', FALSE)  AS timestart,
                        GROUP_CONCAT( CAST(timefinish AS VARCHAR) , ',', FALSE)  AS timefinish,
                       sessiontimezone,
                       MIN(timestart) AS mintimestart,
                       MAX(timefinish) AS maxtimefinish,
                        GROUP_CONCAT( CAST((sessiondate.timefinish-sessiondate.timestart)/60 AS VARCHAR) , ',', FALSE)  AS session_duration
                       FROM mdl_facetoface_sessions_dates sessiondate
                       GROUP BY sessionid, sessiontimezone) agg_sessiondate
           ON agg_sessiondate.sessionid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_7
           ON facetoface_session_7.facetofacesessionid = sessions.id AND facetoface_session_7.fieldid = 7
       LEFT JOIN (SELECT  GROUP_CONCAT( CAST(cfidp.value AS VARCHAR) , '|', TRUE)  AS data,
                                    cfid.facetofacesessionid AS joinid,  CAST(cfid.data AS VARCHAR)  AS jsondata
                               FROM mdl_facetoface_session_info_data cfid
                               LEFT JOIN mdl_facetoface_session_info_data_param cfidp ON (cfidp.dataid = cfid.id)
                              WHERE cfid.fieldid = 2
                              GROUP BY cfid.facetofacesessionid,  CAST(cfid.data AS VARCHAR) ) facetoface_session_2
           ON facetoface_session_2.joinid = sessions.id
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_4
           ON facetoface_session_4.facetofacesessionid = sessions.id AND facetoface_session_4.fieldid = 4
       LEFT JOIN mdl_facetoface_session_info_data facetoface_session_11
           ON facetoface_session_11.facetofacesessionid = sessions.id AND facetoface_session_11.fieldid = 11
       LEFT JOIN mdl_facetoface_room room
           ON sessions.roomid = room.id
       INNER JOIN mdl_course course
           ON course.id = facetoface.course
       LEFT JOIN mdl_course_info_data course_14
           ON course_14.courseid = course.id AND course_14.fieldid = 14
       LEFT JOIN mdl_course_info_data course_21
           ON course_21.courseid = course.id AND course_21.fieldid = 21
       LEFT JOIN mdl_course_info_data course_22
           ON course_22.courseid = course.id AND course_22.fieldid = 22
       LEFT JOIN mdl_course_info_data course_23
           ON course_23.courseid = course.id AND course_23.fieldid = 23
    WHERE ( 1=1 )
       AND 1=1
      ORDER BY base.id;
