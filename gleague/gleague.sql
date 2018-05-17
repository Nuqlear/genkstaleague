--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.12
-- Dumped by pg_dump version 9.5.12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO gleague;

--
-- Name: match; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.match (
    id bigint NOT NULL,
    season_id integer NOT NULL,
    radiant_win boolean,
    duration integer,
    game_mode integer,
    start_time integer
);


ALTER TABLE public.match OWNER TO gleague;

--
-- Name: match_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.match_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.match_id_seq OWNER TO gleague;

--
-- Name: match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.match_id_seq OWNED BY public.match.id;


--
-- Name: player; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.player (
    steam_id bigint NOT NULL,
    nickname character varying(80),
    avatar character varying(255),
    avatar_medium character varying(255)
);


ALTER TABLE public.player OWNER TO gleague;

--
-- Name: player_match_item; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.player_match_item (
    id integer NOT NULL,
    player_match_stats_id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.player_match_item OWNER TO gleague;

--
-- Name: player_match_item_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.player_match_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_match_item_id_seq OWNER TO gleague;

--
-- Name: player_match_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.player_match_item_id_seq OWNED BY public.player_match_item.id;


--
-- Name: player_match_rating; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.player_match_rating (
    id integer NOT NULL,
    rated_by_steam_id bigint NOT NULL,
    rating smallint,
    player_match_stats_id integer NOT NULL,
    CONSTRAINT player_match_rating_rating_check CHECK ((rating >= 1)),
    CONSTRAINT player_match_rating_rating_check1 CHECK ((rating <= 5))
);


ALTER TABLE public.player_match_rating OWNER TO gleague;

--
-- Name: player_match_rating_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.player_match_rating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_match_rating_id_seq OWNER TO gleague;

--
-- Name: player_match_rating_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.player_match_rating_id_seq OWNED BY public.player_match_rating.id;


--
-- Name: player_match_stats; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.player_match_stats (
    id integer NOT NULL,
    season_stats_id integer NOT NULL,
    match_id bigint NOT NULL,
    old_pts integer NOT NULL,
    pts_diff integer NOT NULL,
    kills integer NOT NULL,
    assists integer NOT NULL,
    deaths integer NOT NULL,
    hero_damage integer NOT NULL,
    last_hits integer NOT NULL,
    player_slot integer NOT NULL,
    denies integer NOT NULL,
    tower_damage integer,
    hero character varying(255) NOT NULL,
    hero_healing integer,
    level integer NOT NULL,
    damage_taken integer,
    gold_per_min integer,
    xp_per_min integer
);


ALTER TABLE public.player_match_stats OWNER TO gleague;

--
-- Name: player_match_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.player_match_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_match_stats_id_seq OWNER TO gleague;

--
-- Name: player_match_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.player_match_stats_id_seq OWNED BY public.player_match_stats.id;


--
-- Name: player_steam_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.player_steam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_steam_id_seq OWNER TO gleague;

--
-- Name: player_steam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.player_steam_id_seq OWNED BY public.player.steam_id;


--
-- Name: season; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.season (
    id integer NOT NULL,
    number integer NOT NULL,
    started timestamp without time zone,
    ended timestamp without time zone,
    place_1 bigint,
    place_2 bigint,
    place_3 bigint
);


ALTER TABLE public.season OWNER TO gleague;

--
-- Name: season_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.season_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.season_id_seq OWNER TO gleague;

--
-- Name: season_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.season_id_seq OWNED BY public.season.id;


--
-- Name: season_stats; Type: TABLE; Schema: public; Owner: gleague
--

CREATE TABLE public.season_stats (
    id integer NOT NULL,
    season_id integer NOT NULL,
    steam_id bigint NOT NULL,
    wins integer NOT NULL,
    losses integer NOT NULL,
    pts integer NOT NULL,
    streak integer NOT NULL,
    longest_winstreak integer DEFAULT 0 NOT NULL,
    longest_losestreak integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.season_stats OWNER TO gleague;

--
-- Name: season_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: gleague
--

CREATE SEQUENCE public.season_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.season_stats_id_seq OWNER TO gleague;

--
-- Name: season_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gleague
--

ALTER SEQUENCE public.season_stats_id_seq OWNED BY public.season_stats.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.match ALTER COLUMN id SET DEFAULT nextval('public.match_id_seq'::regclass);


--
-- Name: steam_id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player ALTER COLUMN steam_id SET DEFAULT nextval('public.player_steam_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_item ALTER COLUMN id SET DEFAULT nextval('public.player_match_item_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_rating ALTER COLUMN id SET DEFAULT nextval('public.player_match_rating_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_stats ALTER COLUMN id SET DEFAULT nextval('public.player_match_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season ALTER COLUMN id SET DEFAULT nextval('public.season_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season_stats ALTER COLUMN id SET DEFAULT nextval('public.season_stats_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.alembic_version (version_num) FROM stdin;
58ebc7a4643
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.match (id, season_id, radiant_win, duration, game_mode, start_time) FROM stdin;
1274068589	1	t	3068	3	1424878874
1274674136	1	t	1839	3	1424894739
1280751055	1	f	1866	2	1425074059
1280840885	1	t	2132	2	1425077262
1280898627	1	t	2770	2	1425080465
1283861898	1	f	2711	2	1425150741
1286030237	1	t	2277	2	1425210831
1286218079	1	t	2372	2	1425214746
1286519243	1	f	2798	2	1425218531
1286738035	1	t	2803	2	1425224030
1286912949	1	t	2533	2	1425228312
1287145153	1	f	1828	2	1425233166
1287264156	1	f	1931	2	1425236735
1287360270	1	f	3684	2	1425240406
1289354277	1	t	2878	2	1425305989
1289554851	1	t	1675	2	1425310700
1289701890	1	f	3241	2	1425314473
1289914848	1	t	3705	2	1425319332
1290093058	1	t	2822	2	1425325642
1290249225	1	f	2575	2	1425330505
1290318010	1	f	762	2	1425334491
1290350591	1	t	1374	2	1425336424
1291841940	1	f	1931	2	1425394215
1291972299	1	f	3046	2	1425397621
1292187436	1	t	2271	2	1425403392
1292371811	1	t	1798	2	1425410167
1292443205	1	t	2130	2	1425412999
1292523642	1	t	2497	2	1425416838
1294239846	1	t	3315	1	1425482341
1294381465	1	f	3167	2	1425486850
1294563503	1	t	2642	2	1425492517
1294681796	1	t	1184	2	1425496626
1294751130	1	t	2788	2	1425499438
1294832806	1	f	1350	2	1425503327
1296550050	1	f	2399	2	1425566443
1296751287	1	t	3269	2	1425572230
1297072659	1	f	2362	2	1425582075
1297160515	1	f	2309	2	1425585704
1297240757	1	t	1927	2	1425589198
1297301907	1	t	1416	2	1425592433
1299378094	1	f	1704	2	1425659107
1299504372	1	f	1339	2	1425662114
1299603026	1	t	4375	2	1425664713
1299806373	1	t	2504	2	1425670911
1299931771	1	f	4262	2	1425675480
1300074935	1	t	1907	2	1425681947
1300135746	1	f	2425	2	1425684864
1300226054	1	f	2188	1	1425690942
1301915712	1	f	3207	2	1425737903
1302136486	1	f	2703	2	1425742363
1302338808	1	f	2975	2	1425746914
1302544135	1	f	1941	2	1425751901
1302689870	1	f	1799	2	1425756020
1302859320	1	f	3100	2	1425761413
1302973275	1	t	2731	2	1425765948
1303052426	1	t	3348	2	1425770005
1303139272	1	f	3104	2	1425775369
1305106917	1	f	4351	2	1425829073
1305328543	1	t	2784	2	1425834872
1305477778	1	t	3472	2	1425839162
1305637233	1	f	2316	2	1425844272
1305755581	1	f	2191	2	1425848474
1305832137	1	t	2613	2	1425852021
1305901701	1	t	2550	2	1425855807
1307217153	1	t	2067	2	1425905541
1307683967	1	t	1767	2	1425916185
1307807317	1	f	2273	2	1425919621
1308040018	1	t	3053	2	1425927736
1308149679	1	f	2539	2	1425931487
1308225703	1	t	3589	2	1425935301
1308321231	1	f	2237	2	1425941106
1310483122	1	f	2539	2	1426020936
1310564249	1	f	2823	2	1426025179
1312522817	1	t	2444	2	1426096400
1312644118	1	t	2407	2	1426100726
1312772811	1	f	2427	2	1426105297
1312852600	1	f	2669	2	1426109454
1314178938	1	t	2552	2	1426166074
1314364419	1	f	1192	2	1426170287
1314732543	1	f	2043	2	1426180004
1314848809	1	f	1701	2	1426183810
1315027871	1	t	2770	2	1426190316
1317023558	1	f	2489	2	1426262250
1317237758	1	f	1380	2	1426267562
1319817022	1	f	3997	2	1426346102
1320174428	1	t	2238	2	1426354085
1320307272	1	t	2553	2	1426357513
1320443439	1	t	2129	2	1426361588
1322649293	1	t	1879	2	1426429500
1322810747	1	f	2207	2	1426433184
1324856065	1	t	3203	2	1426512783
1325053670	1	t	4699	2	1426516665
1325298819	1	f	2547	2	1426524186
1325440798	1	f	4211	2	1426528205
1325600389	1	f	1709	2	1426533907
1325670455	1	f	2528	2	1426536866
1327893173	1	f	3706	1	1426619075
1328022360	1	f	3237	2	1426624622
1329883121	1	t	1951	2	1426695254
1329991365	1	t	4529	2	1426698393
1330237858	1	t	1482	2	1426706672
1330306348	1	t	1918	2	1426709542
1330369067	1	f	3526	2	1426712683
1331872548	1	f	2088	2	1426773700
1702814591	2	t	2998	2	1439224752
1702969127	2	f	3549	2	1439229217
1703170077	2	t	2904	2	1439235642
1705590212	2	f	2990	2	1439312250
1705755149	2	t	2359	2	1439317223
1705866389	2	f	3784	2	1439320840
1708245455	2	f	1375	2	1439396711
1708341097	2	t	2249	2	1439399400
1711087497	2	t	2522	2	1439488900
1711229087	2	t	2265	2	1439493484
1711327870	2	f	2148	2	1439497064
1711418546	2	f	3885	2	1439500821
1713230455	2	f	1756	2	1439562622
1713395218	2	f	2589	2	1439566103
1716057540	2	f	3302	2	1439647279
1716321142	2	t	2660	2	1439652535
1716522810	2	t	2425	2	1439657218
1716819375	2	f	1868	2	1439665496
1716998000	2	f	1351	2	1439671527
1719147866	2	t	1518	2	1439735090
1719624915	2	f	2962	2	1439746994
1719764895	2	f	2714	2	1439751211
1719882456	2	f	3023	2	1439755096
1720012133	2	t	2478	2	1439760056
1721993868	2	f	2689	2	1439824705
1722191943	2	f	2273	2	1439829734
1725032466	2	t	2536	2	1439921805
2154515714	3	f	2567	22	1455558720
2154635335	3	f	1059	2	1455561612
2156775205	3	f	2437	2	1455646609
2158744285	3	f	1907	1	1455724847
2158848463	3	t	2996	2	1455729521
2159000477	3	f	2939	2	1455734244
2160882034	3	t	3187	2	1455817365
2331151196	3	t	2666	2	1462042338
2331291800	3	f	1826	2	1462045861
2331397959	3	t	2571	2	1462050317
2331504469	3	f	2425	2	1462054430
2461818948	3	t	3646	2	1466888082
2461941311	3	t	1397	2	1466890983
2462017743	3	t	2172	1	1466894838
2794477637	3	t	2491	2	1479758554
2794553406	3	t	1507	2	1479761024
2794609120	3	t	1886	2	1479764268
2794661867	3	t	4020	2	1479769773
2996445772	3	t	3058	2	1487020010
2996520603	3	t	2495	2	1487023766
2996574726	3	t	3353	2	1487028145
3000196297	3	t	1843	2	1487188178
3000306747	3	f	2151	2	1487194122
3000358491	3	f	2487	2	1487197737
3000419525	3	t	3821	2	1487203530
3001863568	3	t	3729	2	1487267046
3002034420	3	t	1565	2	1487270076
3002118520	3	f	3124	2	1487275307
3002216481	3	f	2118	2	1487278804
3008178398	3	t	1804	2	1487515417
3008343435	3	t	1939	2	1487520137
3008451294	3	t	1524	2	1487523181
3008536849	3	t	2737	2	1487527166
3008653479	3	f	3093	2	1487531871
3008777193	3	t	2062	2	1487536029
3008858859	3	f	2835	2	1487540800
3010553346	3	f	3586	2	1487618728
3010695767	3	f	3726	2	1487625341
3010796852	3	t	2339	2	1487629483
3012327928	3	t	2117	2	1487697931
3012422428	3	t	2582	2	1487702158
3012523678	3	t	2126	2	1487705664
3012602214	3	t	2981	2	1487710039
3012695636	3	t	4138	2	1487716330
3013953614	3	f	4553	2	1487778348
3014167185	3	t	1838	2	1487782136
3014257086	3	t	2352	2	1487785743
3014358368	3	f	2082	2	1487789248
3014446376	3	t	3545	2	1487794913
3014586927	3	t	1711	2	1487798585
3016359318	3	t	3722	2	1487878367
3016597449	3	t	2604	2	1487886725
3016673220	3	t	3130	2	1487891568
3016745235	3	t	2111	2	1487895603
3020583453	3	f	2513	2	1488041004
3020726832	3	t	3437	2	1488046082
3020905680	3	t	2421	2	1488050246
3021019294	3	t	2850	2	1488054490
3021150471	3	f	2292	2	1488058900
3022990507	3	t	2345	2	1488129130
3023089967	3	t	3400	2	1488133968
3023257102	3	f	1100	2	1488137115
3025296499	3	t	2211	1	1488229061
3025348109	3	t	2807	2	1488233175
3027083936	3	t	2775	2	1488311775
3027168796	3	f	2395	2	1488315315
3027253660	3	t	1998	2	1488319971
3027302752	3	t	2718	2	1488324748
3028769261	3	t	2339	2	1488389890
3029116101	3	t	2409	2	1488405361
3029210893	3	t	1753	2	1488411679
3069482442	3	f	3397	2	1490124788
3069593212	3	f	3135	2	1490129345
3075313946	3	t	3212	2	1490382203
3075486152	3	t	4484	2	1490390442
3077353510	3	f	3518	2	1490461413
3077525860	3	t	2742	2	1490465782
3077715640	3	t	3207	2	1490472231
3077845335	3	t	1906	2	1490476447
3077914435	3	f	3239	2	1490481122
3078009474	3	f	4010	1	1490486821
3079846890	3	t	2412	2	1490550683
3079950374	3	t	2293	2	1490554437
3080043012	3	t	3036	2	1490558891
3080142706	3	f	2655	2	1490563258
3081724512	3	t	2017	2	1490634706
3081813180	3	t	2252	2	1490638243
3081894892	3	f	2084	2	1490641331
3081966950	3	t	1891	2	1490644349
3082037038	3	t	1293	2	1490647041
3083980806	3	t	2587	2	1490734616
3084053502	3	f	2325	2	1490738402
3085593226	3	f	4109	2	1490810429
3085744568	3	t	1998	2	1490813999
3085816017	3	t	2898	2	1490818154
3085905223	3	f	2381	2	1490822251
3085967050	3	f	2904	2	1490827253
3087776760	3	t	2670	2	1490903434
3087858685	3	f	2426	2	1490907171
3089707778	3	f	2168	2	1490984469
3089803824	3	f	2146	2	1490988269
3089921112	3	t	3259	2	1490994479
3090030420	3	f	2183	2	1490998746
3090093196	3	f	1835	2	1491002166
3091864405	3	t	925	2	1491068663
3538436243	4	f	2034	2	1509651496
3538546945	4	f	2240	2	1509656225
3538622705	4	f	2366	2	1509659928
3538682725	4	t	2571	2	1509663590
3540213420	4	f	1995	2	1509725499
3540314230	4	t	1448	2	1509727931
3540695097	4	f	1770	2	1509741525
3540778400	4	f	3868	2	1509747666
3540876223	4	f	1406	2	1509750459
3540922574	4	t	2740	2	1509754321
3542087676	4	t	2632	2	1509800555
3542243386	4	t	2565	2	1509804579
3542416731	4	f	2076	2	1509808020
3542567886	4	t	1943	2	1509811674
3542687946	4	t	2297	2	1509815169
3542815871	4	f	1656	2	1509818256
3542905672	4	f	2009	2	1509821433
3542996960	4	t	1768	2	1509824503
3543082126	4	f	3945	2	1509830040
3544586761	4	f	2850	2	1509889427
3544760806	4	f	2702	2	1509893720
3544920819	4	t	2799	2	1509898415
3545063706	4	t	4609	2	1509904684
3545245498	4	f	4217	2	1509911010
3547048847	4	t	2464	2	1509989621
3547154304	4	f	2527	2	1509993348
3547277729	4	f	1396	2	1509998474
3547333480	4	f	2369	2	1510002443
3549048284	4	t	2285	2	1510085438
3549120144	4	f	2067	2	1510089069
3550640644	4	t	316	2	1510163523
3550695993	4	t	2537	2	1510168158
3552513216	4	t	2419	2	1510257749
3554323664	4	f	2929	2	1510341544
3554449842	4	t	2438	2	1510346550
3554525848	4	f	2693	2	1510350815
3554599628	4	t	1680	2	1510353812
3554656831	4	t	1658	2	1510357611
\.


--
-- Name: match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.match_id_seq', 1, false);


--
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.player (steam_id, nickname, avatar, avatar_medium) FROM stdin;
76561198064103935	D-SOL	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7c9b257d85752a19677f4a739891f87ca5dcab19.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7c9b257d85752a19677f4a739891f87ca5dcab19_medium.jpg
76561198054682692	Gava'xy	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8f/8fe83ba4cea9ee46528120c07d35d8b49b345637.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8f/8fe83ba4cea9ee46528120c07d35d8b49b345637_medium.jpg
76561197988794786	V DAMKI	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7e/7e06d3a3c6ef5c6ad765bdf9524b677d83600fdb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7e/7e06d3a3c6ef5c6ad765bdf9524b677d83600fdb_medium.jpg
76561197977893604	MONk	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f38b51df69cd2ca84c16c2320906f9a29290c5d2.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f38b51df69cd2ca84c16c2320906f9a29290c5d2_medium.jpg
76561198087038627	Who's that handsome devil? >:)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/27/27c169006fdb7ed6294ac28d19b21f5906854184.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/27/27c169006fdb7ed6294ac28d19b21f5906854184_medium.jpg
76561198070896680	Gaaaanks	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b4/b404d2fe0f5b29eab36b30341e858eac938cb5f1.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b4/b404d2fe0f5b29eab36b30341e858eac938cb5f1_medium.jpg
76561198036168458	Dardvas	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/3a/3aaf7f70df41708723333c608b4440d679480224.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/3a/3aaf7f70df41708723333c608b4440d679480224_medium.jpg
76561198053792883	Stephen Hawking	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ae/ae5554bd3cf35401b3440a16905d04ab2d823ac1.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ae/ae5554bd3cf35401b3440a16905d04ab2d823ac1_medium.jpg
76561198047287923	FuckToy$	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/56/56189f018f1e954484d53e56efb5c43b6027a5c7.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/56/56189f018f1e954484d53e56efb5c43b6027a5c7_medium.jpg
76561198049523020	@revolution	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c25bed78405b350a9d95a156c7d1ccdcd0f15a42.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c25bed78405b350a9d95a156c7d1ccdcd0f15a42_medium.jpg
76561197984825338	FuckingFisheR	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/61/6196ad22209b7912e8e641aa555ab7f88e5ef790.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/61/6196ad22209b7912e8e641aa555ab7f88e5ef790_medium.jpg
76561198125222713	V.	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fd/fdbf6c1c6f86ec9d644fb522885b88794983b9a3.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fd/fdbf6c1c6f86ec9d644fb522885b88794983b9a3_medium.jpg
76561198062081877	-=MonT=-	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b0/b0b6b0fd716b0a96b9b54d79caf8ba44a0cf1035.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b0/b0b6b0fd716b0a96b9b54d79caf8ba44a0cf1035_medium.jpg
76561198029001894	#zusisback	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/4e/4e882aac676ac19bab94564d48fa199d0d2fb21f.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/4e/4e882aac676ac19bab94564d48fa199d0d2fb21f_medium.jpg
76561198155142404	JohnyDillinger	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/48/48da08297e8c9360f69080eab574d2c930e015a4.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/48/48da08297e8c9360f69080eab574d2c930e015a4_medium.jpg
76561198084230991	BOOMDROP.RU - csfate.com	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/25/25e82d3b49511f7e295de3d8e6bc83ecf5b4e249.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/25/25e82d3b49511f7e295de3d8e6bc83ecf5b4e249_medium.jpg
76561198154638721	alexka2	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg
76561198011090115	Tema SnapDragon	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a5/a5303da756ed7b94ee7c308ac910b123bb836d41.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a5/a5303da756ed7b94ee7c308ac910b123bb836d41_medium.jpg
76561198015535768	Инженер РЗА	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/dc/dc12e13fc2fa241167366a2be4846b6ccfc7717a.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/dc/dc12e13fc2fa241167366a2be4846b6ccfc7717a_medium.jpg
76561198110443918	jonik	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/9a/9aeb2179f2e2994b68ece0e1e124ec0cb51623ce.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/9a/9aeb2179f2e2994b68ece0e1e124ec0cb51623ce_medium.jpg
76561198013030157	no banditos	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/6c/6ce0605997254e551dfb5268659f3be95ee7c2b4.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/6c/6ce0605997254e551dfb5268659f3be95ee7c2b4_medium.jpg
76561198046244483	Mirror's	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/9a/9a8b0049c0b82f829cce3dd233b6e0fccc8d6c08.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/9a/9a8b0049c0b82f829cce3dd233b6e0fccc8d6c08_medium.jpg
76561198064640960	1337	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/de/de0cd8cb6d45ba50790e08acf4a0dec5b30ff0ec.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/de/de0cd8cb6d45ba50790e08acf4a0dec5b30ff0ec_medium.jpg
76561198025119322	боженька	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/0c/0ce944f709ce7185d3533b0d33319a2594970281.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/0c/0ce944f709ce7185d3533b0d33319a2594970281_medium.jpg
76561198100751924	∑ᶍṫϒ	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f5/f532b7bd267d42cc9baaa5845d6d024f75334a35.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f5/f532b7bd267d42cc9baaa5845d6d024f75334a35_medium.jpg
76561198073202489	๋	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fb/fb9c36c36e54b8ca5f2e1cbd89c06574d1348af0.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fb/fb9c36c36e54b8ca5f2e1cbd89c06574d1348af0_medium.jpg
76561198047190001	boris nemtsov	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/37/3712cdad061fabfe31d93a62422c7595b16a9eba.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/37/3712cdad061fabfe31d93a62422c7595b16a9eba_medium.jpg
76561198047431797	babay	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/13/133e4f14d9db26a245f7f3f0753b5e497d3d9f9b.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/13/133e4f14d9db26a245f7f3f0753b5e497d3d9f9b_medium.jpg
76561198073971993	Alens1	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/29/293a642fe9675e36b641bf66806b5c217fbaa998.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/29/293a642fe9675e36b641bf66806b5c217fbaa998_medium.jpg
76561198068053655	I Will Leave	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/af/afac67620da36b7791ea8328b687f98cb0fca59b.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/af/afac67620da36b7791ea8328b687f98cb0fca59b_medium.jpg
76561198097757646	OKLAHOMA CITY SHUFFLE	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/18/18eb437336453b8e045a4110aed499cbb37b673d.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/18/18eb437336453b8e045a4110aed499cbb37b673d_medium.jpg
76561198074266816	nojery	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/67/678e0cbeaeb25e61fd9641ef4f3fff73ceedbba8.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/67/678e0cbeaeb25e61fd9641ef4f3fff73ceedbba8_medium.jpg
76561198072791186	Nigh[T]mar3	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7cc19e792eefd3174bcc10969d9307ae7e2a7531.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7cc19e792eefd3174bcc10969d9307ae7e2a7531_medium.jpg
76561198050567489	RockinShock	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/88/88827fdd5396d34795e024aeaa8dd736bb91848e.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/88/88827fdd5396d34795e024aeaa8dd736bb91848e_medium.jpg
76561198078115598	Darik	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/80/804093ce1d68c0573cc3221b869a6fe05429f615.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/80/804093ce1d68c0573cc3221b869a6fe05429f615_medium.jpg
76561198050981415	N.	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da768daacd5d1e04e25e1ecd2761893e59803276.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da768daacd5d1e04e25e1ecd2761893e59803276_medium.jpg
76561197981436383	Blood Borya	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/06/0670ba12e179ef39f5bfe19c551f33efa7e67882.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/06/0670ba12e179ef39f5bfe19c551f33efa7e67882_medium.jpg
76561198103774744	Disappoinment Around	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/4a/4afde18a14d26982e9a0b61904a52ae90ae8c526.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/4a/4afde18a14d26982e9a0b61904a52ae90ae8c526_medium.jpg
76561198139750363	ЭЛЬБРУС	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ba/ba4f5610b7309c1f16c961859e7649eabe24501c.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ba/ba4f5610b7309c1f16c961859e7649eabe24501c_medium.jpg
76561198044189044	Карл...!)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8f/8f8256d18b86e83fed54c49302d61a36bf0a23e1.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8f/8f8256d18b86e83fed54c49302d61a36bf0a23e1_medium.jpg
76561198114085939	Raka_EL	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg
76561198016217359	panKelo	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/22/22bce46e07f7558d43ecf34980e25b285c47702d.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/22/22bce46e07f7558d43ecf34980e25b285c47702d_medium.jpg
76561198145970413	Kyle	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/60/6001ebd0adc28ce8683c01637210d8786b24d737.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/60/6001ebd0adc28ce8683c01637210d8786b24d737_medium.jpg
76561198029784649	Holerious♥	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/aa/aa042f059b660539b8f596b1a7c37f3299b8f389.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/aa/aa042f059b660539b8f596b1a7c37f3299b8f389_medium.jpg
76561197997266515	HUH?!	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/09/093751910c1d9798e1b435783c3d646e728dc474.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/09/093751910c1d9798e1b435783c3d646e728dc474_medium.jpg
76561198063209393	ХотМьёв	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c0/c07f39a69db037e8feda022c902eef74c0856c78.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c0/c07f39a69db037e8feda022c902eef74c0856c78_medium.jpg
76561198031559450	00	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/62/62bcfd8dbd0de21466070bd9a1336ee89b61d655.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/62/62bcfd8dbd0de21466070bd9a1336ee89b61d655_medium.jpg
76561198056481765	Solitude	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/d8/d8aa3f0883b3d4f51f1561f7069156c9dcf7846a.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/d8/d8aa3f0883b3d4f51f1561f7069156c9dcf7846a_medium.jpg
76561198047223952	ara	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/46/46db7e64457b1bde8ba8d2f27fab825413bfbf50.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/46/46db7e64457b1bde8ba8d2f27fab825413bfbf50_medium.jpg
76561197984868652	Voboroten ಠ_ಠ	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b5/b5c5a87db0b05e6fed2484ea8056c84b6ef15783.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b5/b5c5a87db0b05e6fed2484ea8056c84b6ef15783_medium.jpg
76561197968587871	InFlaTeD	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/42/42e99ec86a5634bef89bde983b2e84a220c9cd06.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/42/42e99ec86a5634bef89bde983b2e84a220c9cd06_medium.jpg
76561198073588713	twitch.tv/hyper_pulse	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/be/be326bc0e9f8a8633e74669eca56fde342c182a4.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/be/be326bc0e9f8a8633e74669eca56fde342c182a4_medium.jpg
76561198063645309	Ozzies	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/14/14ebf9938b8db5b72608cfdb930793d5f8fcd828.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/14/14ebf9938b8db5b72608cfdb930793d5f8fcd828_medium.jpg
76561198074711025	BAD_BOI	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d46404bdd436c2e2ade9682bcb71480a80ac159.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d46404bdd436c2e2ade9682bcb71480a80ac159_medium.jpg
76561198047822188	EzaloR	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/57/570988c6a0b7a5d80d7ff6518b0e5af74bac2f1d.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/57/570988c6a0b7a5d80d7ff6518b0e5af74bac2f1d_medium.jpg
76561198000576954	Ayan	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b3/b36899f44f7e0d013ceba25d7eb21ddeebcbb5c6.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b3/b36899f44f7e0d013ceba25d7eb21ddeebcbb5c6_medium.jpg
76561198041583699	IliasDidNothingWrong	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d5fc2326e4ea7463e6bc8fcc2a503e4fbc328cd.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d5fc2326e4ea7463e6bc8fcc2a503e4fbc328cd_medium.jpg
76561198047815659	DevilNevermore	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/e5/e5cebf4fcbaef55598a9bfd59f78e667d5eb7d00.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/e5/e5cebf4fcbaef55598a9bfd59f78e667d5eb7d00_medium.jpg
76561198056568682	[iddQd] iEvansRed (Evans)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/48/48ff64f9888c78938cfac4dfee78aa24dec8c2c1.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/48/48ff64f9888c78938cfac4dfee78aa24dec8c2c1_medium.jpg
76561198052402193	Yato	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/60/6057de092ab86efd8ee7031de10552e85a9cb50c.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/60/6057de092ab86efd8ee7031de10552e85a9cb50c_medium.jpg
76561198122375492	Vox	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/e8/e8616894b3fc3931839feea890bb7b9f106a2f27.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/e8/e8616894b3fc3931839feea890bb7b9f106a2f27_medium.jpg
76561198056236087	my love	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/bb/bb0771a73096dea698b0e6ec2f2438436b3b7099.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/bb/bb0771a73096dea698b0e6ec2f2438436b3b7099_medium.jpg
76561198061772583	jFUNK	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/3e/3e6662ea79d8d4225878acd9b9a5c86c9fb50e74.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/3e/3e6662ea79d8d4225878acd9b9a5c86c9fb50e74_medium.jpg
76561198040981068	vf.	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ee/ee3e0d2c127cf4406053ffe428bb4de28b4b6070.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ee/ee3e0d2c127cf4406053ffe428bb4de28b4b6070_medium.jpg
76561197993923694	.ю	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a41b4e815c30076d7f1ebed12706de5989df5631.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a41b4e815c30076d7f1ebed12706de5989df5631_medium.jpg
76561198067027003	Sorum;	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b3/b30b3ddae067857775f31aff1f071d364359f379.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b3/b30b3ddae067857775f31aff1f071d364359f379_medium.jpg
76561198049386294	Jemdo	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/cd/cdd4b1f25d31f91cda77b2b890dd9b1d9edc6126.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/cd/cdd4b1f25d31f91cda77b2b890dd9b1d9edc6126_medium.jpg
76561197996770593	Excellent	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg
76561198077176110	Chip (offlane only)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/24/241f9986fdae09a27ced58bdb3466ba7c7403825.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/24/241f9986fdae09a27ced58bdb3466ba7c7403825_medium.jpg
76561198020742538	Solo	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/29/295a19abc4cc9b767c28b54b8b2859322eff9035.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/29/295a19abc4cc9b767c28b54b8b2859322eff9035_medium.jpg
76561198334460348	XIX	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/5b/5b70fc8559391254eb1d1b8c664295bf0829d933.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/5b/5b70fc8559391254eb1d1b8c664295bf0829d933_medium.jpg
76561198349109618	Ololo	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b1/b172a1c35b3fdcb55c7d50dbbd1b0c0f817b1ff6.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b1/b172a1c35b3fdcb55c7d50dbbd1b0c0f817b1ff6_medium.jpg
76561198321243292	◥◣Alensir◢◤	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a4aedfdb39094d7d8921edbe662c3e5a3c23ed60.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a4aedfdb39094d7d8921edbe662c3e5a3c23ed60_medium.jpg
76561198166729266	seega	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/1e/1e8efc65528ca644e2a654578d131cf0d06e929f.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/1e/1e8efc65528ca644e2a654578d131cf0d06e929f_medium.jpg
76561198049220301	[0i0]	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b8/b86b51f88ffce120030e1e9c74b1ea1817cc1abf.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b8/b86b51f88ffce120030e1e9c74b1ea1817cc1abf_medium.jpg
76561198157310514	very mean	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/92/922909196f5d705f036ca9cfd4a3c5d6b181cf8a.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/92/922909196f5d705f036ca9cfd4a3c5d6b181cf8a_medium.jpg
76561198086133183	☛CeNTR	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a2/a2d1000f267f3bacaafd53848b3ac572aa655aa5.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a2/a2d1000f267f3bacaafd53848b3ac572aa655aa5_medium.jpg
76561198054368968	Малайка	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/30/302ad7d0b2e2c00460a54f43df1caf573b1df82b.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/30/302ad7d0b2e2c00460a54f43df1caf573b1df82b_medium.jpg
76561198092655025	Mr.N7.G2A	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/18/183f96fd92f2f457b587501fc52fce02bec2afd0.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/18/183f96fd92f2f457b587501fc52fce02bec2afd0_medium.jpg
76561198066455570	SpIrT	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b2/b2e8590d521ea35384193346f6a90c3fccd2c344.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b2/b2e8590d521ea35384193346f6a90c3fccd2c344_medium.jpg
76561198158099214	Ди	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/47/4799a60d6e6660298b01bac259d54639a4b462a9.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/47/4799a60d6e6660298b01bac259d54639a4b462a9_medium.jpg
76561198029055164	(V)О_о(V) Kraban	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a4a3001e9af6e30429d45b30555ffd1b2bdd0718.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/a4/a4a3001e9af6e30429d45b30555ffd1b2bdd0718_medium.jpg
76561198160172458	Asoka Tano	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/50/5033392b8e8e0e31cfd57a27c02ecac9f316a6fb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/50/5033392b8e8e0e31cfd57a27c02ecac9f316a6fb_medium.jpg
76561198045178572	Nyarlathotep	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d1dba4364f565db51b87d9f2e4775ab17ed6bbc.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8d/8d1dba4364f565db51b87d9f2e4775ab17ed6bbc_medium.jpg
76561198070524578	ZerFest (奥厄)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8e/8ebc04b16176432267695e9cc1aa10525e339ebe.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/8e/8ebc04b16176432267695e9cc1aa10525e339ebe_medium.jpg
76561198026718418	#niceslice	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ac/ac5cefd874614e1f0b63da65d0f1441fc7fd3087.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/ac/ac5cefd874614e1f0b63da65d0f1441fc7fd3087_medium.jpg
76561198087315989	Derwil | BuddahBear	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7e/7efdb879573c6ed01219617467a33373dc6fe93c.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7e/7efdb879573c6ed01219617467a33373dc6fe93c_medium.jpg
76561198243575514	Tiurg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f7/f78969c858b04a3238523279568622e6769bc091.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f7/f78969c858b04a3238523279568622e6769bc091_medium.jpg
76561198012217055	Ice-Snake	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c2be3412bb3701fe42bbe468eb689803e9a353ed.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c2be3412bb3701fe42bbe468eb689803e9a353ed_medium.jpg
76561198006183979	Koyaanisqatsi	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/6e/6e668a02a7f36bdbc04a49f7d97b37b9fb7b4c64.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/6e/6e668a02a7f36bdbc04a49f7d97b37b9fb7b4c64_medium.jpg
76561198047012382	Djet	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/24/2495aa3852274cf74c9a160d560b7eb465195b3c.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/24/2495aa3852274cf74c9a160d560b7eb465195b3c_medium.jpg
76561198203934173	Di na	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/42/42f2861c86a9e8889c2c9dcfa4d7aaea0978533b.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/42/42f2861c86a9e8889c2c9dcfa4d7aaea0978533b_medium.jpg
76561198140337230	💕	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c2e7d2fc768189457ef05c3764237bf947d14d9b.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/c2/c2e7d2fc768189457ef05c3764237bf947d14d9b_medium.jpg
76561198123893031	Farawey	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/87/87fe6594adc7d5f97f2a46974686cbe9e98964c2.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/87/87fe6594adc7d5f97f2a46974686cbe9e98964c2_medium.jpg
76561198062517379	Puck Shaqalov	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b6/b62f26a2677ee7db4d2639d0fbbaccceaabb15ac.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/b6/b62f26a2677ee7db4d2639d0fbbaccceaabb15ac_medium.jpg
76561197978556490	Ашот_НаГубе_CumShot	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/53/53748c8ccb6f90b0370f42258b1571e8cfc7fff5.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/53/53748c8ccb6f90b0370f42258b1571e8cfc7fff5_medium.jpg
76561198432160076	燃烧 (1,2)	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_medium.jpg
76561198077196808	Nice FORCEDROP.net	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/2b/2bc8aaccc0cf07a005c6ec5f4eb2d71481debabb.jpg	https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/2b/2bc8aaccc0cf07a005c6ec5f4eb2d71481debabb_medium.jpg
\.


--
-- Data for Name: player_match_item; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.player_match_item (id, player_match_stats_id, name) FROM stdin;
1	2617	item_travel_boots
2	2617	item_mantle
3	2617	item_mantle
4	2617	item_ultimate_scepter
5	2617	item_aether_lens
6	2617	item_tpscroll
7	2618	item_urn_of_shadows
8	2618	item_travel_boots
9	2618	item_force_staff
10	2618	item_aether_lens
11	2618	item_ultimate_scepter
12	2618	item_trident
13	2619	item_blade_mail
14	2619	item_phase_boots
15	2619	item_hurricane_pike
16	2619	item_mask_of_madness
17	2619	item_manta
18	2619	item_rapier
19	2620	item_crimson_guard
20	2620	item_blade_mail
21	2620	item_pipe
22	2620	item_magic_wand
23	2620	item_ring_of_health
24	2620	item_guardian_greaves
25	2621	item_heavens_halberd
26	2621	item_ward_sentry
27	2621	item_ghost
28	2621	item_glimmer_cape
29	2621	item_tranquil_boots
30	2621	item_magic_wand
31	2622	item_cyclone
32	2622	item_veil_of_discord
33	2622	item_ultimate_scepter
34	2622	item_trident
35	2622	item_aether_lens
36	2622	item_tpscroll
37	2623	item_power_treads
38	2623	item_ring_of_aquila
39	2623	item_radiance
40	2623	item_stout_shield
41	2623	item_diffusal_blade
42	2623	item_manta
43	2624	item_blade_mail
44	2624	item_spirit_vessel
45	2624	item_magic_wand
46	2624	item_tpscroll
47	2624	item_ogre_axe
48	2624	item_power_treads
49	2625	item_stout_shield
50	2625	item_blink
51	2625	item_magic_wand
52	2625	item_guardian_greaves
53	2625	item_shivas_guard
54	2625	item_soul_ring
55	2626	item_aether_lens
56	2626	item_wind_lace
57	2626	item_point_booster
58	2626	item_tranquil_boots
59	2626	item_ward_observer
60	2626	item_tpscroll
121	2637	item_blink
122	2637	item_necronomicon_3
123	2637	item_magic_wand
124	2637	item_power_treads
125	2637	item_tpscroll
126	2637	item_stout_shield
127	2638	item_power_treads
128	2638	item_vladmir
129	2638	item_maelstrom
130	2638	item_ring_of_aquila
131	2638	item_manta
132	2638	item_invis_sword
133	2639	item_blade_mail
134	2639	item_heavens_halberd
135	2639	item_ancient_janggo
136	2639	item_phase_boots
137	2639	item_urn_of_shadows
138	2639	item_platemail
139	2640	item_orchid
140	2640	item_veil_of_discord
141	2640	item_power_treads
142	2640	item_sheepstick
143	2640	item_hand_of_midas
144	2640	item_maelstrom
145	2641	item_helm_of_iron_will
146	2641	item_ward_dispenser
147	2641	item_wind_lace
148	2641	item_arcane_boots
149	2641	item_glimmer_cape
150	2641	item_tpscroll
151	2642	item_blink
152	2642	item_travel_boots
153	2642	item_tpscroll
154	2642	item_trident
155	2642	item_ward_sentry
156	2642	item_tpscroll
157	2643	item_travel_boots
158	2643	item_abyssal_blade
159	2643	item_manta
160	2643	item_butterfly
161	2643	item_bfury
162	2643	item_ultimate_scepter
163	2644	item_blink
164	2644	item_arcane_boots
165	2644	item_aether_lens
166	2644	item_wind_lace
167	2644	item_ultimate_scepter
168	2644	item_ward_observer
169	2645	item_arcane_boots
170	2645	item_refresher
171	2645	item_ward_dispenser
172	2645	item_ultimate_scepter
173	2645	item_hand_of_midas
174	2645	item_pers
175	2646	item_mask_of_madness
176	2646	item_hurricane_pike
177	2646	item_mjollnir
178	2646	item_ring_of_aquila
179	2646	item_tpscroll
180	2646	item_power_treads
181	2647	item_magic_wand
182	2647	item_arcane_boots
183	2647	item_infused_raindrop
184	2647	item_tpscroll
185	2647	item_wind_lace
186	2647	item_ward_observer
187	2648	item_phase_boots
188	2648	item_infused_raindrop
189	2648	item_ring_of_aquila
190	2648	item_tpscroll
191	2648	item_manta
192	2648	item_clarity
193	2649	item_aether_lens
194	2649	item_bottle
195	2649	item_null_talisman
196	2649	item_tpscroll
197	2649	item_boots
198	2649	item_magic_wand
199	2650	item_tpscroll
200	2650	item_magic_wand
201	2650	item_ward_dispenser
202	2650	item_smoke_of_deceit
203	2650	item_branches
204	2650	item_tranquil_boots
205	2651	item_blink
206	2651	item_stout_shield
207	2651	item_broadsword
208	2651	item_ring_of_health
209	2651	item_tranquil_boots
210	2651	item_tpscroll
211	2652	item_arcane_boots
212	2652	item_tpscroll
213	2652	item_enchanted_mango
214	2652	item_staff_of_wizardry
215	2652	item_ogre_axe
216	2652	item_tpscroll
217	2653	item_urn_of_shadows
218	2653	item_wind_lace
219	2653	item_boots
220	2653	item_aether_lens
221	2653	item_ward_dispenser
222	2653	item_blink
223	2654	item_ring_of_aquila
224	2654	item_phase_boots
225	2654	item_echo_sabre
226	2654	item_moon_shard
227	2654	item_stout_shield
228	2654	item_quelling_blade
229	2655	item_trident
230	2655	item_bloodstone
231	2655	item_power_treads
232	2655	item_bottle
233	2655	item_soul_ring
234	2655	item_magic_wand
235	2656	item_magic_wand
236	2656	item_cloak
237	2656	item_tpscroll
238	2656	item_stout_shield
239	2656	item_ring_of_health
240	2656	item_guardian_greaves
241	2657	item_tranquil_boots
242	2657	item_point_booster
243	2657	item_ogre_axe
244	2657	item_staff_of_wizardry
245	2657	item_tpscroll
246	2657	item_ward_sentry
247	2658	item_tranquil_boots
248	2658	item_urn_of_shadows
249	2658	item_glimmer_cape
250	2658	item_gem
251	2658	item_wind_lace
252	2658	item_dust
253	2659	item_phase_boots
254	2659	item_basher
255	2659	item_manta
256	2659	item_ultimate_orb
257	2659	item_invis_sword
258	2659	item_bottle
259	2660	item_blink
260	2660	item_phase_boots
261	2660	item_quelling_blade
262	2660	item_armlet
263	2660	item_desolator
264	2660	item_tpscroll
265	2661	item_magic_wand
266	2661	item_blink
267	2661	item_tpscroll
268	2661	item_ultimate_scepter
269	2661	item_wind_lace
270	2661	item_arcane_boots
271	2662	item_phase_boots
272	2662	item_blink
273	2662	item_invis_sword
274	2662	item_magic_wand
275	2662	item_hand_of_midas
276	2662	item_octarine_core
277	2663	item_solar_crest
278	2663	item_glimmer_cape
279	2663	item_tpscroll
280	2663	item_power_treads
281	2663	item_ultimate_scepter
282	2663	item_magic_wand
283	2664	item_power_treads
284	2664	item_sphere
285	2664	item_shivas_guard
286	2664	item_orchid
287	2664	item_bloodstone
288	2664	item_travel_boots
289	2665	item_diffusal_blade
290	2665	item_eagle
291	2665	item_manta
292	2665	item_power_treads
293	2665	item_heart
294	2665	item_aegis
295	2666	item_smoke_of_deceit
296	2666	item_phase_boots
297	2666	item_tpscroll
298	2666	item_spirit_vessel
299	2666	item_ward_sentry
300	2666	item_dust
301	2667	item_silver_edge
302	2667	item_phase_boots
303	2667	item_hurricane_pike
304	2667	item_ring_of_aquila
305	2667	item_magic_wand
306	2667	item_desolator
307	2668	item_assault
308	2668	item_abyssal_blade
309	2668	item_power_treads
310	2668	item_manta
311	2668	item_butterfly
312	2668	item_bfury
313	2669	item_arcane_boots
314	2669	item_orb_of_venom
315	2669	item_aether_lens
316	2669	item_tpscroll
317	2669	item_force_staff
318	2669	item_ward_observer
319	2670	item_power_treads
320	2670	item_hand_of_midas
321	2670	item_manta
322	2670	item_diffusal_blade
323	2670	item_wraith_band
324	2670	item_bottle
325	2671	item_tranquil_boots
326	2671	item_blink
327	2671	item_pipe
328	2671	item_heart
329	2671	item_gem
330	2671	item_ultimate_scepter
331	2672	item_phase_boots
332	2672	item_invis_sword
333	2672	item_vladmir
334	2672	item_mithril_hammer
335	2672	item_tpscroll
336	2672	item_sange_and_yasha
337	2673	item_phase_boots
338	2673	item_nullifier
339	2673	item_hand_of_midas
340	2673	item_ultimate_scepter
341	2673	item_flask
342	2673	item_blink
343	2674	item_magic_wand
344	2674	item_phase_boots
345	2674	item_tpscroll
346	2674	item_spirit_vessel
347	2674	item_ward_observer
348	2674	item_dust
349	2675	item_magic_wand
350	2675	item_blade_mail
351	2675	item_tpscroll
352	2675	item_vanguard
353	2675	item_cloak
354	2675	item_guardian_greaves
355	2676	item_wind_lace
356	2676	item_staff_of_wizardry
357	2676	item_bracer
358	2676	item_arcane_boots
359	2676	item_glimmer_cape
360	2676	item_gem
361	2677	item_black_king_bar
362	2677	item_phase_boots
363	2677	item_magic_wand
364	2677	item_bfury
365	2677	item_ring_of_aquila
366	2677	item_javelin
367	2678	item_power_treads
368	2678	item_stout_shield
369	2678	item_bfury
370	2678	item_javelin
371	2678	item_manta
372	2678	item_ring_of_aquila
373	2679	item_arcane_boots
374	2679	item_blink
375	2679	item_magic_wand
376	2679	item_wind_lace
377	2679	item_tpscroll
378	2679	item_dust
379	2680	item_cloak
380	2680	item_magic_wand
381	2680	item_phase_boots
382	2680	item_chainmail
383	2680	item_ultimate_scepter
384	2680	item_broadsword
385	2681	item_dagon_3
386	2681	item_blink
387	2681	item_enchanted_mango
388	2681	item_null_talisman
389	2681	item_wind_lace
390	2681	item_arcane_boots
391	2682	item_magic_wand
392	2682	item_blade_mail
393	2682	item_black_king_bar
394	2682	item_travel_boots
395	2682	item_tpscroll
396	2682	item_radiance
397	2683	item_travel_boots
398	2683	item_trident
399	2683	item_cyclone
400	2683	item_bottle
401	2683	item_soul_ring
402	2683	item_bloodstone
403	2684	item_urn_of_shadows
404	2684	item_boots
405	2684	item_gem
406	2684	item_cyclone
407	2684	item_aether_lens
408	2684	item_blink
409	2685	item_gem
410	2685	item_necronomicon_3
411	2685	item_ultimate_scepter
412	2685	item_blink
413	2685	item_tranquil_boots
414	2685	item_magic_wand
415	2686	item_arcane_boots
416	2686	item_force_staff
417	2686	item_glimmer_cape
418	2686	item_magic_wand
419	2686	item_tpscroll
420	2686	item_chainmail
421	2687	item_stout_shield
422	2687	item_boots
423	2687	item_ring_of_health
424	2687	item_magic_wand
425	2687	item_ward_observer
426	2687	item_tpscroll
427	2688	item_bottle
428	2688	item_wraith_band
429	2688	item_branches
430	2688	item_branches
431	2688	item_tango_single
432	2688	item_ward_sentry
433	2689	item_blight_stone
434	2689	item_boots
435	2689	item_stout_shield
436	2689	item_flask
437	2689	item_ring_of_aquila
438	2689	item_quelling_blade
439	2690	item_tpscroll
440	2690	item_ward_sentry
441	2690	item_clarity
442	2690	item_tango
443	2690	item_clarity
444	2690	item_tpscroll
445	2691	item_faerie_fire
446	2691	item_magic_wand
447	2691	item_tpscroll
448	2691	item_circlet
449	2691	item_branches
450	2691	item_tpscroll
451	2692	item_clarity
452	2692	item_tango
453	2692	item_clarity
454	2692	
455	2692	
456	2692	item_tpscroll
457	2693	item_quelling_blade
458	2693	item_tango
459	2693	item_stout_shield
460	2693	item_enchanted_mango
461	2693	
462	2693	item_tpscroll
463	2694	item_enchanted_mango
464	2694	item_tango
465	2694	item_tpscroll
466	2694	
467	2694	
468	2694	item_stout_shield
469	2695	item_null_talisman
470	2695	item_null_talisman
471	2695	item_magic_wand
472	2695	item_clarity
473	2695	item_flask
474	2695	item_magic_wand
475	2696	item_magic_wand
476	2696	item_tango
477	2696	item_clarity
478	2696	item_branches
479	2696	item_clarity
480	2696	item_tpscroll
481	2697	item_solar_crest
482	2697	item_cyclone
483	2697	item_glimmer_cape
484	2697	item_arcane_boots
485	2697	item_tpscroll
486	2697	item_magic_wand
487	2698	item_travel_boots
488	2698	item_bfury
489	2698	item_bloodthorn
490	2698	item_manta
491	2698	item_ultimate_scepter
492	2698	item_butterfly
493	2699	item_ultimate_scepter
494	2699	item_blink
495	2699	item_cyclone
496	2699	item_arcane_boots
497	2699	item_glimmer_cape
498	2699	item_bottle
499	2700	item_pipe
500	2700	item_blade_mail
501	2700	item_ring_of_aquila
502	2700	item_dragon_lance
503	2700	item_phase_boots
504	2700	item_aegis
505	2701	item_aether_lens
506	2701	item_magic_wand
507	2701	item_combo_breaker
508	2701	item_trident
509	2701	item_tranquil_boots
510	2701	item_pipe
511	2702	item_magic_wand
512	2702	item_hand_of_midas
513	2702	item_tranquil_boots
514	2702	item_tpscroll
515	2702	item_ward_dispenser
516	2702	item_ultimate_scepter
517	2703	item_blink
518	2703	item_ultimate_scepter
519	2703	item_skadi
520	2703	item_tpscroll
521	2703	item_sheepstick
522	2703	item_power_treads
523	2704	item_refresher
524	2704	item_ultimate_scepter
525	2704	item_tpscroll
526	2704	item_trident
527	2704	item_staff_of_wizardry
528	2704	item_boots
529	2705	item_vanguard
530	2705	item_heavens_halberd
531	2705	item_tpscroll
532	2705	item_magic_wand
533	2705	item_power_treads
534	2705	item_heart
535	2706	item_urn_of_shadows
536	2706	item_glimmer_cape
537	2706	item_dust
538	2706	item_blink
539	2706	item_tranquil_boots
540	2706	item_tpscroll
541	2707	item_hurricane_pike
542	2707	item_maelstrom
543	2707	item_ring_of_aquila
544	2707	item_sphere
545	2707	item_power_treads
546	2707	item_tpscroll
547	2708	item_travel_boots
548	2708	item_bfury
549	2708	item_assault
550	2708	item_manta
551	2708	item_butterfly
552	2708	item_sphere
553	2709	item_phase_boots
554	2709	item_urn_of_shadows
555	2709	item_ward_observer
556	2709	item_diffusal_blade
557	2709	item_gem
558	2709	item_blink
559	2710	item_ring_of_aquila
560	2710	item_solar_crest
561	2710	item_magic_wand
562	2710	item_ghost
563	2710	item_ultimate_scepter
564	2710	item_boots
565	2711	item_phase_boots
566	2711	item_blink
567	2711	item_invis_sword
568	2711	item_magic_wand
569	2711	item_hand_of_midas
570	2711	item_ultimate_scepter
571	2712	item_blade_mail
572	2712	item_guardian_greaves
573	2712	item_necronomicon_3
574	2712	item_stout_shield
575	2712	item_tpscroll
576	2712	item_circlet
577	2713	item_meteor_hammer
578	2713	item_spirit_vessel
579	2713	item_tpscroll
580	2713	item_power_treads
581	2713	item_dust
582	2713	item_stout_shield
583	2714	item_phase_boots
584	2714	item_black_king_bar
585	2714	item_abyssal_blade
586	2714	item_tpscroll
587	2714	item_vladmir
588	2714	item_desolator
589	2715	item_power_treads
590	2715	item_dragon_lance
591	2715	item_ring_of_basilius
592	2715	item_tpscroll
593	2715	item_maelstrom
594	2715	item_ward_observer
595	2716	item_magic_wand
596	2716	item_staff_of_wizardry
597	2716	item_tranquil_boots
598	2716	item_dust
599	2716	item_tpscroll
600	2716	item_blink
601	2717	item_tpscroll
602	2717	item_arcane_boots
603	2717	item_ultimate_scepter
604	2717	item_ward_observer
605	2717	item_smoke_of_deceit
606	2717	item_ogre_axe
607	2718	item_bottle
608	2718	item_boots
609	2718	item_bloodstone
610	2718	item_ultimate_orb
611	2718	item_orchid
612	2718	item_black_king_bar
613	2719	item_blink
614	2719	item_invis_sword
615	2719	item_shivas_guard
616	2719	item_hand_of_midas
617	2719	item_power_treads
618	2719	item_ultimate_scepter
619	2720	item_guardian_greaves
620	2720	item_blade_mail
621	2720	item_pipe
622	2720	item_magic_wand
623	2720	item_assault
624	2720	item_gem
625	2721	item_mask_of_madness
626	2721	item_invis_sword
627	2721	item_phase_boots
628	2721	item_diffusal_blade
629	2721	item_black_king_bar
630	2721	item_magic_wand
631	2722	item_blink
632	2722	item_arcane_boots
633	2722	item_veil_of_discord
634	2722	item_trident
635	2722	item_tpscroll
636	2722	item_gem
637	2723	item_phase_boots
638	2723	item_abyssal_blade
639	2723	item_pipe
640	2723	item_radiance
641	2723	item_armlet
642	2723	item_mask_of_madness
643	2724	item_glimmer_cape
644	2724	item_magic_wand
645	2724	item_travel_boots
646	2724	item_mekansm
647	2724	item_tranquil_boots
648	2724	item_ward_sentry
649	2725	item_phase_boots
650	2725	item_cyclone
651	2725	item_octarine_core
652	2725	item_shivas_guard
653	2725	item_refresher
654	2725	item_black_king_bar
655	2726	item_abyssal_blade
656	2726	item_black_king_bar
657	2726	item_phase_boots
658	2726	item_hyperstone
659	2726	item_desolator
660	2726	item_platemail
661	2727	item_hurricane_pike
662	2727	item_cyclone
663	2727	item_diffusal_blade
664	2727	item_hand_of_midas
665	2727	item_tpscroll
666	2727	item_power_treads
667	2728	item_power_treads
668	2728	item_vanguard
669	2728	item_radiance
670	2728	item_tpscroll
671	2728	item_diffusal_blade
672	2728	item_manta
673	2729	item_blink
674	2729	item_dust
675	2729	item_ultimate_scepter
676	2729	item_vanguard
677	2729	item_blade_mail
678	2729	item_tranquil_boots
679	2730	item_veil_of_discord
680	2730	item_bottle
681	2730	item_ultimate_scepter
682	2730	item_aether_lens
683	2730	item_trident
684	2730	item_travel_boots
685	2731	item_tranquil_boots
686	2731	item_tango
687	2731	item_ultimate_scepter
688	2731	item_void_stone
689	2731	item_tpscroll
690	2731	item_ward_observer
691	2732	item_force_staff
692	2732	item_pipe
693	2732	item_arcane_boots
694	2732	item_magic_wand
695	2732	item_tpscroll
696	2732	item_headdress
697	2733	item_hood_of_defiance
698	2733	item_silver_edge
699	2733	item_maelstrom
700	2733	item_dragon_lance
701	2733	item_black_king_bar
702	2733	item_power_treads
703	2734	item_desolator
704	2734	item_phase_boots
705	2734	item_tpscroll
706	2734	item_armlet
707	2734	item_abyssal_blade
708	2734	item_basher
709	2735	item_phase_boots
710	2735	item_ultimate_scepter
711	2735	item_magic_wand
712	2735	item_urn_of_shadows
713	2735	item_black_king_bar
714	2735	item_tpscroll
715	2736	item_ward_observer
716	2736	item_glimmer_cape
717	2736	item_force_staff
718	2736	item_magic_wand
719	2736	item_travel_boots
720	2736	item_tpscroll
721	2737	item_bfury
722	2737	item_power_treads
723	2737	item_tpscroll
724	2737	item_manta
725	2737	item_abyssal_blade
726	2737	item_vladmir
727	2738	item_travel_boots
728	2738	item_gem
729	2738	item_silver_edge
730	2738	item_rapier
731	2738	item_desolator
732	2738	item_blink
733	2739	item_phase_boots
734	2739	item_blink
735	2739	item_magic_wand
736	2739	item_gem
737	2739	item_sphere
738	2739	item_rapier
739	2740	item_veil_of_discord
740	2740	item_boots
741	2740	item_ultimate_scepter
742	2740	item_aether_lens
743	2740	item_cyclone
744	2740	item_tome_of_knowledge
745	2741	item_power_treads
746	2741	item_solar_crest
747	2741	item_ward_observer
748	2741	item_ring_of_aquila
749	2741	item_cyclone
750	2741	item_tpscroll
751	2742	item_veil_of_discord
752	2742	item_ultimate_scepter
753	2742	item_ultimate_scepter
754	2742	item_solar_crest
755	2742	item_tranquil_boots
756	2742	item_magic_wand
757	2743	item_power_treads
758	2743	item_ultimate_scepter
759	2743	item_radiance
760	2743	item_tpscroll
761	2743	item_force_staff
762	2743	item_abyssal_blade
763	2744	item_rapier
764	2744	item_blink
765	2744	item_armlet
766	2744	item_travel_boots
767	2744	item_greater_crit
768	2744	item_assault
769	2745	item_stout_shield
770	2745	item_ward_dispenser
771	2745	item_force_staff
772	2745	item_blink
773	2745	item_guardian_greaves
774	2745	item_magic_wand
775	2746	item_guardian_greaves
776	2746	item_shivas_guard
777	2746	item_pipe
778	2746	item_necronomicon_3
779	2746	item_magic_wand
780	2746	item_tpscroll
781	2747	item_wind_lace
782	2747	item_phase_boots
783	2747	item_vanguard
784	2747	item_infused_raindrop
785	2747	item_dust
786	2747	item_vitality_booster
787	2748	item_bottle
788	2748	item_phase_boots
789	2748	item_ultimate_scepter
790	2748	item_magic_wand
791	2748	item_blade_mail
792	2748	item_tpscroll
793	2749	item_power_treads
794	2749	item_bfury
795	2749	item_manta
796	2749	item_butterfly
797	2749	item_ultimate_scepter
798	2749	item_basher
799	2750	item_ring_of_aquila
800	2750	item_power_treads
801	2750	item_mjollnir
802	2750	item_bottle
803	2750	item_dragon_lance
804	2750	item_tpscroll
805	2751	item_cyclone
806	2751	item_magic_wand
807	2751	item_ward_observer
808	2751	item_boots
809	2751	item_smoke_of_deceit
810	2751	item_tpscroll
811	2752	item_force_staff
812	2752	item_bottle
813	2752	item_trident
814	2752	item_ghost
815	2752	item_arcane_boots
816	2752	item_magic_wand
817	2753	item_power_treads
818	2753	item_vladmir
819	2753	item_stout_shield
820	2753	item_tpscroll
821	2753	item_manta
822	2753	item_diffusal_blade
823	2754	item_staff_of_wizardry
824	2754	item_invis_sword
825	2754	item_hand_of_midas
826	2754	item_boots
827	2754	item_tpscroll
828	2754	item_ultimate_scepter
829	2755	item_tranquil_boots
830	2755	item_blink
831	2755	item_tpscroll
832	2755	item_tango
833	2755	item_ward_sentry
834	2755	item_ward_sentry
835	2756	item_tranquil_boots
836	2756	item_tango
837	2756	item_dust
838	2756	item_glimmer_cape
839	2756	item_wind_lace
840	2756	
841	2757	item_sange_and_yasha
842	2757	item_blink
843	2757	item_lesser_crit
844	2757	item_mask_of_madness
845	2757	item_power_treads
846	2757	item_quelling_blade
847	2758	item_aegis
848	2758	item_mask_of_madness
849	2758	item_hurricane_pike
850	2758	item_invis_sword
851	2758	item_magic_wand
852	2758	item_power_treads
853	2759	item_phase_boots
854	2759	item_diffusal_blade
855	2759	item_invis_sword
856	2759	item_gem
857	2759	item_sphere
858	2759	item_orb_of_venom
859	2760	item_point_booster
860	2760	item_ward_observer
861	2760	item_bracer
862	2760	item_infused_raindrop
863	2760	item_arcane_boots
864	2760	item_magic_wand
865	2761	item_force_staff
866	2761	item_magic_wand
867	2761	item_glimmer_cape
868	2761	item_urn_of_shadows
869	2761	item_tpscroll
870	2761	item_arcane_boots
871	2762	item_blink
872	2762	item_arcane_boots
873	2762	item_ward_dispenser
874	2762	item_tpscroll
875	2762	item_dust
876	2762	item_tpscroll
877	2763	item_invis_sword
878	2763	item_stout_shield
879	2763	item_maelstrom
880	2763	item_dust
881	2763	item_power_treads
882	2763	item_tpscroll
883	2764	item_magic_wand
884	2764	item_armlet
885	2764	item_power_treads
886	2764	item_quelling_blade
887	2764	item_mithril_hammer
888	2764	item_radiance
889	2765	item_hand_of_midas
890	2765	item_staff_of_wizardry
891	2765	item_point_booster
892	2765	item_tpscroll
893	2765	item_boots
894	2765	item_ogre_axe
895	2766	item_dust
896	2766	item_ring_of_basilius
897	2766	item_tpscroll
898	2766	item_bracer
899	2766	item_vanguard
900	2766	item_arcane_boots
\.


--
-- Name: player_match_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.player_match_item_id_seq', 900, true);


--
-- Data for Name: player_match_rating; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.player_match_rating (id, rated_by_steam_id, rating, player_match_stats_id) FROM stdin;
1	76561198050981415	5	4
2	76561198049220301	4	3
4	76561198049220301	5	1
5	76561198049220301	3	2
6	76561198049220301	3	4
7	76561198049220301	4	6
8	76561198049220301	4	7
9	76561198049220301	3	8
10	76561198049220301	3	9
11	76561198049220301	5	10
12	76561198050981415	4	3
13	76561198050981415	4	2
14	76561198050981415	4	5
15	76561198050981415	5	15
16	76561198050981415	3	17
17	76561198050981415	3	16
18	76561198050981415	3	12
19	76561198050981415	3	11
21	76561198050981415	4	20
22	76561198050981415	5	14
23	76561198006183979	4	13
24	76561198006183979	4	12
25	76561198006183979	4	11
26	76561198006183979	5	15
27	76561198006183979	4	18
28	76561198006183979	4	19
29	76561198049220301	1	21
30	76561198049220301	1	25
31	76561198049220301	2	22
32	76561198050981415	5	34
33	76561198049220301	5	34
34	76561198049220301	5	35
35	76561198049220301	5	33
36	76561198049220301	5	31
37	76561198049220301	3	36
38	76561198049220301	4	37
39	76561198049220301	4	38
40	76561198049220301	2	39
41	76561198049220301	2	40
42	76561198050981415	5	47
43	76561198050981415	5	50
44	76561198049220301	5	41
45	76561198049220301	5	42
46	76561198049220301	5	43
47	76561198049220301	5	45
48	76561198049220301	5	46
49	76561198049220301	4	47
50	76561198049220301	3	49
51	76561198049220301	2	48
52	76561198046244483	1	46
53	76561198046244483	4	42
54	76561198046244483	4	43
55	76561198046244483	4	44
56	76561198046244483	4	45
57	76561198046244483	1	49
58	76561198046244483	1	47
59	76561198046244483	3	50
60	76561198013030157	5	41
61	76561198050981415	1	48
62	76561198050981415	2	49
63	76561198013030157	1	46
64	76561198013030157	1	48
65	76561198013030157	1	47
66	76561198050981415	1	40
67	76561198050981415	3	41
69	76561198050981415	5	44
70	76561198050981415	1	22
71	76561198050981415	2	24
72	76561198050981415	1	25
73	76561198046244483	1	31
75	76561198046244483	3	33
77	76561198046244483	2	38
78	76561198046244483	3	35
80	76561198046244483	1	48
81	76561198029784649	5	41
82	76561198029784649	5	43
83	76561198029784649	5	42
84	76561198029784649	4	44
85	76561198029784649	5	46
86	76561198029784649	4	47
87	76561198029784649	3	49
88	76561198029784649	4	50
89	76561198062081877	1	41
90	76561198062081877	1	42
91	76561198062081877	1	43
92	76561198062081877	5	44
93	76561198062081877	3	45
94	76561198062081877	1	48
96	76561198062081877	2	49
97	76561198062081877	5	50
98	76561198049220301	1	59
99	76561198049220301	1	58
100	76561198049220301	1	60
101	76561198049220301	1	61
102	76561198049220301	4	62
103	76561198049220301	1	63
104	76561198049220301	5	64
105	76561198049220301	5	65
106	76561198049220301	4	66
107	76561198050981415	1	58
108	76561198050981415	1	60
109	76561198006183979	5	62
110	76561198006183979	5	63
111	76561198047012382	5	71
112	76561198047012382	2	69
113	76561198047012382	4	67
114	76561198047012382	3	68
115	76561198047012382	2	70
116	76561198047012382	3	72
117	76561198047012382	2	73
118	76561198047012382	3	75
119	76561198047012382	2	76
120	76561198050981415	5	77
121	76561198050981415	5	79
122	76561198050981415	5	80
123	76561198050981415	5	81
124	76561198050981415	5	83
125	76561198049220301	1	79
128	76561198047012382	1	83
129	76561198047012382	5	77
130	76561198047012382	5	78
131	76561198047012382	5	80
132	76561198047012382	5	81
133	76561198049220301	4	78
134	76561198047012382	1	84
135	76561198049220301	5	77
136	76561198047012382	2	85
137	76561198047012382	2	86
139	76561198047012382	3	82
140	76561198049220301	4	86
141	76561198049220301	4	85
142	76561198049220301	3	84
143	76561198049220301	5	80
144	76561198049220301	5	81
145	76561198049220301	4	87
146	76561198049220301	2	89
147	76561198050981415	2	89
148	76561198049220301	5	90
149	76561198050981415	5	90
150	76561198049220301	3	91
151	76561198050981415	4	95
152	76561198049220301	5	92
153	76561198049220301	5	95
154	76561198049220301	4	94
155	76561198049220301	5	96
156	76561198049220301	5	93
157	76561198047012382	4	87
158	76561198047012382	2	88
170	76561198036168458	5	74
172	76561198036168458	2	67
159	76561198047012382	3	89
160	76561198047012382	2	91
161	76561198047012382	4	92
162	76561198047012382	3	93
163	76561198047012382	4	94
164	76561198047012382	4	95
165	76561198047012382	5	96
166	76561198036168458	5	79
167	76561198036168458	4	78
168	76561198036168458	5	77
169	76561198036168458	5	80
171	76561198036168458	5	71
173	76561198036168458	1	69
174	76561198047012382	1	106
175	76561198049220301	1	99
176	76561198047012382	2	105
178	76561198047012382	1	104
179	76561198047012382	2	103
180	76561198049220301	5	98
181	76561198047012382	3	102
182	76561198049220301	5	102
183	76561198047012382	4	101
184	76561198047012382	4	100
185	76561198049220301	5	97
186	76561198047012382	5	98
187	76561198049220301	5	100
188	76561198047012382	4	97
189	76561198049220301	5	101
190	76561198049220301	2	103
191	76561198049220301	2	104
192	76561198049220301	5	105
193	76561198029784649	5	98
194	76561198029784649	5	99
195	76561198029784649	5	100
196	76561198029784649	5	101
197	76561198029784649	4	102
198	76561198029784649	4	103
199	76561198029784649	2	104
200	76561198050981415	1	106
201	76561198029784649	3	105
202	76561198050981415	3	104
203	76561198050981415	2	103
204	76561198050981415	5	101
205	76561198047012382	4	116
206	76561198047012382	2	115
207	76561198047012382	3	114
208	76561198047012382	1	113
209	76561198047012382	3	112
210	76561198047012382	4	111
211	76561198047012382	4	109
212	76561198047012382	3	108
213	76561198047012382	3	107
215	76561198155142404	1	57
216	76561198155142404	1	58
217	76561198155142404	1	59
218	76561198049220301	4	117
219	76561198049220301	4	119
220	76561198049220301	1	120
221	76561198049220301	3	121
222	76561198049220301	5	122
223	76561198049220301	5	123
224	76561198049220301	5	124
225	76561198049220301	5	125
226	76561198049220301	1	126
227	76561198047012382	1	118
229	76561198047012382	5	117
230	76561198047012382	5	119
231	76561198047012382	5	120
232	76561198047012382	5	121
233	76561198047012382	5	122
234	76561198047012382	5	123
235	76561198047012382	5	124
236	76561198047012382	5	125
256	76561198049220301	2	128
257	76561198049220301	3	129
258	76561198049220301	2	130
259	76561198049220301	2	131
260	76561198047012382	3	127
262	76561198047012382	3	128
263	76561198047012382	2	129
264	76561198049220301	1	136
265	76561198047012382	2	130
266	76561198047012382	2	131
267	76561198047012382	3	132
268	76561198047012382	2	133
269	76561198047012382	2	134
270	76561198047012382	4	135
271	76561198050981415	1	131
272	76561198050981415	1	128
273	76561198050981415	5	143
274	76561198050981415	5	145
275	76561198050981415	5	144
276	76561198050981415	5	146
277	76561198049220301	2	143
278	76561198049220301	4	144
279	76561198049220301	3	145
280	76561198049220301	4	146
281	76561198049220301	5	142
282	76561198049220301	5	138
283	76561198049220301	5	139
284	76561198049220301	5	140
285	76561198049220301	5	141
286	76561198049523020	5	136
287	76561198049523020	5	130
288	76561198049523020	3	129
289	76561198049523020	3	128
290	76561198049523020	4	127
291	76561198049523020	4	132
292	76561198049523020	3	133
293	76561198049523020	4	134
294	76561198049523020	5	135
295	76561198049523020	5	137
297	76561198050981415	5	68
298	76561198050981415	5	67
299	76561198050981415	4	70
300	76561198050981415	1	69
301	76561198050981415	5	74
302	76561198050981415	1	153
303	76561198050981415	1	154
304	76561198050981415	5	155
305	76561198049220301	4	148
306	76561198049220301	4	149
307	76561198049220301	5	150
308	76561198049220301	5	151
309	76561198049220301	3	152
310	76561198049220301	5	153
311	76561198049220301	3	154
312	76561198049220301	1	155
313	76561198049220301	4	156
314	76561198047012382	3	156
315	76561198047012382	2	154
316	76561198047012382	3	153
317	76561198047012382	3	152
318	76561198050981415	1	147
319	76561198047012382	4	151
321	76561198047012382	4	150
322	76561198047012382	3	149
323	76561198047012382	3	148
324	76561198047012382	3	147
325	76561198049220301	5	157
326	76561198049220301	5	159
327	76561198049220301	5	160
328	76561198049220301	5	161
329	76561198049220301	3	162
330	76561198049220301	3	163
331	76561198049220301	3	164
332	76561198049220301	5	165
333	76561198049220301	3	166
334	76561198050981415	1	163
335	76561198029784649	5	158
336	76561198029784649	5	159
337	76561198029784649	5	160
338	76561198029784649	5	161
339	76561198029784649	3	162
340	76561198029784649	4	163
341	76561198029784649	3	164
342	76561198029784649	4	166
343	76561198049220301	5	167
345	76561198049220301	3	172
346	76561198049220301	4	175
347	76561198049220301	4	176
348	76561198049220301	3	174
350	76561198050981415	5	183
351	76561198050981415	3	182
352	76561198049220301	4	178
355	76561198049220301	5	180
359	76561198049220301	3	182
368	76561198155142404	5	187
372	76561198155142404	4	189
374	76561198155142404	4	192
378	76561198049220301	3	195
388	76561198050981415	5	205
398	76561198036168458	5	151
400	76561198036168458	2	153
401	76561198036168458	4	155
349	76561198050981415	2	186
353	76561198049220301	5	179
354	76561198049220301	5	181
358	76561198049220301	2	184
360	76561198049220301	3	183
363	76561198029784649	5	177
381	76561198155142404	3	195
382	76561198155142404	1	194
384	76561198049220301	5	190
389	76561198050981415	1	211
394	76561198049220301	1	208
395	76561198049220301	1	211
397	76561198036168458	2	147
399	76561198036168458	5	150
403	76561198036168458	3	165
404	76561198036168458	4	159
408	76561198050981415	1	228
356	76561198049220301	5	186
361	76561198155142404	1	162
370	76561198155142404	3	188
373	76561198155142404	2	190
375	76561198049220301	4	192
377	76561198049220301	4	194
383	76561198155142404	4	193
386	76561198049220301	5	187
390	76561198050981415	2	207
392	76561198050981415	2	209
402	76561198036168458	1	163
405	76561198036168458	4	166
357	76561198049220301	5	185
362	76561198047822188	1	177
365	76561198029784649	4	178
366	76561198029784649	5	179
367	76561198029784649	5	180
376	76561198049220301	4	196
379	76561198049220301	1	191
380	76561198155142404	4	196
385	76561198049220301	5	189
387	76561198049220301	5	188
393	76561198049220301	1	207
396	76561198049220301	3	210
406	76561198050981415	5	235
407	76561198050981415	5	234
410	76561198047012382	5	249
412	76561198047012382	5	247
413	76561198047012382	5	248
415	76561198047012382	3	250
416	76561198047012382	4	251
417	76561198047012382	3	252
418	76561198047012382	2	253
419	76561198047012382	1	254
420	76561198047012382	2	256
421	76561198047012382	3	237
422	76561198047012382	2	238
423	76561198047012382	4	239
424	76561198047012382	3	241
425	76561198047012382	3	242
426	76561198047012382	5	243
427	76561198047012382	1	244
428	76561198047012382	3	245
429	76561198047012382	3	246
430	76561198047012382	5	233
431	76561198047012382	5	235
432	76561198047012382	1	228
433	76561198074711025	5	247
434	76561198074711025	3	250
435	76561198074711025	5	249
436	76561198074711025	5	248
437	76561198049220301	5	259
438	76561198049220301	5	257
439	76561198049220301	5	258
440	76561198049220301	5	269
441	76561198049220301	5	261
442	76561198049220301	5	270
443	76561198049220301	5	271
444	76561198049220301	5	267
445	76561198049220301	1	272
446	76561198049220301	5	278
447	76561198049220301	5	279
448	76561198049220301	5	280
449	76561198049220301	5	281
450	76561198049220301	1	282
451	76561198050981415	5	277
452	76561198050981415	5	279
453	76561198050981415	5	281
454	76561198050981415	5	268
455	76561198050981415	1	272
456	76561198050981415	5	276
457	76561198050981415	2	282
458	76561198050981415	1	284
459	76561198036168458	1	263
460	76561198036168458	5	265
461	76561198036168458	2	264
462	76561198036168458	4	260
463	76561198036168458	4	261
464	76561198036168458	5	259
465	76561198036168458	4	266
466	76561198036168458	3	258
467	76561198036168458	3	257
469	76561198046244483	1	292
470	76561198046244483	2	296
471	76561198046244483	3	294
472	76561198046244483	4	293
473	76561198049220301	2	299
474	76561198049220301	2	300
475	76561198049220301	4	301
476	76561198049220301	3	298
477	76561198049220301	5	303
478	76561198047822188	5	302
479	76561198047822188	5	304
480	76561198047822188	5	305
481	76561198049220301	2	315
482	76561198049220301	4	316
483	76561198049220301	3	314
484	76561198049220301	4	312
487	76561198047822188	5	316
488	76561198047822188	5	308
489	76561198029784649	3	307
490	76561198029784649	5	308
491	76561198029784649	5	313
492	76561198049220301	1	307
494	76561198049220301	5	308
496	76561198050981415	5	311
497	76561198050981415	5	317
498	76561198050981415	5	318
500	76561198050981415	5	319
501	76561198050981415	5	320
502	76561198049220301	5	321
503	76561198049220301	5	320
504	76561198049220301	5	318
505	76561198049220301	5	317
507	76561198047822188	5	327
508	76561198047822188	5	328
509	76561198047822188	5	330
510	76561198047822188	5	331
511	76561198049220301	5	329
512	76561198049220301	5	330
513	76561198049220301	5	331
514	76561198049220301	5	328
515	76561198046244483	3	287
516	76561198046244483	3	288
517	76561198046244483	3	289
518	76561198046244483	3	290
519	76561198046244483	3	291
520	76561198050981415	5	345
521	76561198050981415	5	346
522	76561198050981415	5	343
523	76561198050981415	5	342
524	76561198047012382	5	338
526	76561198047012382	5	344
527	76561198013030157	1	341
528	76561198050981415	1	301
529	76561198029784649	5	357
530	76561198029784649	5	359
531	76561198029784649	5	358
532	76561198029784649	5	360
533	76561198029784649	4	362
534	76561198029784649	4	363
535	76561198029784649	3	364
536	76561198029784649	3	365
537	76561198029784649	3	366
538	76561198050981415	1	363
539	76561198050981415	1	364
540	76561198050981415	1	365
541	76561198050981415	1	366
542	76561198049220301	4	362
543	76561198049220301	1	364
544	76561198049220301	4	365
545	76561198049220301	4	366
546	76561198049220301	5	361
547	76561198049220301	5	360
548	76561198049220301	5	358
549	76561198049220301	5	357
550	76561198050981415	5	360
551	76561198050981415	1	370
552	76561198050981415	2	369
553	76561198050981415	2	368
554	76561198050981415	5	376
555	76561198049220301	3	367
556	76561198050981415	2	381
557	76561198050981415	2	378
558	76561198050981415	4	377
560	76561198050981415	4	385
561	76561198050981415	5	386
562	76561198049220301	5	385
563	76561198049220301	5	386
564	76561198049220301	5	383
567	76561198049220301	1	377
569	76561198050981415	5	391
571	76561198049220301	1	393
572	76561198049220301	1	392
574	76561198074711025	1	395
575	76561198050981415	1	405
580	76561198049220301	5	399
581	76561198049220301	5	401
582	76561198074711025	1	405
589	76561198155142404	5	399
591	76561198155142404	5	401
600	76561198155142404	2	406
603	76561198074711025	5	397
606	76561198074711025	5	400
607	76561198074711025	4	402
609	76561198155142404	5	389
610	76561198155142404	4	390
565	76561198049220301	4	382
566	76561198049220301	2	379
570	76561198049220301	1	395
573	76561198049220301	4	396
579	76561198049220301	5	398
583	76561198049220301	5	400
584	76561198029784649	5	397
585	76561198155142404	5	397
586	76561198029784649	5	398
587	76561198029784649	5	399
593	76561198155142404	2	402
595	76561198029784649	5	404
596	76561198155142404	2	403
598	76561198155142404	3	404
604	76561198074711025	5	398
605	76561198074711025	5	399
613	76561198074711025	4	404
568	76561198049220301	1	378
590	76561198155142404	5	400
592	76561198029784649	1	405
594	76561198049220301	3	404
597	76561198049220301	1	405
599	76561198155142404	1	405
601	76561198050981415	1	398
611	76561198155142404	2	387
612	76561198155142404	1	394
614	76561198050981415	1	403
616	76561198050981415	5	402
617	76561198050981415	5	358
619	76561198155142404	1	380
620	76561198050981415	5	414
621	76561198050981415	5	415
622	76561198050981415	5	416
623	76561198050981415	5	413
624	76561198013030157	5	412
625	76561198047012382	5	412
626	76561198047012382	5	413
627	76561198047012382	5	414
628	76561198047012382	5	416
629	76561198036168458	1	363
630	76561198036168458	4	362
631	76561198036168458	5	357
632	76561198050981415	5	424
633	76561198050981415	5	425
634	76561198050981415	5	426
635	76561198050981415	5	422
636	76561198050981415	4	429
637	76561198050981415	5	431
638	76561198050981415	4	430
639	76561198050981415	5	433
640	76561198049220301	5	432
641	76561198049220301	5	436
642	76561198049220301	5	431
643	76561198049220301	5	427
644	76561198050981415	1	445
645	76561198050981415	5	438
647	76561198049220301	1	445
648	76561198049220301	5	437
649	76561198049220301	5	438
650	76561198049220301	2	444
651	76561198074711025	5	439
652	76561198074711025	5	441
653	76561198074711025	5	440
654	76561198050981415	1	448
655	76561198049220301	5	447
656	76561198074711025	5	456
657	76561198074711025	5	454
658	76561198074711025	5	453
659	76561198074711025	5	452
661	76561198050981415	5	457
662	76561198050981415	4	459
665	76561198050981415	5	474
666	76561198050981415	5	473
667	76561198050981415	5	472
668	76561198050981415	5	476
669	76561198155142404	5	455
670	76561198155142404	5	454
671	76561198155142404	5	452
672	76561198155142404	5	456
673	76561198155142404	5	447
674	76561198155142404	2	448
675	76561198155142404	1	449
676	76561198155142404	3	451
677	76561198050981415	1	450
678	76561198047012382	3	492
679	76561198047012382	3	493
680	76561198047012382	5	494
681	76561198047012382	5	495
682	76561198047012382	4	496
683	76561198047012382	4	491
684	76561198047012382	1	490
685	76561198047012382	2	489
686	76561198047012382	3	488
687	76561198049523020	5	492
688	76561198049523020	5	495
689	76561198049523020	5	496
690	76561198049523020	5	494
691	76561198049523020	5	487
693	76561198049523020	5	489
694	76561198049523020	5	491
695	76561198050981415	2	498
696	76561198050981415	2	497
697	76561198050981415	5	506
698	76561198050981415	4	505
699	76561198047012382	5	502
700	76561198047012382	3	503
701	76561198047012382	4	505
702	76561198047012382	3	500
703	76561198047012382	3	501
704	76561198047012382	2	499
705	76561198047012382	1	498
706	76561198047012382	3	497
707	76561198074711025	5	515
708	76561198074711025	5	516
709	76561198074711025	5	514
710	76561198074711025	4	513
711	76561198155142404	1	510
712	76561198155142404	1	511
713	76561198155142404	1	512
714	76561198155142404	1	513
715	76561198155142404	1	514
716	76561198155142404	1	515
717	76561198155142404	1	516
718	76561198155142404	1	509
719	76561198155142404	1	507
720	76561198049220301	5	524
721	76561198049220301	5	523
722	76561198049220301	5	525
723	76561198049220301	5	526
724	76561198049220301	4	520
725	76561198074711025	1	517
726	76561198049523020	5	488
728	76561198049523020	5	490
729	76561198049220301	5	532
730	76561198049220301	5	535
731	76561198049220301	5	536
732	76561198049220301	4	527
733	76561198049220301	5	533
734	76561198050981415	5	545
735	76561198050981415	5	544
736	76561198050981415	5	543
737	76561198050981415	5	542
738	76561198050981415	5	555
739	76561198050981415	4	556
740	76561198050981415	5	553
741	76561198155142404	4	557
742	76561198155142404	5	559
743	76561198155142404	5	560
744	76561198155142404	5	561
745	76561198155142404	1	562
746	76561198155142404	3	563
747	76561198155142404	1	564
748	76561198155142404	1	565
749	76561198155142404	5	566
750	76561198125222713	5	561
751	76561198006183979	5	566
752	76561198125222713	5	559
753	76561198125222713	5	558
754	76561198125222713	5	557
755	76561198125222713	4	562
756	76561198125222713	4	563
757	76561198006183979	4	564
758	76561198125222713	2	566
759	76561198006183979	2	563
760	76561198125222713	2	565
761	76561198125222713	3	564
768	76561198155142404	5	551
771	76561198050981415	1	566
772	76561197981436383	5	548
776	76561198029784649	5	546
777	76561198029784649	5	544
778	76561198029784649	5	558
786	76561198029784649	5	573
789	76561198029784649	5	575
790	76561198074711025	5	576
794	76561198006183979	1	571
799	76561198006183979	1	469
809	76561198155142404	2	569
810	76561198155142404	4	568
762	76561198155142404	1	552
764	76561198155142404	1	554
779	76561198029784649	5	557
780	76561198029784649	5	559
782	76561198029784649	5	562
793	76561198074711025	4	567
795	76561198074711025	1	571
800	76561198006183979	1	475
803	76561198155142404	5	573
763	76561198006183979	1	562
766	76561198155142404	2	549
767	76561198155142404	1	547
770	76561197981436383	5	562
773	76561198050981415	1	565
781	76561198029784649	5	560
783	76561198029784649	5	572
785	76561198029784649	5	574
788	76561198074711025	5	574
791	76561198074711025	4	568
796	76561198074711025	3	569
801	76561198006183979	1	527
802	76561198006183979	1	520
807	76561198155142404	1	571
808	76561198155142404	1	570
765	76561198155142404	5	550
769	76561198155142404	1	546
774	76561198050981415	2	563
775	76561198050981415	5	557
784	76561198074711025	5	572
787	76561198074711025	5	573
792	76561198006183979	1	575
797	76561198006183979	1	569
798	76561198006183979	1	570
804	76561198155142404	5	572
805	76561198155142404	4	575
806	76561198155142404	5	576
811	76561198155142404	5	567
813	76561198125222713	1	516
814	76561198125222713	1	515
815	76561198125222713	1	514
816	76561198125222713	1	513
817	76561198125222713	1	512
818	76561198125222713	1	511
819	76561198125222713	1	509
820	76561198125222713	1	507
822	76561198074711025	5	585
823	76561198074711025	4	583
824	76561198074711025	5	584
826	76561198074711025	5	582
827	76561198047012382	5	581
828	76561198047012382	2	577
829	76561198047012382	3	578
831	76561198047012382	4	579
832	76561198047012382	3	580
834	76561198047012382	5	582
835	76561198047012382	3	583
836	76561198047012382	5	584
837	76561198047012382	5	586
838	76561198050981415	5	585
839	76561198050981415	5	586
840	76561198050981415	5	590
841	76561198050981415	5	589
842	76561198050981415	5	588
843	76561198050981415	5	587
845	76561198049220301	4	597
846	76561198050981415	5	605
848	76561198049220301	5	599
849	76561198049220301	5	600
850	76561198049220301	5	598
851	76561198049220301	5	604
852	76561197981436383	1	602
853	76561197981436383	1	603
854	76561197981436383	1	605
855	76561197981436383	1	606
856	76561197981436383	5	598
857	76561197981436383	3	599
858	76561197981436383	3	600
859	76561197981436383	2	601
860	76561197981436383	4	597
861	76561198155142404	1	613
862	76561198155142404	5	614
863	76561198155142404	5	615
864	76561198155142404	5	616
865	76561198049220301	5	613
866	76561198049220301	5	612
867	76561198049220301	5	615
868	76561198049220301	5	616
869	76561198155142404	5	611
870	76561198155142404	5	610
871	76561198155142404	5	609
872	76561198155142404	1	608
873	76561198155142404	1	607
874	76561198050981415	5	614
875	76561198050981415	5	615
876	76561198049220301	5	609
877	76561198029784649	5	612
878	76561198029784649	1	609
879	76561197981436383	1	610
880	76561197981436383	1	607
881	76561197981436383	1	608
882	76561197981436383	1	611
883	76561197981436383	2	613
884	76561197981436383	5	612
885	76561197981436383	4	614
886	76561197981436383	3	615
887	76561197981436383	5	616
888	76561198050981415	1	617
889	76561198049220301	5	622
890	76561198049220301	5	624
891	76561198049220301	5	626
892	76561198049220301	5	623
893	76561198049220301	5	617
894	76561198074711025	5	625
895	76561198074711025	5	626
896	76561198074711025	5	624
897	76561198049220301	4	618
898	76561198074711025	5	623
902	76561198155142404	5	628
903	76561198155142404	5	629
904	76561198155142404	4	630
905	76561198155142404	5	631
906	76561198155142404	5	632
907	76561198155142404	4	633
908	76561198050981415	5	634
909	76561198155142404	1	634
910	76561198155142404	5	635
911	76561198155142404	1	636
912	76561198050981415	5	636
914	76561198125222713	1	634
915	76561198049220301	3	632
916	76561198049220301	5	628
917	76561198049220301	5	635
918	76561198049220301	3	636
919	76561197981436383	1	633
920	76561197981436383	4	636
921	76561197981436383	4	634
922	76561198155142404	5	637
923	76561198155142404	5	639
924	76561198155142404	5	641
925	76561198155142404	5	640
926	76561198155142404	5	642
927	76561198155142404	1	643
928	76561198155142404	2	644
929	76561198155142404	4	645
930	76561198155142404	1	646
931	76561198049220301	5	637
932	76561198049220301	5	638
933	76561198049220301	5	639
934	76561198049220301	5	641
935	76561198006183979	1	643
936	76561198074711025	5	638
937	76561198074711025	5	639
938	76561198074711025	5	640
939	76561198074711025	5	641
940	76561198074711025	5	642
941	76561198074711025	3	644
942	76561198074711025	4	645
943	76561198074711025	1	646
944	76561198074711025	1	643
945	76561198006183979	1	517
946	76561198049220301	4	643
947	76561198050981415	5	640
948	76561198050981415	5	641
949	76561198050981415	5	638
950	76561198050981415	5	637
951	76561198050981415	5	651
952	76561198050981415	5	648
953	76561198050981415	5	647
954	76561198050981415	5	660
955	76561198050981415	5	659
956	76561198050981415	5	658
959	76561198050981415	1	686
962	76561198074711025	5	677
963	76561198074711025	5	678
964	76561198074711025	5	679
973	76561198050981415	5	698
974	76561198050981415	5	697
975	76561198050981415	5	701
983	76561198155142404	3	706
987	76561198047012382	5	705
995	76561198049220301	5	705
1001	76561198125222713	5	725
1002	76561198125222713	5	724
1007	76561198125222713	3	719
1008	76561198125222713	2	720
1010	76561198125222713	3	721
1014	76561198050981415	5	738
1015	76561198050981415	4	741
1017	76561198047012382	2	742
1018	76561198047012382	2	744
1019	76561198047012382	3	746
1020	76561198036168458	1	744
1027	76561198036168458	4	739
1028	76561198036168458	4	740
1029	76561198036168458	4	741
1030	76561198155142404	2	766
1033	76561198155142404	5	763
1037	76561198155142404	5	757
958	76561198050981415	5	657
965	76561198074711025	5	680
966	76561198050981415	1	684
968	76561198050981415	1	690
969	76561198050981415	1	688
970	76561198050981415	5	689
972	76561198050981415	5	700
976	76561198155142404	5	698
977	76561198155142404	4	699
978	76561198155142404	5	700
979	76561198155142404	1	702
980	76561198155142404	5	703
981	76561198155142404	4	704
982	76561198155142404	1	705
984	76561198050981415	1	702
985	76561198047012382	1	702
986	76561198047012382	3	704
988	76561198047012382	5	706
989	76561198047012382	3	701
990	76561198047012382	5	700
991	76561198047012382	3	699
992	76561198047012382	5	698
993	76561198047012382	5	697
994	76561198049220301	2	703
996	76561198050981415	5	704
997	76561198049220301	5	712
998	76561198049220301	5	714
999	76561198049220301	5	716
1000	76561198049220301	4	715
1003	76561198125222713	5	723
1004	76561198125222713	5	722
1005	76561198125222713	2	717
1006	76561198125222713	3	718
1011	76561198049220301	5	726
1012	76561198050981415	5	740
1013	76561198050981415	5	739
1016	76561198047012382	1	743
1021	76561198036168458	4	743
1022	76561198036168458	3	745
1023	76561198036168458	4	746
1024	76561198036168458	5	737
1026	76561198036168458	4	738
1031	76561198155142404	5	765
1032	76561198155142404	4	764
1034	76561198155142404	5	760
1035	76561198155142404	1	759
1036	76561198155142404	1	758
1039	76561198046244483	3	763
1040	76561198049220301	2	767
1041	76561198063209393	5	737
1045	76561198050981415	1	784
1046	76561198049220301	1	784
1047	76561198049220301	5	783
1048	76561198049220301	2	785
1049	76561198047012382	5	792
1050	76561198047012382	5	793
1051	76561198047012382	5	794
1052	76561198047012382	5	795
1053	76561198047012382	1	791
1054	76561198047012382	2	790
1055	76561198047012382	1	789
1056	76561198047012382	1	788
1057	76561198047012382	1	787
1059	76561198125222713	1	792
1060	76561198125222713	1	793
1061	76561198125222713	1	794
1062	76561198125222713	1	795
1063	76561198049220301	5	793
1064	76561198049220301	5	794
1065	76561198049220301	5	795
1066	76561198049220301	5	796
1067	76561198046244483	5	812
1068	76561198046244483	5	814
1069	76561198046244483	5	813
1070	76561198046244483	5	815
1071	76561198050981415	5	816
1072	76561198050981415	5	815
1073	76561198050981415	5	814
1074	76561198050981415	5	813
1075	76561198049220301	5	843
1076	76561198049220301	4	846
1077	76561198049220301	5	897
1078	76561198049220301	5	899
1079	76561198049220301	5	901
1080	76561198049220301	5	900
1081	76561198049220301	5	912
1082	76561198049220301	5	913
1083	76561198049220301	5	914
1084	76561198049220301	5	915
1085	76561198049220301	4	908
1086	76561198050981415	1	908
1087	76561198049220301	5	962
1088	76561198049220301	5	963
1089	76561198049220301	5	965
1090	76561198049220301	5	966
1091	76561198050981415	5	966
1092	76561198050981415	5	965
1093	76561198050981415	5	964
1094	76561198050981415	5	963
1095	76561198050981415	4	986
1096	76561198050981415	5	983
1097	76561198049220301	5	1007
1098	76561198049220301	5	1009
1099	76561198049220301	5	1010
1100	76561198049220301	5	1011
1101	76561198049220301	4	1015
1102	76561198049523020	5	1022
1103	76561198049523020	5	1042
1104	76561198049523020	5	1043
1105	76561198049523020	5	1044
1106	76561198049523020	5	1046
1107	76561198062081877	5	1038
1109	76561198062081877	5	1039
1111	76561198062081877	3	1041
1112	76561198050981415	5	1046
1113	76561198050981415	5	1045
1114	76561198050981415	5	1044
1115	76561198050981415	5	1043
1116	76561198050981415	4	1041
1117	76561198050981415	5	1038
1118	76561198050981415	2	1040
1119	76561198050981415	3	1037
1121	76561198050981415	5	1078
1122	76561198050981415	5	1080
1123	76561198050981415	5	1059
1124	76561198074711025	5	1078
1125	76561198074711025	5	1080
1126	76561198074711025	4	1077
1127	76561198074711025	5	1082
1128	76561198074711025	5	1084
1129	76561198074711025	4	1085
1130	76561198074711025	4	1086
1131	76561198049220301	3	1088
1132	76561198049220301	2	1089
1133	76561198049220301	1	1090
1134	76561198049220301	4	1091
1135	76561198049220301	5	1095
1136	76561198049220301	5	1094
1137	76561198049220301	5	1093
1138	76561198050981415	2	1105
1139	76561198050981415	2	1104
1140	76561198050981415	2	1103
1141	76561198049220301	1	1102
1142	76561198049220301	5	1104
1143	76561198049220301	1	1105
1144	76561198049220301	1	1106
1145	76561198049220301	1	1112
1146	76561198074711025	5	1114
1147	76561198074711025	3	1116
1148	76561198049220301	4	1107
1149	76561198049220301	4	1108
1150	76561198074711025	5	1115
1151	76561198049220301	3	1109
1152	76561198049220301	4	1111
1153	76561198049220301	1	1115
1154	76561198049220301	1	1116
1155	76561198049220301	1	1113
1156	76561198049220301	4	1114
1157	76561198074711025	4	1110
1158	76561198074711025	4	1109
1159	76561198074711025	4	1111
1160	76561198050981415	1	1110
1163	76561197997266515	3	1107
1164	76561197997266515	5	1111
1165	76561197997266515	5	1108
1166	76561198050981415	5	1114
1167	76561197997266515	1	1112
1168	76561197997266515	1	1113
1169	76561197997266515	1	1114
1170	76561197997266515	1	1115
1171	76561197997266515	1	1116
1172	76561198050981415	5	1115
1173	76561198050981415	5	517
1175	76561198074711025	1	520
1176	76561198050981415	3	1107
1177	76561198049220301	1	1118
1178	76561198049220301	1	1119
1179	76561198049220301	4	1120
1180	76561198049220301	1	1121
1181	76561198049220301	5	1128
1182	76561198049220301	5	1130
1183	76561198049220301	4	1129
1184	76561198049220301	5	1127
1185	76561198049220301	4	1133
1186	76561198050981415	1	1117
1187	76561198050981415	1	1119
1188	76561198050981415	1	1121
1189	76561198050981415	3	1120
1190	76561198049220301	3	1146
1191	76561198049220301	3	1145
1192	76561198049220301	4	1144
1193	76561198049220301	3	1143
1194	76561198049220301	5	1141
1195	76561198049220301	5	1137
1196	76561198074711025	4	1146
1198	76561198074711025	4	1144
1199	76561198074711025	4	1142
1219	76561198050981415	5	1185
1221	76561198050981415	4	1178
1223	76561198049220301	5	1185
1197	76561198074711025	4	1145
1200	76561198049220301	4	1148
1201	76561198049220301	5	1149
1202	76561198049220301	4	1147
1203	76561198049220301	5	1150
1204	76561198049220301	5	1151
1205	76561198049220301	1	1154
1206	76561198049220301	3	1153
1207	76561198049220301	3	1152
1208	76561198049220301	5	1155
1209	76561198049220301	5	1162
1210	76561198049220301	4	1166
1211	76561198049220301	4	1165
1212	76561198049220301	5	1163
1213	76561198049220301	5	1172
1214	76561198049220301	5	1174
1215	76561198049220301	5	1176
1216	76561198049220301	5	1175
1217	76561198050981415	5	1173
1218	76561198050981415	5	1164
1220	76561198050981415	5	1186
1222	76561198049220301	5	1182
1224	76561198049220301	5	1184
1225	76561198049220301	5	1186
1226	76561198049220301	5	1178
1227	76561197997266515	5	1182
1228	76561197997266515	5	1184
1229	76561197997266515	5	1186
1230	76561197997266515	5	1183
1231	76561197997266515	1	1178
1232	76561198049220301	1	1191
1233	76561198049220301	5	1190
1234	76561198049220301	5	1189
1235	76561198049220301	4	1188
1236	76561198049220301	5	1195
1237	76561198049220301	5	1196
1238	76561198049220301	5	1204
1239	76561198049220301	5	1203
1240	76561198049220301	5	1202
1241	76561198049220301	5	1198
1242	76561198049220301	4	1206
1243	76561198049220301	5	1207
1244	76561198049220301	4	1208
1245	76561198049220301	5	1210
1246	76561198049220301	4	1211
1247	76561198049220301	4	1223
1248	76561198049220301	4	1224
1249	76561198049220301	4	1225
1250	76561198049220301	4	1226
1251	76561198078115598	5	1217
1253	76561198078115598	4	1218
1254	76561198078115598	5	1220
1255	76561198078115598	5	1221
1256	76561198078115598	5	1233
1257	76561198078115598	5	1235
1258	76561198049220301	1	1229
1259	76561198049220301	1	1230
1260	76561198049220301	5	1231
1261	76561198049220301	5	1227
1262	76561198049220301	5	1239
1263	76561198050981415	5	1209
1264	76561198050981415	5	1213
1265	76561198016217359	1	1229
1266	76561198016217359	1	1230
1267	76561198016217359	5	1231
1268	76561198016217359	5	1228
1269	76561198016217359	1	1232
1270	76561198016217359	1	1234
1271	76561198016217359	1	1235
1272	76561198016217359	1	1236
1273	76561198016217359	1	1233
1274	76561198049220301	1	1262
1275	76561198049220301	5	1261
1276	76561198049220301	5	1272
1277	76561198016217359	1	1272
1278	76561198049220301	5	1280
1279	76561198049220301	4	1281
1280	76561198049220301	1	1279
1281	76561198049220301	4	1278
1282	76561198016217359	1	1279
1283	76561198016217359	1	1277
1284	76561198016217359	1	1278
1287	76561198016217359	1	1280
1290	76561198016217359	1	1281
1294	76561198016217359	1	1282
1296	76561198078115598	2	1283
1297	76561198078115598	2	1286
1298	76561198078115598	4	1284
1299	76561198041583699	1	1284
1300	76561198041583699	1	1282
1301	76561198041583699	5	1281
1302	76561198006183979	1	1229
1303	76561198041583699	1	1272
1304	76561198041583699	1	1268
1305	76561198041583699	1	1271
1306	76561198041583699	1	1270
1307	76561198041583699	1	1269
1308	76561198041583699	1	1273
1309	76561198041583699	1	1275
1310	76561198041583699	1	1276
1311	76561198041583699	1	1274
1312	76561198041583699	1	1229
1313	76561198041583699	1	1230
1314	76561198041583699	1	1233
1315	76561198041583699	5	1236
1316	76561198041583699	1	1235
1317	76561198049220301	5	1292
1318	76561198049220301	5	1293
1319	76561198049220301	5	1295
1320	76561198049220301	5	1296
1321	76561198041583699	5	1294
1322	76561198041583699	1	1287
1323	76561198041583699	1	1288
1324	76561198041583699	1	1289
1325	76561198041583699	1	1291
1326	76561198041583699	1	1290
1327	76561198016217359	1	1287
1328	76561198016217359	1	1292
1329	76561198016217359	1	1293
1330	76561198016217359	1	1294
1331	76561198016217359	1	1295
1332	76561198016217359	1	1296
1333	76561198016217359	5	1290
1334	76561198016217359	5	1289
1335	76561198016217359	5	1288
1336	76561198049220301	4	1287
1338	76561198049220301	4	1305
1339	76561198016217359	1	1305
1340	76561198074711025	4	1327
1341	76561198074711025	2	1328
1343	76561198074711025	3	1329
1344	76561198074711025	2	1330
1345	76561198074711025	3	1331
1346	76561198074711025	4	1332
1347	76561198074711025	4	1334
1348	76561198074711025	5	1335
1349	76561198074711025	4	1336
1350	76561198074711025	5	1355
1351	76561198074711025	5	1352
1352	76561198074711025	5	1354
1353	76561198074711025	5	1356
1354	76561198074711025	4	1351
1355	76561198074711025	3	1350
1356	76561198074711025	3	1349
1357	76561198074711025	4	1348
1358	76561198074711025	4	1347
1360	76561198050981415	5	1353
1361	76561198050981415	5	1354
1362	76561198050981415	5	1355
1363	76561198050981415	5	1356
1369	76561198050981415	5	1344
1371	76561198050981415	3	1333
1372	76561198050981415	5	1334
1373	76561198050981415	5	1330
1374	76561198050981415	4	1331
1375	76561198050981415	2	1328
1376	76561198050981415	2	1327
1381	76561198062517379	1	1377
1382	76561198062517379	1	1372
1383	76561198074711025	3	1373
1384	76561198062517379	1	1357
1385	76561198074711025	1	1375
1391	76561198050981415	1	1036
1393	76561198050981415	1	979
1364	76561198050981415	4	1350
1365	76561198050981415	3	1349
1366	76561198050981415	4	1348
1367	76561198050981415	3	1347
1379	76561198062517379	1	1352
1380	76561198074711025	4	1372
1388	76561198050981415	1	1363
1392	76561198050981415	1	1005
1368	76561198050981415	5	1346
1370	76561198050981415	3	1336
1378	76561198050981415	1	1373
1386	76561198074711025	4	1376
1387	76561198050981415	1	1383
1389	76561198050981415	1	1338
1394	76561198050981415	1	1394
1396	76561198050981415	5	1440
1397	76561198050981415	5	1439
1398	76561198050981415	2	1445
1399	76561198050981415	2	1466
1400	76561198050981415	4	1462
1401	76561198050981415	5	1530
1402	76561198050981415	5	1569
1404	76561198334460348	4	1567
1406	76561198334460348	5	1569
1407	76561198050981415	5	1568
1408	76561198049220301	3	1557
1409	76561198049220301	2	1558
1410	76561198049220301	1	1559
1411	76561198049220301	4	1560
1412	76561198334460348	4	1562
1413	76561198049220301	5	1561
1414	76561198334460348	5	1564
1415	76561198334460348	4	1563
1416	76561198334460348	3	1566
1417	76561198334460348	2	1565
1418	76561198049220301	5	1563
1419	76561198049220301	5	1564
1420	76561198049220301	5	1565
1421	76561198049220301	1	1566
1422	76561198049220301	1	1553
1423	76561198049220301	4	1555
1424	76561198049220301	3	1554
1425	76561198049220301	4	1552
1426	76561198334460348	4	1554
1427	76561198334460348	5	1553
1428	76561198049220301	3	1556
1429	76561198334460348	4	1556
1430	76561198334460348	5	1555
1431	76561198049220301	3	1551
1432	76561198049220301	3	1550
1433	76561198334460348	4	1547
1434	76561198049220301	5	1548
1435	76561198049220301	5	1549
1436	76561198334460348	4	1548
1437	76561198334460348	5	1549
1438	76561198334460348	4	1550
1439	76561198049220301	5	1537
1440	76561198049220301	5	1538
1441	76561198049220301	5	1539
1442	76561198334460348	3	1551
1443	76561198049220301	5	1541
1444	76561198334460348	5	1540
1445	76561198050981415	5	1541
1446	76561198334460348	5	1541
1447	76561198334460348	5	1539
1448	76561198334460348	5	1537
1449	76561198334460348	3	1546
1450	76561198334460348	2	1545
1451	76561198334460348	3	1544
1452	76561198334460348	3	1543
1453	76561198334460348	3	1542
1454	76561198050981415	5	1520
1455	76561198049220301	5	1498
1456	76561198049220301	5	1500
1457	76561198049220301	5	1501
1458	76561198049220301	5	1497
1459	76561198049220301	1	1487
1460	76561198050981415	1	1499
1461	76561198334460348	5	1517
1462	76561198334460348	5	1519
1463	76561198334460348	5	1520
1464	76561198334460348	5	1521
1465	76561198334460348	3	1522
1466	76561198334460348	3	1523
1467	76561198334460348	2	1524
1468	76561198334460348	3	1525
1469	76561198334460348	4	1526
1470	76561198050981415	5	1526
1471	76561198050981415	1	1523
1472	76561198334460348	5	1577
1474	76561198334460348	4	1578
1475	76561198334460348	5	1580
1476	76561198334460348	5	1581
1477	76561198050981415	5	1579
1478	76561198050981415	5	1577
1479	76561198050981415	5	1613
1480	76561198050981415	5	1614
1481	76561198050981415	5	1616
1482	76561198050981415	4	1615
1483	76561198050981415	1	1608
1484	76561198050981415	1	1611
1485	76561198050981415	5	1518
1486	76561198334460348	1	1608
1487	76561198050981415	5	1531
1488	76561198049220301	3	1622
1489	76561198049220301	3	1624
1490	76561198049220301	3	1625
1491	76561198049220301	3	1626
1492	76561198049220301	5	1638
1493	76561198049220301	5	1639
1494	76561198049220301	5	1640
1495	76561198049220301	5	1641
1496	76561198050981415	1	1623
1497	76561198050981415	2	1625
1498	76561198050981415	1	1624
1499	76561198050981415	1	1626
1500	76561198049220301	5	1617
1501	76561198049220301	5	1618
1502	76561198049220301	3	1619
1503	76561198049220301	4	1620
1504	76561198049220301	5	1621
1505	76561198050981415	5	1640
1506	76561198049220301	2	1648
1507	76561198049220301	4	1633
1508	76561198049220301	2	1634
1509	76561198049220301	1	1635
1510	76561198049220301	2	1632
1511	76561198049220301	5	1628
1512	76561198050981415	5	1650
1513	76561198050981415	5	1651
1514	76561198050981415	5	1647
1515	76561198050981415	1	1654
1516	76561198049220301	4	1652
1517	76561198049220301	4	1653
1518	76561198049220301	5	1663
1519	76561198049220301	5	1664
1520	76561198049220301	5	1665
1521	76561198049220301	5	1666
1522	76561198049220301	3	1657
1523	76561198049220301	4	1658
1524	76561198049220301	4	1659
1525	76561198049220301	3	1660
1526	76561198049220301	2	1661
1527	76561198050981415	3	1658
1528	76561198050981415	5	1659
1529	76561198050981415	1	1661
1530	76561198050981415	2	1662
1531	76561198050981415	5	1666
1532	76561198050981415	5	1665
1533	76561198049220301	1	1676
1534	76561198049220301	5	1686
1535	76561198049220301	4	1678
1536	76561198049220301	3	1685
1537	76561198049220301	5	1684
1538	76561198049220301	5	1683
1539	76561198050981415	5	1699
1540	76561198050981415	5	1702
1541	76561198050981415	5	1711
1542	76561198050981415	5	1721
1543	76561198050981415	5	1720
1544	76561198049220301	5	1749
1545	76561198049220301	5	1748
1546	76561198049220301	5	1750
1547	76561198049220301	5	1751
1549	76561198049220301	3	1753
1550	76561198049220301	4	1754
1551	76561198049220301	3	1755
1552	76561198049220301	3	1756
1553	76561198049220301	5	1758
1554	76561198049220301	5	1759
1555	76561198049220301	5	1761
1560	76561198049220301	3	1765
1561	76561198049220301	1	1766
1563	76561198050981415	2	1758
1564	76561198050981415	5	1759
1565	76561198050981415	2	1757
1571	76561198049220301	5	1805
1572	76561198049220301	5	1803
1573	76561198049220301	5	1802
1574	76561198049220301	5	1806
1594	76561198016217359	1	1808
1600	76561198016217359	1	1814
1601	76561198016217359	4	1815
1604	76561198016217359	5	1804
1605	76561198016217359	5	1805
1616	76561198016217359	1	1792
1621	76561198016217359	5	1787
1548	76561198049220301	1	1752
1556	76561198049220301	3	1763
1557	76561198049220301	5	1760
1567	76561198050981415	4	1732
1575	76561198049220301	2	1816
1577	76561198049220301	3	1813
1578	76561198049220301	4	1814
1579	76561198050981415	1	1822
1580	76561198050981415	1	1825
1581	76561198050981415	2	1826
1595	76561198016217359	5	1809
1613	76561198016217359	1	1794
1614	76561198016217359	1	1795
1615	76561198016217359	1	1796
1558	76561198049220301	3	1762
1559	76561198049220301	4	1764
1562	76561198050981415	4	1764
1566	76561198050981415	2	1734
1568	76561198050981415	4	1733
1569	76561198050981415	5	1719
1570	76561198050981415	5	1717
1587	76561198050981415	1	1816
1593	76561198050981415	2	1808
1596	76561198016217359	5	1811
1598	76561198016217359	2	1812
1608	76561198016217359	1	1800
1609	76561198016217359	5	1799
1610	76561198016217359	3	1798
1611	76561198016217359	1	1797
1618	76561198016217359	5	1790
1619	76561198016217359	3	1789
1620	76561198016217359	5	1788
1576	76561198049220301	4	1812
1582	76561198049220301	2	1823
1583	76561198049220301	5	1817
1584	76561198049220301	4	1819
1585	76561198049220301	5	1820
1586	76561198049220301	5	1821
1588	76561198050981415	3	1815
1589	76561198050981415	4	1813
1590	76561198050981415	3	1814
1591	76561198050981415	5	1811
1592	76561198050981415	4	1807
1597	76561198016217359	4	1807
1599	76561198016217359	1	1813
1602	76561198016217359	2	1816
1603	76561198016217359	2	1803
1606	76561198016217359	5	1806
1607	76561198016217359	4	1801
1617	76561198016217359	1	1791
1622	76561198049220301	1	1827
1624	76561198049220301	5	1847
1625	76561198049220301	5	1848
1626	76561198049220301	5	1849
1627	76561198049220301	5	1851
1628	76561198050981415	1	1855
1629	76561198050981415	2	1856
1630	76561198050981415	2	1854
1631	76561198050981415	4	1852
1632	76561198050981415	4	1844
1633	76561198050981415	1	1842
1634	76561198049220301	3	1863
1635	76561198049220301	1	1862
1636	76561198049220301	1	1866
1637	76561198049220301	2	1865
1638	76561198049220301	3	1864
1639	76561198049220301	5	1858
1640	76561198049220301	5	1859
1641	76561198049220301	5	1860
1642	76561198049220301	5	1861
1643	76561198050981415	5	1866
1644	76561198050981415	1	1865
1645	76561198050981415	2	1864
1646	76561198050981415	1	1862
1647	76561198050981415	5	1861
1648	76561198050981415	5	1859
1649	76561198050981415	5	1858
1650	76561198050981415	3	1857
1652	76561198050981415	5	1875
1653	76561198050981415	5	1876
1654	76561198050981415	5	1874
1655	76561198050981415	5	1872
1656	76561198049220301	4	1873
1657	76561198050981415	2	1877
1658	76561198050981415	2	1881
1659	76561198050981415	2	1879
1660	76561198050981415	4	1880
1661	76561198050981415	5	1883
1662	76561198050981415	5	1884
1663	76561198050981415	2	1882
1664	76561198050981415	2	1886
1665	76561198050981415	1	1906
1666	76561198050981415	5	1916
1667	76561198050981415	1	1832
1668	76561198050981415	4	1913
1669	76561198050981415	5	1912
1670	76561198050981415	5	1915
1671	76561198050981415	1	1907
1672	76561198050981415	1	1910
1673	76561198049220301	1	1880
1674	76561198049220301	4	1878
1675	76561198049220301	4	1895
1676	76561198049220301	4	1894
1677	76561198049220301	3	1893
1678	76561198049220301	3	1892
1679	76561198049220301	5	1890
1681	76561198049220301	1	1888
1682	76561198049220301	4	1902
1683	76561198049220301	5	1906
1684	76561198050981415	1	1896
1685	76561198050981415	5	1921
1686	76561198050981415	5	1920
1687	76561198050981415	4	1919
1688	76561198050981415	4	1917
1689	76561198049220301	1	1342
1690	76561198049220301	3	1918
1691	76561198049220301	2	1926
1692	76561198049220301	4	1923
1693	76561198049220301	3	1922
1694	76561198049220301	3	1924
1695	76561198049220301	3	1925
1696	76561198050981415	5	1933
1697	76561198050981415	4	1931
1698	76561198050981415	4	1929
1699	76561198050981415	4	1927
1700	76561198050981415	4	1930
1701	76561198334460348	5	1943
1702	76561198334460348	5	1945
1703	76561198334460348	5	1944
1704	76561198334460348	5	1942
1705	76561198334460348	5	1933
1706	76561198334460348	5	1928
1707	76561198334460348	4	1929
1708	76561198334460348	4	1930
1709	76561198334460348	4	1931
1710	76561198334460348	5	1918
1711	76561198334460348	5	1919
1712	76561198334460348	5	1920
1713	76561198334460348	5	1921
1714	76561198334460348	3	1923
1715	76561198334460348	2	1924
1716	76561198334460348	2	1925
1717	76561198334460348	1	1926
1718	76561198334460348	3	1922
1719	76561198050981415	5	1944
1720	76561198050981415	5	1945
1721	76561198050981415	5	1942
1722	76561198050981415	5	1946
1723	76561198016217359	4	1942
1724	76561198016217359	4	1943
1725	76561198016217359	5	1946
1726	76561198016217359	4	1945
1727	76561198334460348	1	1881
1728	76561198334460348	5	1878
1729	76561198334460348	3	1879
1730	76561198334460348	3	1880
1731	76561198334460348	5	1883
1732	76561198334460348	4	1884
1733	76561198049220301	4	1946
1734	76561198050981415	5	1951
1735	76561198050981415	5	1950
1736	76561198050981415	5	1959
1737	76561198050981415	5	1960
1738	76561198049220301	5	1957
1739	76561198049220301	1	1958
1740	76561198049220301	4	1959
1741	76561198049220301	5	1960
1742	76561198049220301	2	1964
1743	76561198049220301	3	1966
1744	76561198049220301	2	1952
1745	76561198049220301	3	1953
1746	76561198049220301	2	1955
1747	76561198049220301	3	1956
1748	76561198049220301	5	1968
1749	76561198049220301	5	1970
1750	76561198049220301	5	1971
1751	76561198049220301	5	1967
1752	76561198049220301	3	1991
1753	76561198049220301	5	1989
1754	76561198049220301	4	1988
1755	76561198049220301	5	1987
1757	76561198049220301	4	1995
1758	76561198049220301	2	1993
1759	76561198050981415	5	1995
1760	76561198050981415	2	1993
1761	76561198050981415	2	1996
1762	76561198050981415	3	1994
1765	76561198050981415	2	1988
1766	76561198050981415	4	1987
1768	76561198050981415	4	1774
1769	76561198050981415	4	1776
1770	76561198049220301	1	2005
1774	76561198049220301	5	1999
1763	76561198050981415	1	1991
1764	76561198050981415	5	1989
1767	76561198050981415	5	1772
1776	76561198049220301	5	2000
1771	76561198049220301	5	2003
1772	76561198049220301	3	2004
1773	76561198049220301	4	2002
1778	76561198050981415	5	2026
1779	76561198334460348	1	1990
1780	76561198050981415	5	2027
1781	76561198050981415	5	2029
1782	76561198050981415	2	2076
1783	76561198050981415	2	2072
1784	76561198050981415	5	2070
1785	76561198050981415	5	2068
1786	76561198050981415	3	2075
1787	76561198050981415	5	2140
1788	76561198050981415	5	2141
1789	76561198050981415	5	2139
1790	76561198050981415	5	2137
1791	76561198050981415	5	2149
1792	76561198050981415	5	2158
1793	76561198050981415	5	2159
1794	76561198050981415	5	2160
1795	76561198050981415	5	2161
1796	76561198050981415	4	2170
1797	76561198050981415	4	2171
1798	76561198050981415	4	2167
1799	76561198334460348	5	2067
1801	76561198049220301	5	2217
1802	76561198049220301	5	2219
1803	76561198049220301	5	2218
1804	76561198049220301	5	2220
1805	76561198049220301	2	2223
1806	76561198049220301	3	2224
1807	76561198049220301	5	2225
1808	76561198049220301	3	2226
1809	76561198049220301	2	2222
1810	76561198049220301	5	2208
1811	76561198049220301	1	2215
1812	76561198049220301	1	2214
1813	76561198049220301	1	2212
1814	76561198049220301	2	2213
1815	76561198049220301	3	2199
1816	76561198049220301	5	2200
1817	76561198049220301	3	2198
1818	76561198049220301	3	2197
1820	76561198049220301	3	2194
1821	76561198049220301	3	2193
1822	76561198049220301	2	2195
1823	76561198049220301	2	2196
1824	76561198050981415	1	2224
1825	76561198050981415	3	2225
1826	76561198049220301	5	2191
1827	76561198050981415	1	2226
1828	76561198050981415	1	2222
1829	76561198049220301	2	2186
1830	76561198050981415	1	2221
1831	76561198050981415	4	2210
1832	76561198050981415	5	2211
1833	76561198050981415	4	2209
1834	76561198050981415	2	2207
1835	76561198050981415	2	2200
1836	76561198050981415	5	2205
1837	76561198050981415	5	2202
1838	76561198050981415	4	2204
1839	76561198050981415	4	2206
1840	76561198334460348	5	2219
1841	76561198334460348	5	2209
1842	76561198050981415	1	2232
1843	76561198050981415	5	2246
1844	76561198050981415	5	2245
1845	76561198050981415	5	2242
1846	76561198050981415	5	2243
1847	76561198050981415	5	2252
1848	76561198050981415	5	2254
1849	76561198049220301	1	2264
1850	76561198050981415	5	2292
1851	76561198050981415	5	2294
1852	76561198050981415	5	2296
1853	76561198050981415	4	2295
1854	76561198006183979	1	2289
1855	76561198006183979	1	2288
1856	76561198041583699	5	2289
1857	76561198041583699	1	2288
1858	76561198041583699	1	2291
1859	76561198041583699	1	2290
1860	76561198041583699	5	2287
1862	76561198041583699	1	2295
1863	76561198041583699	5	2293
1864	76561198041583699	5	2294
1865	76561198041583699	5	2296
1866	76561198041583699	1	2237
1867	76561198041583699	1	2239
1868	76561198041583699	1	2232
1869	76561198041583699	1	2236
1870	76561198041583699	1	2227
1872	76561198041583699	1	2139
1874	76561198041583699	5	2141
1875	76561198041583699	1	2142
1876	76561198041583699	5	2091
1877	76561198041583699	1	2092
1878	76561198041583699	1	2094
1879	76561198041583699	1	2079
1880	76561198041583699	5	2081
1881	76561198041583699	1	2082
1882	76561198041583699	5	2069
1883	76561198041583699	5	2071
1884	76561198041583699	1	2064
1885	76561198041583699	1	2049
1886	76561198041583699	1	2051
1887	76561198041583699	1	2052
1888	76561198041583699	1	2038
1889	76561198041583699	1	2045
1890	76561198041583699	1	2046
1891	76561198041583699	1	2027
1893	76561198041583699	5	2032
1894	76561198041583699	1	2019
1895	76561198041583699	1	2020
1897	76561198041583699	5	2024
1898	76561198041583699	1	1999
1899	76561198041583699	5	2002
1900	76561198041583699	1	2006
1901	76561198041583699	5	1711
1902	76561198041583699	1	1712
1903	76561198041583699	5	1702
1904	76561198041583699	1	1700
1905	76561198041583699	1	1698
1907	76561198041583699	1	1540
1908	76561198041583699	1	1461
1909	76561198041583699	1	1462
1910	76561198041583699	1	1454
1911	76561198041583699	1	1447
1913	76561198041583699	1	1442
1914	76561198041583699	1	1445
1915	76561198041583699	1	1400
1916	76561198041583699	5	1404
1917	76561198041583699	1	1406
1918	76561198041583699	5	1394
1919	76561198041583699	1	1391
1921	76561198041583699	5	1390
1922	76561198041583699	1	1388
1924	76561198041583699	1	1326
1925	76561198041583699	1	1313
1926	76561198041583699	5	1308
1928	76561198041583699	1	1286
1929	76561198041583699	1	1277
1930	76561198049220301	4	2293
1931	76561198049220301	5	2292
1932	76561198049220301	5	2294
1933	76561198050981415	5	2300
1934	76561198050981415	5	2301
1936	76561198049220301	5	2297
1940	76561198049220301	5	2302
1941	76561198049220301	3	2303
1942	76561198049220301	3	2306
1943	76561198049220301	3	2304
1944	76561198049220301	3	2305
1945	76561198049220301	4	2308
1946	76561198049220301	5	2313
1947	76561198049220301	5	2314
1948	76561198049220301	5	2315
1949	76561198049220301	5	2316
1952	76561198049220301	4	2309
1957	76561198049220301	5	2324
1963	76561198050981415	5	2331
1972	76561198041583699	1	2329
1975	76561198049220301	5	2331
1985	76561198047012382	2	2331
1992	76561198050981415	1	2336
1993	76561198047012382	1	2317
1994	76561198047012382	3	2318
1995	76561198049220301	5	2337
2002	76561198074711025	5	2325
2012	76561198049220301	1	2347
2013	76561198049220301	1	2348
2014	76561198049220301	1	2349
2015	76561198049220301	5	2352
2016	76561198049220301	5	2353
2017	76561198049220301	5	2355
2018	76561198049220301	5	2356
2019	76561198050981415	1	2281
2024	76561198049220301	5	2373
1935	76561198049220301	5	2298
1938	76561198049220301	5	2299
1939	76561198049220301	5	2300
1950	76561198049220301	4	2310
1951	76561198049220301	3	2311
1953	76561198049220301	2	2307
1955	76561198049220301	5	2325
1956	76561198049220301	4	2326
1958	76561198049220301	4	2322
1959	76561198049220301	5	2321
1960	76561198049220301	3	2317
1961	76561198050981415	1	2330
1962	76561198050981415	1	2329
1964	76561198050981415	5	2327
1965	76561198041583699	5	2328
1966	76561198041583699	1	2332
1967	76561198041583699	1	2333
1968	76561198041583699	1	2334
1969	76561198041583699	1	2336
1970	76561198041583699	1	2335
1971	76561198041583699	1	2330
1973	76561198041583699	5	2331
1974	76561198049220301	4	2328
1976	76561198049220301	5	2333
1977	76561198049220301	5	2336
1978	76561198049220301	5	2334
1979	76561198049220301	5	2335
1980	76561198049220301	3	2330
1981	76561198049220301	2	2329
1982	76561198049220301	4	2327
1983	76561198047012382	1	2330
1984	76561198047012382	1	2329
1986	76561198047012382	1	2327
1987	76561198047012382	1	2328
1988	76561198047012382	5	2332
1989	76561198047012382	5	2333
1990	76561198047012382	5	2334
1991	76561198047012382	5	2335
1996	76561198049220301	5	2338
1997	76561198049220301	5	2340
1998	76561198049220301	5	2341
1999	76561198074711025	5	2339
2000	76561198074711025	5	2323
2001	76561198074711025	5	2324
2003	76561198050981415	1	2352
2004	76561198050981415	1	2353
2005	76561198050981415	1	2354
2006	76561198050981415	1	2355
2007	76561198050981415	1	2356
2008	76561198050981415	1	2351
2009	76561198050981415	1	2350
2010	76561198050981415	1	2349
2011	76561198050981415	5	2348
2020	76561198049220301	4	2360
2021	76561198049220301	4	2359
2022	76561198049220301	4	2358
2023	76561198049220301	4	2361
2025	76561198049220301	5	2374
2026	76561198049220301	4	2372
2027	76561198050981415	5	2383
2028	76561198050981415	5	2384
2029	76561198050981415	5	2396
2030	76561198050981415	4	2395
2031	76561198050981415	4	2403
2032	76561198050981415	5	2404
2033	76561198050981415	5	2405
2034	76561198050981415	5	2406
2035	76561198050981415	5	2456
2036	76561198050981415	5	2455
2037	76561198050981415	5	2454
2038	76561198050981415	5	2452
2039	76561198050981415	5	2487
2040	76561198050981415	5	2490
2041	76561198050981415	5	2489
2042	76561198050981415	5	2505
2043	76561198050981415	5	2506
2044	76561198050981415	5	2504
2045	76561198050981415	5	2502
2046	76561198050981415	2	2525
2047	76561198050981415	2	2526
2048	76561198050981415	2	2522
2049	76561198050981415	5	2533
2050	76561198050981415	5	2532
2051	76561198050981415	5	2535
2052	76561198050981415	5	2536
2053	76561198050981415	1	2539
2054	76561198334460348	5	2467
2055	76561198334460348	5	2468
2056	76561198334460348	3	2471
2057	76561198334460348	1	2381
2058	76561198334460348	2	2377
2059	76561198334460348	5	2396
2060	76561198334460348	1	2403
2061	76561198334460348	4	2408
2062	76561198334460348	1	2419
2063	76561198334460348	1	2459
2064	76561198334460348	5	2469
2065	76561198334460348	5	2488
2066	76561198334460348	5	2489
2067	76561198334460348	5	2487
2068	76561198334460348	3	2491
2069	76561198334460348	5	2503
2070	76561198334460348	5	2504
2071	76561198334460348	5	2506
2072	76561198334460348	4	2509
2073	76561198334460348	5	2507
2075	76561198334460348	2	2513
2076	76561198334460348	5	2520
2077	76561198334460348	2	2528
2078	76561198334460348	2	2531
2079	76561198334460348	1	2539
2080	76561198334460348	1	2537
2081	76561198334460348	5	2543
2082	76561198334460348	5	2545
2083	76561198334460348	5	2546
2084	76561198334460348	5	2544
2085	76561198334460348	1	2538
2086	76561198334460348	5	2573
2087	76561198334460348	5	2574
2088	76561198334460348	3	2575
2089	76561198334460348	5	2585
2090	76561198334460348	5	2586
2091	76561198334460348	5	2583
2092	76561198334460348	5	2582
2093	76561198050981415	2	2596
2094	76561198334460348	5	2591
2095	76561198334460348	5	2590
2096	76561198334460348	1	2587
2097	76561198334460348	5	2588
2098	76561198050981415	1	2603
2099	76561198334460348	5	2601
2100	76561198334460348	5	2600
2101	76561198334460348	5	2598
2102	76561198334460348	5	2597
2103	76561198334460348	5	2616
2104	76561198334460348	5	2615
2105	76561198334460348	5	2614
2106	76561198334460348	5	2613
2108	76561198050981415	5	2622
2110	76561198050981415	5	2702
2111	76561198050981415	5	2706
2112	76561198050981415	5	2730
2113	76561198050981415	5	2727
2114	76561198050981415	5	2729
2115	76561198050981415	5	2731
2116	76561198050981415	5	2744
2117	76561198050981415	1	2751
2118	76561198050981415	1	2750
2119	76561198050981415	1	2749
2120	76561198050981415	1	2748
2121	76561198050981415	1	2747
2123	76561198050981415	1	2752
2124	76561198050981415	1	2721
2125	76561198006183979	5	2728
\.


--
-- Name: player_match_rating_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.player_match_rating_id_seq', 2126, true);


--
-- Data for Name: player_match_stats; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.player_match_stats (id, season_stats_id, match_id, old_pts, pts_diff, kills, assists, deaths, hero_damage, last_hits, player_slot, denies, tower_damage, hero, hero_healing, level, damage_taken, gold_per_min, xp_per_min) FROM stdin;
1	1	1274068589	1000	10	11	8	3	26031	352	0	20	5513	alchemist	0	25	\N	\N	\N
2	10	1274068589	1000	10	1	9	11	5494	39	1	3	0	disruptor	0	13	\N	\N	\N
3	11	1274068589	1000	10	13	11	6	22455	190	2	9	6246	clinkz	0	25	\N	\N	\N
4	5	1274068589	1000	10	0	5	6	4100	74	3	0	287	omniknight	6135	19	\N	\N	\N
5	4	1274068589	1000	10	7	5	10	23547	160	4	5	1832	centaur	0	19	\N	\N	\N
6	12	1274068589	1000	-10	10	10	4	22006	175	128	0	2649	bristleback	0	23	\N	\N	\N
7	13	1274068589	1000	-10	7	12	4	15583	240	129	18	1960	dragon_knight	0	20	\N	\N	\N
8	9	1274068589	1000	-10	7	11	7	11982	124	130	2	499	bloodseeker	778	18	\N	\N	\N
9	6	1274068589	1000	-10	0	11	13	5265	25	131	19	481	witch_doctor	1254	12	\N	\N	\N
10	14	1274068589	1000	-10	12	11	5	24055	136	132	14	0	earthshaker	0	20	\N	\N	\N
11	16	1274674136	1000	10	3	14	5	12911	41	0	1	537	razor	0	13	\N	\N	\N
12	10	1274674136	1010	10	4	14	9	14234	37	1	4	434	rattletrap	400	14	\N	\N	\N
13	17	1274674136	1000	10	9	7	3	8025	35	2	2	264	spirit_breaker	0	14	\N	\N	\N
14	15	1274674136	1000	10	14	5	1	29894	178	3	23	5547	juggernaut	0	22	\N	\N	\N
15	18	1274674136	1000	10	4	9	3	5141	35	4	4	15	omniknight	5484	17	\N	\N	\N
16	5	1274674136	1010	-10	2	3	6	5695	48	128	6	0	legion_commander	0	13	\N	\N	\N
17	12	1274674136	990	-10	3	8	3	9492	123	129	1	0	axe	0	15	\N	\N	\N
18	8	1274674136	1000	-10	3	8	10	13697	77	130	4	23	lich	0	13	\N	\N	\N
19	1	1274674136	1010	-10	9	7	9	18708	121	131	2	41	ursa	0	18	\N	\N	\N
20	19	1274674136	1000	-10	3	6	7	7672	18	132	7	466	jakiro	2250	11	\N	\N	\N
21	1	1280751055	1000	-10	0	0	8	5708	179	0	19	315	nevermore	0	14	\N	\N	\N
22	20	1280751055	1000	-10	1	1	3	1933	101	1	1	403	drow_ranger	0	11	\N	\N	\N
23	21	1280751055	1000	-10	1	2	9	3252	23	2	4	0	lion	0	10	\N	\N	\N
24	4	1280751055	1010	-10	3	1	9	11540	44	3	1	0	rattletrap	0	12	\N	\N	\N
25	17	1280751055	1010	-10	0	2	7	474	3	4	1	0	omniknight	758	8	\N	\N	\N
26	5	1280751055	1000	10	2	10	0	3055	23	128	3	908	ogre_magi	0	15	\N	\N	\N
27	11	1280751055	1010	10	20	7	1	22632	140	129	10	15414	sniper	0	20	\N	\N	\N
28	6	1280751055	990	10	8	6	2	8548	114	130	11	445	axe	0	16	\N	\N	\N
29	22	1280751055	1000	10	2	6	2	8875	36	131	2	342	pudge	1600	12	\N	\N	\N
30	10	1280751055	1020	10	4	7	3	5467	33	132	1	247	skywrath_mage	0	11	\N	\N	\N
31	1	1280840885	990	11	14	17	1	24862	173	0	19	4873	windrunner	0	22	\N	\N	\N
32	4	1280840885	1000	11	8	19	5	16270	118	1	3	1423	skeleton_king	2369	18	\N	\N	\N
33	5	1280840885	1010	11	8	12	3	17107	180	2	10	3922	weaver	0	22	\N	\N	\N
34	17	1280840885	1000	11	13	17	5	15469	122	3	0	2780	axe	0	20	\N	\N	\N
35	22	1280840885	1010	11	4	21	9	6774	24	4	1	498	witch_doctor	3076	13	\N	\N	\N
36	6	1280840885	1000	-11	0	3	7	7428	143	128	0	0	chaos_knight	0	16	\N	\N	\N
37	11	1280840885	1020	-11	10	4	10	19643	87	129	9	84	slark	0	20	\N	\N	\N
38	21	1280840885	990	-11	7	9	7	22117	61	130	17	0	queenofpain	0	18	\N	\N	\N
39	10	1280840885	1030	-11	3	9	16	10873	41	131	1	0	earthshaker	0	12	\N	\N	\N
40	20	1280840885	990	-11	0	7	9	7345	14	132	3	0	rubick	0	9	\N	\N	\N
41	20	1280898627	979	12	8	14	9	11247	88	0	1	1239	doom_bringer	2010	18	\N	\N	\N
42	11	1280898627	1009	12	10	6	5	14093	223	1	12	8832	juggernaut	0	22	\N	\N	\N
43	23	1280898627	1000	12	1	15	8	6682	22	2	0	436	skywrath_mage	0	13	\N	\N	\N
44	4	1280898627	1011	12	10	12	5	35007	262	3	5	4391	skeleton_king	2238	23	\N	\N	\N
45	6	1280898627	989	12	3	11	6	6990	35	4	2	659	vengefulspirit	0	14	\N	\N	\N
46	1	1280898627	1001	-12	15	12	2	37314	339	128	37	1312	morphling	223	25	\N	\N	\N
47	5	1280898627	1021	-12	2	19	4	9479	33	129	0	0	shadow_demon	82	14	\N	\N	\N
48	21	1280898627	979	-12	3	14	9	14279	56	130	3	76	storm_spirit	0	14	\N	\N	\N
49	17	1280898627	1011	-12	5	14	8	14739	74	131	0	0	spirit_breaker	0	18	\N	\N	\N
50	10	1280898627	1019	-12	2	16	9	8350	18	132	2	0	bane	0	14	\N	\N	\N
57	4	1283861898	1023	-11	4	5	7	20539	165	0	6	339	skeleton_king	698	17	\N	\N	\N
58	17	1283861898	999	-11	1	4	7	4032	114	1	0	0	axe	0	14	\N	\N	\N
59	1	1283861898	989	-11	10	3	10	11653	124	2	31	107	invoker	0	15	\N	\N	\N
60	25	1283861898	1000	-11	1	6	8	15151	79	3	11	0	centaur	0	15	\N	\N	\N
61	26	1283861898	1000	-11	0	8	10	2377	37	4	1	57	witch_doctor	1123	11	\N	\N	\N
62	6	1283861898	1001	11	6	16	5	15097	128	128	9	80	storm_spirit	1200	21	\N	\N	\N
63	8	1283861898	990	11	8	3	1	12144	74	129	0	1117	techies	0	13	\N	\N	\N
64	11	1283861898	1021	11	10	11	6	17933	66	130	3	316	nyx_assassin	0	20	\N	\N	\N
65	15	1283861898	1010	11	18	6	2	26536	197	131	16	2128	phantom_assassin	0	24	\N	\N	\N
66	21	1283861898	967	11	0	3	2	1104	27	132	4	1871	shadow_shaman	0	8	\N	\N	\N
67	5	1286030237	1009	13	1	15	2	4547	36	0	7	1436	dazzle	5807	17	\N	\N	\N
68	27	1286030237	1000	13	3	14	2	6279	38	1	18	1548	disruptor	1994	15	\N	\N	\N
69	21	1286030237	978	13	5	10	1	10084	101	2	10	2600	windrunner	0	18	\N	\N	\N
70	26	1286030237	989	13	4	9	7	10917	69	3	1	1299	centaur	0	15	\N	\N	\N
71	1	1286030237	978	13	20	7	3	27002	279	4	5	9018	alchemist	0	21	\N	\N	\N
72	28	1286030237	1000	-13	6	8	10	16441	24	128	1	0	necrolyte	1551	11	\N	\N	\N
73	25	1286030237	989	-13	0	6	8	6043	65	129	11	0	silencer	0	13	\N	\N	\N
74	3	1286030237	1000	-13	7	0	3	15458	214	130	84	1179	viper	1319	19	\N	\N	\N
75	15	1286030237	1021	-13	2	3	4	5688	239	131	19	0	morphling	0	18	\N	\N	\N
76	10	1286030237	1007	-13	0	7	8	10013	36	132	0	18	tidehunter	137	13	\N	\N	\N
77	13	1286218079	990	11	13	17	4	28163	201	0	19	3162	sniper	0	23	\N	\N	\N
78	1	1286218079	991	11	16	17	3	27781	166	1	22	3241	invoker	0	23	\N	\N	\N
79	3	1286218079	987	11	8	8	5	13023	141	2	2	1059	axe	0	19	\N	\N	\N
80	10	1286218079	994	11	11	21	10	16899	50	3	0	152	rattletrap	0	17	\N	\N	\N
81	27	1286218079	1013	11	4	20	4	10308	37	4	5	762	skywrath_mage	2887	18	\N	\N	\N
82	5	1286218079	1022	-11	5	8	7	9366	72	128	7	716	windrunner	0	19	\N	\N	\N
83	4	1286218079	1012	-11	9	12	6	41577	187	129	8	524	skeleton_king	1689	22	\N	\N	\N
84	21	1286218079	991	-11	3	6	11	5040	114	130	8	269	templar_assassin	0	18	\N	\N	\N
85	25	1286218079	976	-11	7	10	13	9818	18	131	4	0	lich	1341	15	\N	\N	\N
86	26	1286218079	1002	-11	2	7	15	5486	29	132	3	114	lion	0	12	\N	\N	\N
87	1	1286519243	1002	-11	9	6	10	22712	337	0	12	1310	nevermore	0	25	\N	\N	\N
88	4	1286519243	1001	-11	0	10	9	12951	78	1	4	36	phoenix	548	18	\N	\N	\N
89	5	1286519243	1011	-11	2	7	11	5577	42	2	1	14	vengefulspirit	0	14	\N	\N	\N
90	3	1286519243	998	-11	9	5	6	16179	333	3	50	599	juggernaut	0	24	\N	\N	\N
91	26	1286519243	991	-11	4	7	11	8205	66	4	3	1080	shadow_shaman	0	15	\N	\N	\N
92	6	1286519243	1012	11	10	17	3	21510	325	128	39	10522	phantom_lancer	0	24	\N	\N	\N
93	25	1286519243	965	11	5	19	7	13051	92	129	0	1673	puck	0	20	\N	\N	\N
94	10	1286519243	1005	11	4	12	6	5808	37	130	0	765	bane	0	16	\N	\N	\N
95	7	1286519243	1000	11	9	21	4	15788	94	131	0	1495	sand_king	0	22	\N	\N	\N
96	13	1286519243	1001	11	18	17	4	27312	256	132	10	7046	sniper	0	25	\N	\N	\N
97	6	1286738035	1023	9	7	12	5	18771	96	0	14	1470	nyx_assassin	0	22	\N	\N	\N
98	15	1286738035	1008	9	24	7	2	27197	353	1	14	16950	juggernaut	0	25	\N	\N	\N
99	3	1286738035	987	9	0	9	10	5194	55	2	11	623	vengefulspirit	0	14	\N	\N	\N
100	30	1286738035	1000	9	7	12	8	9840	23	3	8	750	skywrath_mage	0	16	\N	\N	\N
101	7	1286738035	1011	9	12	10	3	14706	133	4	10	2662	phoenix	3101	24	\N	\N	\N
102	1	1286738035	991	-9	3	9	3	26460	235	128	0	18	tinker	0	19	\N	\N	\N
103	11	1286738035	1032	-9	4	2	11	10251	170	129	14	467	troll_warlord	0	18	\N	\N	\N
104	31	1286738035	1000	-9	2	2	13	3888	38	130	2	0	lion	0	13	\N	\N	\N
105	13	1286738035	1012	-9	8	10	14	18507	74	131	1	300	pugna	150	19	\N	\N	\N
106	4	1286738035	990	-9	9	8	11	21817	144	132	4	35	spectre	0	23	\N	\N	\N
107	11	1286912949	1023	10	3	14	10	7738	71	0	1	1153	spirit_breaker	0	16	\N	\N	\N
108	1	1286912949	982	10	10	8	11	14819	205	1	0	834	shredder	2769	21	\N	\N	\N
109	30	1286912949	1009	10	6	18	5	8492	43	2	4	1106	vengefulspirit	0	20	\N	\N	\N
110	3	1286912949	996	10	18	10	5	25013	139	3	4	3221	lina	0	24	\N	\N	\N
111	15	1286912949	1017	10	12	6	4	20709	258	4	15	5277	juggernaut	0	24	\N	\N	\N
112	6	1286912949	1032	-10	11	11	8	18527	189	128	17	0	phantom_assassin	0	21	\N	\N	\N
113	4	1286912949	981	-10	1	15	14	8640	15	129	4	78	lion	0	15	\N	\N	\N
114	13	1286912949	1003	-10	11	9	10	22043	63	130	8	162	pugna	329	18	\N	\N	\N
115	31	1286912949	991	-10	0	15	10	5993	86	131	2	0	enigma	0	17	\N	\N	\N
116	7	1286912949	1020	-10	10	15	7	26356	219	132	16	515	nevermore	0	22	\N	\N	\N
117	6	1287145153	1022	-7	6	6	11	9095	93	0	7	0	slardar	0	17	\N	\N	\N
118	4	1287145153	971	-7	4	6	12	10400	86	1	2	0	bloodseeker	1215	16	\N	\N	\N
119	32	1287145153	1000	-7	3	6	6	9526	50	2	1	16	ancient_apparition	0	14	\N	\N	\N
120	31	1287145153	981	-7	0	7	11	7325	21	3	8	0	ogre_magi	0	14	\N	\N	\N
121	33	1287145153	1000	-7	5	5	11	16306	26	4	1	0	pudge	0	16	\N	\N	\N
122	1	1287145153	992	7	12	9	2	20727	174	128	18	8477	morphling	0	22	\N	\N	\N
123	5	1287145153	1000	7	19	8	4	20697	140	129	2	3624	broodmother	0	21	\N	\N	\N
124	13	1287145153	993	7	3	14	6	4430	27	130	4	52	witch_doctor	592	16	\N	\N	\N
125	11	1287145153	1033	7	12	16	5	21590	117	131	21	2162	slark	0	21	\N	\N	\N
126	3	1287145153	1006	7	4	7	3	6337	71	132	14	729	dazzle	1720	17	\N	\N	\N
127	4	1287264156	964	-8	6	4	6	17814	108	0	3	210	slark	0	17	\N	\N	\N
128	30	1287264156	1019	-8	13	2	7	17118	39	1	11	16	skywrath_mage	0	17	\N	\N	\N
129	8	1287264156	1001	-8	2	8	9	5339	61	2	3	0	witch_doctor	0	12	\N	\N	\N
130	1	1287264156	999	-8	2	5	5	6774	124	3	2	0	life_stealer	498	17	\N	\N	\N
131	34	1287264156	1000	-8	4	4	10	8979	40	4	3	0	rattletrap	0	15	\N	\N	\N
132	5	1287264156	1007	8	2	6	3	3248	120	128	8	1248	doom_bringer	1637	17	\N	\N	\N
133	31	1287264156	974	8	2	4	9	2831	33	129	5	550	vengefulspirit	0	13	\N	\N	\N
134	26	1287264156	980	8	3	5	9	6561	31	130	3	235	lich	0	13	\N	\N	\N
135	11	1287264156	1040	8	11	7	3	14143	142	131	9	9010	troll_warlord	0	20	\N	\N	\N
136	3	1287264156	1013	8	19	6	3	25969	139	132	18	2796	riki	0	22	\N	\N	\N
137	4	1287360270	956	-10	13	5	7	25966	380	0	7	624	phantom_assassin	0	25	\N	\N	\N
138	6	1287360270	1015	-10	3	7	8	10090	227	1	3	1052	bristleback	0	20	\N	\N	\N
139	11	1287360270	1048	-10	12	9	8	18547	201	2	4	864	brewmaster	1443	23	\N	\N	\N
140	34	1287360270	992	-10	2	8	9	9186	48	3	14	0	shadow_demon	0	17	\N	\N	\N
141	5	1287360270	1015	-10	1	8	5	10307	23	4	1	144	wisp	7586	14	\N	\N	\N
142	1	1287360270	991	10	9	13	5	26098	333	128	10	4067	invoker	0	25	\N	\N	\N
143	8	1287360270	993	10	2	10	7	13229	56	129	5	65	ancient_apparition	0	15	\N	\N	\N
144	15	1287360270	1027	10	15	9	2	27282	353	130	9	9057	faceless_void	0	25	\N	\N	\N
145	26	1287360270	988	10	2	13	11	7451	82	131	2	164	lich	0	19	\N	\N	\N
146	30	1287360270	1011	10	7	15	7	22763	265	132	5	591	shredder	0	25	\N	\N	\N
147	4	1289354277	946	11	10	12	7	54238	173	0	5	3366	skeleton_king	3678	24	\N	\N	\N
148	27	1289354277	1024	11	4	15	11	13607	45	1	2	1172	disruptor	2322	17	\N	\N	\N
149	35	1289354277	1000	11	2	16	10	9677	22	2	2	667	vengefulspirit	0	17	\N	\N	\N
150	5	1289354277	1005	11	7	11	2	21697	210	3	7	5840	lone_druid	1025	24	\N	\N	\N
151	13	1289354277	1000	11	7	12	6	22533	223	4	7	3075	razor	0	21	\N	\N	\N
152	1	1289354277	1001	-11	4	12	5	22943	181	128	3	582	invoker	0	20	\N	\N	\N
153	9	1289354277	990	-11	10	7	5	18687	188	129	10	2323	juggernaut	0	23	\N	\N	\N
154	36	1289354277	1000	-11	14	8	6	37897	274	130	16	7568	troll_warlord	0	25	\N	\N	\N
155	3	1289354277	1021	-11	3	7	11	6817	41	131	2	326	lion	0	16	\N	\N	\N
156	32	1289354277	993	-11	5	7	6	16370	139	132	2	319	axe	0	18	\N	\N	\N
157	6	1289554851	1005	10	4	12	4	4238	14	0	2	801	vengefulspirit	0	11	\N	\N	\N
158	4	1289554851	957	10	13	12	3	16031	113	1	7	2392	skeleton_king	3102	19	\N	\N	\N
159	5	1289554851	1016	10	7	13	1	10607	20	2	0	841	nyx_assassin	0	18	\N	\N	\N
160	11	1289554851	1038	10	18	13	4	25417	97	3	9	4872	sniper	0	18	\N	\N	\N
161	26	1289554851	998	10	4	10	7	4545	20	4	1	808	spirit_breaker	1162	13	\N	\N	\N
162	1	1289554851	990	-10	4	7	8	7556	70	128	16	0	invoker	0	13	\N	\N	\N
163	8	1289554851	1003	-10	7	3	11	6755	22	129	4	0	witch_doctor	0	10	\N	\N	\N
164	27	1289554851	1035	-10	3	4	9	7633	16	130	8	0	skywrath_mage	0	11	\N	\N	\N
165	9	1289554851	979	-10	2	5	6	7955	83	131	7	145	phantom_assassin	0	15	\N	\N	\N
166	10	1289554851	1016	-10	2	7	13	8883	20	132	0	0	rattletrap	0	9	\N	\N	\N
167	9	1289701890	969	-9	14	21	8	41936	150	0	0	342	sand_king	0	25	\N	\N	\N
168	5	1289701890	1026	-9	5	17	4	26743	85	1	2	4234	windrunner	0	21	\N	\N	\N
169	10	1289701890	1006	-9	13	15	14	23164	78	2	1	1467	night_stalker	487	23	\N	\N	\N
170	31	1289701890	982	-9	5	8	15	9215	35	3	5	0	vengefulspirit	0	15	\N	\N	\N
171	6	1289701890	1015	-9	4	16	9	22490	234	4	13	2324	phantom_lancer	0	22	\N	\N	\N
172	1	1289701890	980	9	14	12	6	42488	306	128	27	6929	juggernaut	0	25	\N	\N	\N
173	4	1289701890	967	9	9	19	7	27695	177	129	1	1192	tidehunter	0	22	\N	\N	\N
174	37	1289701890	1000	9	7	21	11	14992	55	130	0	52	crystal_maiden	0	19	\N	\N	\N
175	26	1289701890	1008	9	8	12	14	12713	104	131	2	459	spirit_breaker	0	20	\N	\N	\N
176	11	1289701890	1048	9	11	17	7	28605	228	132	6	5685	magnataur	0	25	\N	\N	\N
177	4	1289914848	976	10	6	20	13	22195	130	0	4	738	tidehunter	0	22	\N	\N	\N
178	31	1289914848	973	10	4	11	8	8707	18	1	6	810	lion	875	17	\N	\N	\N
179	10	1289914848	997	10	14	10	7	29183	189	2	26	7605	troll_warlord	0	25	\N	\N	\N
180	13	1289914848	1011	10	13	15	8	34056	197	3	8	3383	sniper	0	25	\N	\N	\N
181	6	1289914848	1006	10	5	17	8	15386	170	4	5	3129	doom_bringer	0	25	\N	\N	\N
182	17	1289914848	988	-10	6	13	7	11744	78	128	3	427	ogre_magi	0	20	\N	\N	\N
183	26	1289914848	1017	-10	7	16	7	41225	341	129	5	628	centaur	0	25	\N	\N	\N
184	37	1289914848	1009	-10	3	12	11	8712	37	130	6	17	witch_doctor	1532	16	\N	\N	\N
185	1	1289914848	989	-10	24	6	7	37210	359	131	7	2186	windrunner	0	25	\N	\N	\N
186	9	1289914848	960	-10	4	7	10	9885	363	132	2	94	faceless_void	0	25	\N	\N	\N
187	11	1290093058	1057	9	15	14	5	28093	226	0	25	10210	troll_warlord	0	25	\N	\N	\N
188	38	1290093058	1000	9	7	15	6	12271	58	1	3	1019	tusk	0	18	\N	\N	\N
189	32	1290093058	982	9	7	9	4	16142	261	2	21	5481	weaver	0	23	\N	\N	\N
190	17	1290093058	978	9	5	12	5	13577	151	3	4	3346	bristleback	0	19	\N	\N	\N
191	8	1290093058	993	9	5	13	10	7836	57	4	1	845	vengefulspirit	1028	16	\N	\N	\N
192	6	1290093058	1016	-9	7	12	7	12553	131	128	7	0	storm_spirit	0	18	\N	\N	\N
193	4	1290093058	986	-9	6	14	10	28501	250	129	6	82	slark	0	22	\N	\N	\N
194	13	1290093058	1021	-9	10	13	10	12752	18	130	2	0	skywrath_mage	0	16	\N	\N	\N
195	10	1290093058	1007	-9	3	14	9	25229	110	131	7	0	rattletrap	0	16	\N	\N	\N
196	1	1290093058	979	-9	3	13	4	16264	116	132	4	101	windrunner	1871	17	\N	\N	\N
197	10	1290249225	998	-8	5	8	5	5902	24	0	2	0	omniknight	6246	16	\N	\N	\N
198	8	1290249225	1002	-8	9	9	9	26588	121	1	1	0	lina	0	18	\N	\N	\N
199	13	1290249225	1012	-8	8	8	6	19739	178	2	6	858	phantom_assassin	0	21	\N	\N	\N
200	4	1290249225	977	-8	2	9	7	14915	102	3	0	0	tidehunter	0	17	\N	\N	\N
201	5	1290249225	1017	-8	3	6	12	7003	24	4	1	0	lion	0	15	\N	\N	\N
202	32	1290249225	991	8	2	15	8	7789	24	128	0	711	nyx_assassin	0	14	\N	\N	\N
203	6	1290249225	1007	8	6	10	3	9456	222	129	16	5098	faceless_void	0	21	\N	\N	\N
204	11	1290249225	1066	8	11	13	4	16114	172	130	17	12342	troll_warlord	0	22	\N	\N	\N
205	38	1290249225	1009	8	9	20	6	12556	47	131	7	1048	rubick	3623	18	\N	\N	\N
206	1	1290249225	970	8	10	18	6	29279	187	132	1	1031	shredder	318	21	\N	\N	\N
207	15	1290318010	1037	-8	2	1	3	1133	29	0	1	0	antimage	0	6	\N	\N	\N
208	38	1290318010	1017	-8	0	1	5	1212	6	1	3	0	lion	0	4	\N	\N	\N
209	4	1290318010	969	-8	0	2	1	3203	56	2	1	0	tidehunter	0	9	\N	\N	\N
210	5	1290318010	1009	-8	1	1	2	1872	5	3	1	0	disruptor	0	6	\N	\N	\N
211	8	1290318010	994	-8	0	0	3	2285	36	4	0	0	kunkka	0	8	\N	\N	\N
212	10	1290318010	990	8	1	9	1	2434	1	128	0	221	mirana	0	5	\N	\N	\N
213	1	1290318010	978	8	6	0	0	5016	59	129	5	48	storm_spirit	0	11	\N	\N	\N
214	13	1290318010	1004	8	2	4	1	1560	2	130	12	0	bane	0	7	\N	\N	\N
215	6	1290318010	1015	8	1	1	0	1449	80	131	15	77	life_stealer	31	10	\N	\N	\N
216	11	1290318010	1074	8	4	3	2	3186	49	132	9	0	bristleback	0	8	\N	\N	\N
217	23	1290350591	1012	10	2	7	0	2856	26	0	5	244	tidehunter	0	1	\N	\N	\N
218	13	1290350591	1012	10	1	3	3	1155	5	1	0	30	dazzle	932	1	\N	\N	\N
219	10	1290350591	998	10	6	4	0	6491	29	2	3	553	queenofpain	0	1	\N	\N	\N
220	38	1290350591	1009	10	1	2	3	1565	35	3	8	161	witch_doctor	685	1	\N	\N	\N
221	15	1290350591	1029	10	6	5	1	4848	35	4	18	161	riki	0	1	\N	\N	\N
222	6	1290350591	1023	-10	1	1	4	2893	45	128	12	0	razor	0	1	\N	\N	\N
223	8	1290350591	986	-10	0	2	6	3632	11	129	0	13	ancient_apparition	0	1	\N	\N	\N
224	5	1290350591	1001	-10	3	2	1	5313	44	130	7	49	bristleback	0	1	\N	\N	\N
225	1	1290350591	986	-10	3	1	4	3193	50	131	0	0	tinker	0	1	\N	\N	\N
226	11	1290350591	1082	-10	0	2	1	2938	57	132	13	350	clinkz	0	1	\N	\N	\N
227	39	1291841940	1000	-10	2	3	7	4341	54	0	3	1140	shadow_shaman	0	11	\N	\N	\N
228	10	1291841940	1008	-10	4	4	13	9572	44	1	1	74	queenofpain	0	11	\N	\N	\N
229	7	1291841940	1010	-10	2	7	6	4188	28	2	4	0	vengefulspirit	0	11	\N	\N	\N
230	23	1291841940	1022	-10	2	9	9	19470	100	3	3	0	bristleback	0	14	\N	\N	\N
231	9	1291841940	950	-10	6	1	4	8059	119	4	13	219	morphling	0	15	\N	\N	\N
232	40	1291841940	1000	10	2	21	5	5609	33	128	6	188	undying	1609	15	\N	\N	\N
233	1	1291841940	976	10	14	10	1	23296	214	129	19	3489	nevermore	0	22	\N	\N	\N
234	3	1291841940	1010	10	6	3	5	9207	198	130	23	3408	faceless_void	0	18	\N	\N	\N
235	13	1291841940	1022	10	14	7	1	15686	130	131	1	374	ursa	0	20	\N	\N	\N
236	12	1291841940	980	10	3	12	5	6402	27	132	3	0	disruptor	750	13	\N	\N	\N
237	8	1291972299	976	-10	5	7	6	7778	29	0	1	0	bane	0	17	\N	\N	\N
238	10	1291972299	998	-10	4	5	10	12793	30	1	1	0	pudge	0	16	\N	\N	\N
239	23	1291972299	1012	-10	9	5	8	16090	103	2	8	0	lich	0	20	\N	\N	\N
240	3	1291972299	1020	-10	5	7	7	12019	357	3	8	1108	gyrocopter	0	22	\N	\N	\N
241	1	1291972299	986	-10	4	7	5	18767	300	4	8	0	phantom_assassin	0	21	\N	\N	\N
242	7	1291972299	1000	10	6	13	3	13010	217	128	10	3871	doom_bringer	0	23	\N	\N	\N
243	9	1291972299	940	10	11	8	3	23193	293	129	3	5694	broodmother	0	25	\N	\N	\N
244	39	1291972299	990	10	1	3	11	3804	32	130	10	524	witch_doctor	985	15	\N	\N	\N
245	6	1291972299	1013	10	9	7	5	10409	246	131	12	2122	faceless_void	0	21	\N	\N	\N
246	13	1291972299	1032	10	9	16	5	19224	139	132	12	4719	invoker	0	23	\N	\N	\N
247	8	1292187436	966	9	16	12	1	20236	81	0	2	3200	witch_doctor	5344	19	\N	\N	\N
248	10	1292187436	988	9	8	18	1	15416	59	1	1	3824	mirana	0	18	\N	\N	\N
249	13	1292187436	1042	9	15	13	3	21172	260	2	14	8920	juggernaut	0	23	\N	\N	\N
250	38	1292187436	1019	9	4	12	7	6826	23	3	4	751	rubick	399	14	\N	\N	\N
251	29	1292187436	1000	9	2	26	6	9071	20	4	2	1815	vengefulspirit	1048	15	\N	\N	\N
252	1	1292187436	976	-9	5	6	6	14020	123	128	0	0	doom_bringer	0	17	\N	\N	\N
253	23	1292187436	1002	-9	4	3	13	10617	71	129	5	0	shredder	901	14	\N	\N	\N
254	39	1292187436	1000	-9	0	5	14	4449	11	130	9	0	bane	0	13	\N	\N	\N
255	3	1292187436	1010	-9	6	4	6	14933	200	131	34	315	invoker	0	19	\N	\N	\N
256	6	1292187436	1023	-9	2	4	7	3813	89	132	13	0	faceless_void	0	16	\N	\N	\N
257	10	1292371811	997	11	13	7	4	15327	26	0	3	724	pudge	2237	16	\N	\N	\N
258	26	1292371811	1007	11	9	7	4	8201	4	1	0	155	lion	0	14	\N	\N	\N
259	38	1292371811	1028	11	10	18	3	14291	80	2	7	1001	phoenix	876	18	\N	\N	\N
260	4	1292371811	961	11	3	11	5	5657	130	3	6	1311	enigma	0	14	\N	\N	\N
261	6	1292371811	1014	11	7	8	1	12772	167	4	28	3252	life_stealer	350	17	\N	\N	\N
262	27	1292371811	1025	-11	3	2	13	4085	21	128	7	0	ancient_apparition	382	9	\N	\N	\N
263	41	1292371811	1000	-11	4	4	10	4701	8	129	2	0	crystal_maiden	0	12	\N	\N	\N
264	32	1292371811	999	-11	2	3	7	7036	103	130	12	355	medusa	0	15	\N	\N	\N
265	42	1292371811	1000	-11	5	5	6	10234	93	131	13	0	magnataur	0	15	\N	\N	\N
266	29	1292371811	1009	-11	1	8	6	6748	72	132	10	0	brewmaster	0	13	\N	\N	\N
267	6	1292443205	1025	12	7	9	1	12179	247	0	30	13726	drow_ranger	0	19	\N	\N	\N
268	4	1292443205	972	12	5	16	5	8513	59	1	4	1046	undying	1297	15	\N	\N	\N
269	1	1292443205	967	12	13	7	3	15377	142	2	2	1874	storm_spirit	1361	21	\N	\N	\N
270	38	1292443205	1039	12	3	8	2	3169	33	3	7	1207	dazzle	6735	11	\N	\N	\N
271	32	1292443205	988	12	1	10	5	2446	29	4	0	3689	shadow_shaman	0	11	\N	\N	\N
272	8	1292443205	975	-12	5	6	6	14022	90	128	0	269	silencer	0	15	\N	\N	\N
273	10	1292443205	1008	-12	0	12	6	5002	21	129	1	86	mirana	0	11	\N	\N	\N
274	13	1292443205	1051	-12	6	9	5	17644	185	130	12	196	sniper	0	14	\N	\N	\N
275	26	1292443205	1018	-12	1	6	6	6541	90	131	0	118	bristleback	0	14	\N	\N	\N
276	29	1292443205	998	-12	4	7	6	6155	28	132	3	212	ogre_magi	0	11	\N	\N	\N
277	4	1292523642	984	10	6	21	5	15325	126	0	2	1657	tidehunter	0	22	\N	\N	\N
278	1	1292523642	979	10	15	16	6	30734	243	1	11	1394	tinker	0	22	\N	\N	\N
279	6	1292523642	1037	10	11	9	1	12625	217	2	38	8677	phantom_lancer	0	22	\N	\N	\N
280	18	1292523642	1010	10	3	11	6	4756	15	3	1	936	vengefulspirit	0	15	\N	\N	\N
281	38	1292523642	1051	10	6	15	5	5963	20	4	3	1631	bane	3824	16	\N	\N	\N
282	8	1292523642	963	-10	12	0	6	15598	244	128	2	0	phantom_assassin	0	23	\N	\N	\N
283	10	1292523642	996	-10	3	14	13	6529	8	129	0	0	spirit_breaker	556	11	\N	\N	\N
284	39	1292523642	991	-10	2	7	8	8947	51	130	9	0	puck	0	15	\N	\N	\N
285	11	1292523642	1072	-10	3	11	8	9995	172	131	29	0	troll_warlord	0	17	\N	\N	\N
286	13	1292523642	1039	-10	3	11	6	8289	48	132	12	0	mirana	0	15	\N	\N	\N
287	8	1294239846	953	12	10	9	3	24619	142	0	2	1523	zuus	0	19	\N	\N	\N
288	23	1294239846	993	12	10	9	5	15294	143	1	5	1532	axe	0	18	\N	\N	\N
289	43	1294239846	1000	12	11	7	2	19114	257	2	14	5564	phantom_assassin	0	21	\N	\N	\N
290	37	1294239846	999	12	2	5	9	1958	12	3	3	466	lion	0	11	\N	\N	\N
291	25	1294239846	976	12	2	8	4	2646	35	4	8	1173	ogre_magi	0	15	\N	\N	\N
292	1	1294239846	989	-12	2	6	4	9737	197	128	14	213	morphling	0	18	\N	\N	\N
293	10	1294239846	986	-12	3	9	7	5914	6	129	6	49	disruptor	0	11	\N	\N	\N
294	3	1294239846	1001	-12	3	5	8	4796	90	130	1	18	sand_king	0	13	\N	\N	\N
295	20	1294239846	991	-12	11	7	4	16959	115	131	12	37	windrunner	0	19	\N	\N	\N
296	4	1294239846	994	-12	3	7	12	5475	54	132	1	0	tidehunter	0	13	\N	\N	\N
297	4	1294381465	982	-7	8	12	7	48161	185	0	8	585	skeleton_king	1057	25	\N	\N	\N
298	3	1294381465	989	-7	6	6	16	12367	97	1	8	309	mirana	0	20	\N	\N	\N
299	10	1294381465	974	-7	4	11	17	16873	66	2	1	0	spirit_breaker	0	17	\N	\N	\N
300	13	1294381465	1029	-7	0	4	7	2793	13	3	3	0	vengefulspirit	0	8	\N	\N	\N
301	8	1294381465	965	-7	15	9	14	24014	111	4	4	0	witch_doctor	1407	24	\N	\N	\N
302	38	1294381465	1061	7	11	21	7	27217	67	128	1	1295	nyx_assassin	2298	24	\N	\N	\N
303	1	1294381465	977	7	29	15	6	59568	307	129	12	572	tinker	0	25	\N	\N	\N
304	37	1294381465	1011	7	5	16	8	10339	26	130	1	1826	jakiro	0	18	\N	\N	\N
305	31	1294381465	983	7	5	11	11	7597	45	131	4	813	lion	750	19	\N	\N	\N
306	9	1294381465	950	7	11	8	3	20807	201	132	9	7752	juggernaut	0	23	\N	\N	\N
307	9	1294563503	957	10	9	6	9	13385	195	0	9	2223	storm_spirit	0	21	\N	\N	\N
308	1	1294563503	984	10	18	4	1	18862	301	1	4	9372	windrunner	0	25	\N	\N	\N
309	38	1294563503	1068	10	2	5	3	7254	42	2	6	433	ancient_apparition	0	14	\N	\N	\N
310	13	1294563503	1022	10	3	9	1	9692	185	3	0	3110	ursa	0	22	\N	\N	\N
311	31	1294563503	990	10	3	11	6	5436	83	4	0	411	spirit_breaker	400	17	\N	\N	\N
312	6	1294563503	1047	-10	2	5	2	8167	250	128	31	84	faceless_void	0	20	\N	\N	\N
313	4	1294563503	975	-10	10	7	7	19538	58	129	0	442	rattletrap	0	17	\N	\N	\N
314	44	1294563503	1000	-10	4	6	8	8837	116	130	10	0	kunkka	0	18	\N	\N	\N
315	3	1294563503	982	-10	2	5	8	4112	118	131	19	546	silencer	0	16	\N	\N	\N
316	37	1294563503	1018	-10	2	5	10	5884	27	132	3	36	crystal_maiden	0	13	\N	\N	\N
317	37	1294681796	1008	10	1	4	1	3066	3	0	3	0	lion	0	9	\N	\N	\N
318	23	1294681796	1005	10	1	2	1	4199	33	1	2	60	centaur	0	9	\N	\N	\N
319	4	1294681796	965	10	7	4	0	7307	94	2	8	543	skeleton_king	300	15	\N	\N	\N
320	3	1294681796	972	10	1	4	0	2310	91	3	0	1066	enigma	0	11	\N	\N	\N
321	1	1294681796	994	10	8	7	1	9323	97	4	10	1196	windrunner	0	14	\N	\N	\N
322	6	1294681796	1037	-10	0	0	2	1028	122	128	22	0	antimage	0	11	\N	\N	\N
323	17	1294681796	987	-10	0	2	3	2359	8	129	7	0	ogre_magi	0	9	\N	\N	\N
324	31	1294681796	1000	-10	0	1	6	3760	31	130	1	0	tidehunter	0	8	\N	\N	\N
325	8	1294681796	958	-10	3	0	2	5011	29	131	4	0	lina	0	9	\N	\N	\N
326	9	1294681796	967	-10	0	3	6	2110	39	132	1	0	invoker	0	10	\N	\N	\N
327	4	1294751130	975	10	5	19	8	15972	100	0	4	689	tidehunter	0	21	\N	\N	\N
328	33	1294751130	993	10	5	18	10	9267	52	1	5	2215	witch_doctor	4438	18	\N	\N	\N
329	9	1294751130	957	10	17	18	6	26373	214	2	8	8020	troll_warlord	0	25	\N	\N	\N
330	37	1294751130	1018	10	5	10	12	9508	36	3	0	364	lion	0	16	\N	\N	\N
331	43	1294751130	1012	10	14	23	6	30237	187	4	2	1355	lina	0	24	\N	\N	\N
332	1	1294751130	1004	-10	6	15	7	15440	196	128	6	1094	storm_spirit	2900	22	\N	\N	\N
333	3	1294751130	982	-10	16	9	11	26058	172	129	30	2104	sniper	0	23	\N	\N	\N
334	8	1294751130	948	-10	10	11	7	13214	153	130	1	316	axe	0	18	\N	\N	\N
335	23	1294751130	1015	-10	5	14	10	16431	49	131	0	620	lich	812	19	\N	\N	\N
336	26	1294751130	1006	-10	3	9	11	6224	70	132	0	761	shadow_shaman	0	16	\N	\N	\N
337	6	1294832806	1027	-14	1	3	6	5097	75	0	14	0	life_stealer	184	10	\N	\N	\N
338	4	1294832806	985	-14	2	6	8	6512	2	1	0	0	lich	0	9	\N	\N	\N
339	43	1294832806	1022	-14	3	0	5	12672	62	2	2	17	warlock	0	10	\N	\N	\N
340	37	1294832806	1028	-14	0	2	11	2606	6	3	5	0	witch_doctor	631	6	\N	\N	\N
341	33	1294832806	1003	-14	2	3	9	9920	37	4	2	85	viper	0	8	\N	\N	\N
342	8	1294832806	938	14	1	19	2	6476	24	128	0	487	earthshaker	0	11	\N	\N	\N
343	23	1294832806	1005	14	9	17	3	13288	60	129	5	2919	bristleback	0	14	\N	\N	\N
344	1	1294832806	994	14	11	3	0	11796	91	130	6	5036	morphling	0	15	\N	\N	\N
345	11	1294832806	1062	14	5	10	3	5713	26	131	9	907	dazzle	8638	13	\N	\N	\N
346	3	1294832806	972	14	12	6	2	12728	85	132	9	4220	clinkz	0	14	\N	\N	\N
347	13	1296550050	1032	-10	4	12	11	9570	36	0	6	550	dazzle	10712	13	\N	\N	\N
348	10	1296550050	967	-10	3	13	10	22173	43	1	4	176	pudge	0	15	\N	\N	\N
349	35	1296550050	1011	-10	3	12	7	7251	37	2	4	524	vengefulspirit	0	14	\N	\N	\N
350	3	1296550050	986	-10	4	13	9	22329	122	3	2	2179	bristleback	0	17	\N	\N	\N
351	43	1296550050	1008	-10	13	6	5	22313	233	4	0	3583	antimage	0	23	\N	\N	\N
352	9	1296550050	967	10	20	11	4	29733	174	128	7	10440	juggernaut	0	21	\N	\N	\N
353	45	1296550050	1000	10	4	13	5	5637	30	129	2	2735	shadow_shaman	644	14	\N	\N	\N
354	23	1296550050	1019	10	10	13	6	16595	44	130	0	902	witch_doctor	364	15	\N	\N	\N
355	32	1296550050	1000	10	2	10	6	8093	102	131	3	2134	doom_bringer	923	16	\N	\N	\N
356	6	1296550050	1013	10	6	19	7	15684	93	132	20	999	storm_spirit	157	19	\N	\N	\N
357	13	1296751287	1022	9	10	9	6	16119	107	0	0	2333	ursa	1030	19	\N	\N	\N
358	9	1296751287	977	9	19	15	3	31797	130	1	2	7355	centaur	0	24	\N	\N	\N
359	23	1296751287	1029	9	8	13	4	15292	178	2	18	3649	faceless_void	0	21	\N	\N	\N
360	26	1296751287	996	9	3	8	10	6697	28	3	0	331	lich	0	14	\N	\N	\N
361	6	1296751287	1023	9	11	24	4	17611	116	4	5	3361	storm_spirit	2519	24	\N	\N	\N
362	1	1296751287	1008	-9	10	3	7	18929	213	128	12	121	windrunner	0	22	\N	\N	\N
363	4	1296751287	971	-9	8	5	8	24645	171	129	2	112	slark	0	21	\N	\N	\N
364	38	1296751287	1078	-9	3	11	12	20458	82	130	1	75	phoenix	515	18	\N	\N	\N
365	10	1296751287	957	-9	2	6	14	5571	18	131	1	319	vengefulspirit	0	12	\N	\N	\N
366	27	1296751287	1014	-9	3	5	10	6765	24	132	5	169	disruptor	0	12	\N	\N	\N
367	1	1297072659	999	-10	5	5	8	14527	159	0	9	823	storm_spirit	0	17	\N	\N	\N
368	4	1297072659	962	-10	3	4	8	13213	90	1	1	0	tidehunter	0	15	\N	\N	\N
369	3	1297072659	976	-10	3	8	6	14485	168	2	0	1643	enigma	0	19	\N	\N	\N
370	37	1297072659	1014	-10	1	8	11	6458	17	3	2	227	jakiro	0	11	\N	\N	\N
371	6	1297072659	1032	-10	6	4	5	11503	146	4	16	788	phantom_lancer	0	15	\N	\N	\N
372	10	1297072659	948	10	7	16	6	15152	34	128	2	1758	pudge	400	17	\N	\N	\N
373	17	1297072659	977	10	11	17	2	15006	93	129	0	3102	bristleback	0	19	\N	\N	\N
374	46	1297072659	1000	10	9	17	4	16035	80	130	0	2443	doom_bringer	0	19	\N	\N	\N
375	38	1297072659	1069	10	4	8	5	9898	208	131	18	4135	juggernaut	0	17	\N	\N	\N
376	29	1297072659	986	10	7	13	3	9542	25	132	4	2691	lion	0	18	\N	\N	\N
377	10	1297160515	958	-8	3	7	10	7464	39	0	0	93	spirit_breaker	400	15	\N	\N	\N
378	37	1297160515	1004	-8	0	0	9	1153	17	1	1	0	omniknight	4294	9	\N	\N	\N
379	1	1297160515	989	-8	3	2	8	17954	188	2	1	973	ember_spirit	0	17	\N	\N	\N
380	17	1297160515	987	-8	6	2	13	9799	48	3	2	219	lina	0	14	\N	\N	\N
381	6	1297160515	1022	-8	4	0	4	12978	214	4	30	0	juggernaut	0	18	\N	\N	\N
382	8	1297160515	952	8	17	7	2	19767	345	128	16	7904	sven	0	24	\N	\N	\N
383	46	1297160515	1010	8	6	19	3	8159	14	129	5	1317	vengefulspirit	0	16	\N	\N	\N
384	4	1297160515	952	8	4	19	4	16877	63	130	1	698	rattletrap	0	16	\N	\N	\N
385	38	1297160515	1079	8	13	11	3	26149	174	131	18	2765	queenofpain	0	21	\N	\N	\N
386	29	1297160515	996	8	4	13	4	7345	22	132	6	2319	lion	0	19	\N	\N	\N
387	46	1297240757	1018	8	5	19	4	17025	72	0	2	1539	rattletrap	0	16	\N	\N	\N
388	8	1297240757	960	8	9	6	2	8803	130	1	9	2502	slardar	0	17	\N	\N	\N
389	1	1297240757	981	8	17	12	3	24457	143	2	11	6180	templar_assassin	0	20	\N	\N	\N
390	29	1297240757	1004	8	2	20	3	8888	19	3	7	2111	vengefulspirit	0	17	\N	\N	\N
391	11	1297240757	1076	8	10	16	5	12798	20	4	1	1456	skywrath_mage	0	15	\N	\N	\N
392	37	1297240757	996	-8	3	4	9	3472	1	128	5	0	necrolyte	1738	8	\N	\N	\N
393	10	1297240757	950	-8	1	5	8	7168	39	129	2	0	sand_king	0	11	\N	\N	\N
394	4	1297240757	960	-8	5	6	10	14035	64	130	0	0	bristleback	0	16	\N	\N	\N
395	38	1297240757	1087	-8	2	4	11	5849	97	131	6	115	storm_spirit	0	14	\N	\N	\N
396	6	1297240757	1014	-8	4	4	8	8944	119	132	21	0	troll_warlord	0	14	\N	\N	\N
397	4	1297301907	952	10	6	5	0	14169	116	0	7	752	slark	0	15	\N	\N	\N
398	8	1297301907	968	10	1	8	2	4539	39	1	2	699	vengefulspirit	0	11	\N	\N	\N
399	11	1297301907	1084	10	5	5	3	7692	76	2	11	2399	death_prophet	0	13	\N	\N	\N
400	6	1297301907	1006	10	9	7	0	8921	110	3	3	1944	bristleback	0	16	\N	\N	\N
401	29	1297301907	1012	10	3	11	6	6316	8	4	1	496	ancient_apparition	500	10	\N	\N	\N
402	46	1297301907	1026	-10	3	3	3	5224	53	128	0	0	doom_bringer	0	11	\N	\N	\N
403	37	1297301907	988	-10	1	2	8	2430	3	129	2	0	bane	0	9	\N	\N	\N
404	1	1297301907	989	-10	7	2	2	11968	90	130	14	489	windrunner	0	14	\N	\N	\N
405	38	1297301907	1079	-10	0	2	5	3352	52	131	11	0	troll_warlord	0	8	\N	\N	\N
406	10	1297301907	942	-10	0	2	7	6136	63	132	6	0	centaur	0	11	\N	\N	\N
407	10	1299378094	932	-10	2	4	9	4977	43	0	1	0	bristleback	0	10	\N	\N	\N
408	31	1299378094	990	-10	0	2	10	2300	10	1	8	0	vengefulspirit	0	10	\N	\N	\N
409	37	1299378094	978	-10	1	2	7	1105	5	2	0	0	ogre_magi	0	7	\N	\N	\N
410	46	1299378094	1016	-10	3	1	7	9147	111	3	18	0	razor	0	15	\N	\N	\N
411	11	1299378094	1094	-10	5	3	7	10029	98	4	27	52	slark	0	14	\N	\N	\N
412	1	1299378094	979	10	23	7	0	22204	166	128	1	5689	phantom_assassin	0	20	\N	\N	\N
413	23	1299378094	1038	10	9	16	2	14712	128	129	47	3110	gyrocopter	0	17	\N	\N	\N
414	26	1299378094	1005	10	4	11	3	4337	36	130	2	1555	spirit_breaker	1600	13	\N	\N	\N
415	3	1299378094	966	10	2	15	3	8933	63	131	3	1048	magnataur	0	15	\N	\N	\N
416	29	1299378094	1022	10	2	17	3	6727	11	132	7	1053	lion	0	14	\N	\N	\N
417	23	1299504372	1048	-9	1	6	4	4267	82	0	16	0	troll_warlord	0	9	\N	\N	\N
418	6	1299504372	1016	-9	1	3	4	5051	77	1	17	0	phantom_assassin	0	12	\N	\N	\N
419	26	1299504372	1015	-9	1	0	4	5381	43	2	0	0	centaur	0	10	\N	\N	\N
420	37	1299504372	968	-9	2	2	3	3962	4	3	6	0	lion	0	9	\N	\N	\N
421	31	1299504372	980	-9	3	2	7	3719	28	4	2	0	crystal_maiden	0	9	\N	\N	\N
422	46	1299504372	1006	9	6	8	3	9383	59	128	3	919	bristleback	0	13	\N	\N	\N
423	1	1299504372	989	9	6	7	0	5872	145	129	45	2088	morphling	0	16	\N	\N	\N
424	11	1299504372	1084	9	5	6	1	6891	100	130	11	3085	invoker	0	14	\N	\N	\N
425	10	1299504372	922	9	1	6	2	3670	14	131	1	508	vengefulspirit	0	9	\N	\N	\N
426	29	1299504372	1032	9	3	8	2	5945	8	132	1	653	bane	0	11	\N	\N	\N
427	1	1299603026	998	9	16	26	8	93355	484	0	6	15	tinker	2891	25	\N	\N	\N
428	31	1299603026	971	9	0	20	15	9106	73	1	1	117	crystal_maiden	0	19	\N	\N	\N
429	10	1299603026	931	9	11	16	8	15956	108	2	1	662	beastmaster	0	25	\N	\N	\N
430	26	1299603026	1006	9	6	17	16	13170	138	3	1	999	spirit_breaker	400	22	\N	\N	\N
431	11	1299603026	1093	9	17	19	9	49466	399	4	26	9088	juggernaut	0	25	\N	\N	\N
432	6	1299603026	1007	-9	15	28	6	32278	392	128	2	1147	storm_spirit	3981	25	\N	\N	\N
433	4	1299603026	962	-9	23	16	6	93127	368	129	10	4874	skeleton_king	5924	25	\N	\N	\N
434	37	1299603026	959	-9	4	16	15	12371	25	130	3	40	lion	0	22	\N	\N	\N
435	29	1299603026	1041	-9	4	22	15	17043	135	131	2	378	magnataur	0	23	\N	\N	\N
436	46	1299603026	1015	-9	7	18	11	15687	73	132	3	640	silencer	0	19	\N	\N	\N
437	46	1299806373	1006	10	27	10	5	46208	208	0	18	4943	sven	0	24	\N	\N	\N
438	29	1299806373	1032	10	5	18	6	10208	16	1	5	1497	lion	0	21	\N	\N	\N
439	28	1299806373	987	10	9	19	5	14972	131	2	1	1060	batrider	0	24	\N	\N	\N
440	38	1299806373	1069	10	1	12	6	5009	65	3	5	923	rubick	800	19	\N	\N	\N
441	10	1299806373	940	10	5	9	12	7662	38	4	1	1602	mirana	0	16	\N	\N	\N
442	1	1299806373	1007	-10	16	5	9	19790	173	128	6	55	phantom_assassin	0	21	\N	\N	\N
443	4	1299806373	953	-10	1	12	9	10731	83	129	2	0	tidehunter	0	16	\N	\N	\N
444	11	1299806373	1102	-10	11	9	12	17964	144	130	20	81	slark	0	22	\N	\N	\N
445	8	1299806373	978	-10	4	6	10	9500	62	131	1	0	witch_doctor	118	14	\N	\N	\N
446	6	1299806373	998	-10	1	7	10	5337	101	132	2	0	sand_king	0	14	\N	\N	\N
447	1	1299931771	997	-9	23	24	13	60621	434	0	4	829	shredder	7728	25	\N	\N	\N
448	13	1299931771	1031	-9	21	36	7	54319	186	1	7	1992	sniper	0	25	\N	\N	\N
449	38	1299931771	1079	-9	5	21	19	14176	50	2	8	521	bane	0	22	\N	\N	\N
450	4	1299931771	943	-9	7	30	17	29023	178	3	0	384	batrider	0	25	\N	\N	\N
451	6	1299931771	988	-9	8	28	11	27214	357	4	2	2730	phantom_assassin	0	25	\N	\N	\N
452	28	1299931771	997	9	11	26	14	32972	204	128	3	1289	rattletrap	0	24	\N	\N	\N
453	8	1299931771	968	9	29	24	7	105611	197	129	0	1918	zuus	0	24	\N	\N	\N
454	10	1299931771	950	9	2	24	12	8392	96	130	7	2319	dazzle	21765	24	\N	\N	\N
455	29	1299931771	1042	9	4	28	19	14997	29	131	1	1480	vengefulspirit	0	22	\N	\N	\N
456	11	1299931771	1092	9	21	24	13	53335	254	132	7	10915	bristleback	0	25	\N	\N	\N
457	29	1300074935	1051	10	7	23	1	11589	23	0	0	1196	lion	0	18	\N	\N	\N
458	1	1300074935	988	10	14	18	2	21546	217	1	10	9751	alchemist	0	20	\N	\N	\N
459	38	1300074935	1070	10	6	13	2	5988	13	2	7	672	bane	0	15	\N	\N	\N
460	28	1300074935	1006	10	8	17	7	14019	80	3	4	1052	necrolyte	3855	16	\N	\N	\N
461	10	1300074935	959	10	9	23	5	14287	43	4	5	1819	spirit_breaker	525	18	\N	\N	\N
462	6	1300074935	979	-10	4	3	7	12786	118	128	13	0	life_stealer	336	16	\N	\N	\N
463	11	1300074935	1101	-10	4	6	10	10432	77	129	4	418	rubick	179	15	\N	\N	\N
464	23	1300074935	1039	-10	2	7	12	8337	8	130	1	0	earthshaker	0	11	\N	\N	\N
465	4	1300074935	934	-10	2	4	10	11661	60	131	2	0	centaur	0	13	\N	\N	\N
466	13	1300074935	1022	-10	4	5	5	9513	98	132	0	0	ursa	388	14	\N	\N	\N
467	6	1300135746	969	-9	6	9	8	15757	131	0	8	346	storm_spirit	1677	23	\N	\N	\N
468	15	1300135746	1039	-9	2	9	10	10885	46	1	2	0	crystal_maiden	0	15	\N	\N	\N
469	28	1300135746	1016	-9	6	7	9	17725	98	2	2	0	doom_bringer	0	20	\N	\N	\N
470	47	1300135746	1000	-9	2	8	6	7283	54	3	1	0	tidehunter	0	17	\N	\N	\N
471	29	1300135746	1061	-9	12	5	8	18475	137	4	12	0	faceless_void	0	20	\N	\N	\N
472	13	1300135746	1012	9	14	6	3	27627	229	128	0	3060	ursa	0	23	\N	\N	\N
473	23	1300135746	1029	9	10	10	4	16802	202	129	27	3508	phantom_assassin	0	23	\N	\N	\N
474	38	1300135746	1080	9	5	19	7	11459	29	130	5	1633	lion	0	19	\N	\N	\N
475	1	1300135746	998	9	10	12	8	19261	209	131	2	609	shredder	2814	24	\N	\N	\N
476	10	1300135746	969	9	2	3	6	6553	55	132	3	417	omniknight	4945	18	\N	\N	\N
477	1	1300226054	1007	-9	5	8	10	9292	137	0	3	281	clinkz	0	17	\N	\N	\N
478	47	1300226054	991	-9	5	3	7	7323	12	1	1	0	ogre_magi	0	13	\N	\N	\N
479	29	1300226054	1052	-9	0	10	11	6939	15	2	3	67	vengefulspirit	0	9	\N	\N	\N
480	15	1300226054	1030	-9	3	7	6	11482	213	3	23	584	medusa	0	19	\N	\N	\N
481	6	1300226054	960	-9	4	4	9	5845	78	4	4	128	storm_spirit	756	17	\N	\N	\N
482	28	1300226054	1007	9	5	21	7	8120	27	128	4	386	disruptor	0	16	\N	\N	\N
483	10	1300226054	978	9	8	18	4	8240	9	129	1	352	lion	0	16	\N	\N	\N
484	23	1300226054	1038	9	3	26	4	14661	161	130	23	5466	phantom_lancer	0	18	\N	\N	\N
485	13	1300226054	1021	9	8	17	1	16336	85	131	5	2415	centaur	0	18	\N	\N	\N
486	43	1300226054	998	9	18	17	3	25262	124	132	3	5742	viper	5559	21	\N	\N	\N
487	3	1301915712	976	-10	6	15	5	13494	164	0	3	651	tidehunter	0	22	\N	\N	\N
488	13	1301915712	1030	-10	4	8	5	10516	239	1	1	1512	ursa	577	22	\N	\N	\N
489	39	1301915712	981	-10	8	21	11	35011	96	2	3	92	zuus	0	20	\N	\N	\N
490	38	1301915712	1089	-10	0	13	14	7380	58	3	8	0	rubick	0	17	\N	\N	\N
491	30	1301915712	1021	-10	13	10	10	23787	193	4	13	1092	slark	0	24	\N	\N	\N
492	8	1301915712	977	10	1	12	3	16365	398	128	8	2419	medusa	0	25	\N	\N	\N
493	34	1301915712	982	10	1	16	13	6548	26	129	21	65	vengefulspirit	0	15	\N	\N	\N
494	1	1301915712	998	10	19	11	4	33652	311	130	10	5647	windrunner	0	25	\N	\N	\N
495	11	1301915712	1091	10	19	16	5	34745	168	131	4	6812	bristleback	0	25	\N	\N	\N
496	29	1301915712	1043	10	5	11	8	4900	44	132	9	487	bane	0	18	\N	\N	\N
497	8	1302136486	987	-11	8	6	8	16720	226	0	1	51	alchemist	0	21	\N	\N	\N
498	37	1302136486	950	-11	2	12	12	4268	25	1	2	0	spirit_breaker	400	15	\N	\N	\N
499	11	1302136486	1101	-11	4	10	13	8187	28	2	2	15	rubick	0	14	\N	\N	\N
500	1	1302136486	1008	-11	11	8	9	14557	214	3	14	3071	morphling	0	23	\N	\N	\N
501	13	1302136486	1020	-11	8	8	10	23988	169	4	1	726	bristleback	0	20	\N	\N	\N
502	15	1302136486	1021	11	17	18	5	32502	203	128	13	5030	phantom_assassin	0	25	\N	\N	\N
503	30	1302136486	1011	11	7	21	8	12711	36	129	5	952	skywrath_mage	0	19	\N	\N	\N
504	3	1302136486	966	11	14	17	7	24222	149	130	18	9904	viper	0	23	\N	\N	\N
505	10	1302136486	987	11	6	17	6	12990	79	131	2	1173	tidehunter	3234	21	\N	\N	\N
506	29	1302136486	1053	11	8	16	7	13159	41	132	1	1676	lion	0	20	\N	\N	\N
507	10	1302338808	998	-10	5	11	11	7749	66	0	2	139	dazzle	6548	17	\N	\N	\N
508	8	1302338808	976	-10	5	17	9	21516	240	1	2	0	spectre	0	22	\N	\N	\N
509	30	1302338808	1022	-10	10	13	11	14288	65	2	18	157	skywrath_mage	0	19	\N	\N	\N
510	11	1302338808	1090	-10	10	17	8	17994	250	3	8	1161	furion	0	21	\N	\N	\N
511	13	1302338808	1009	-10	13	14	4	19337	113	4	2	0	nyx_assassin	0	20	\N	\N	\N
512	29	1302338808	1064	10	1	20	11	6309	45	128	1	456	vengefulspirit	0	18	\N	\N	\N
513	37	1302338808	939	10	5	14	12	7599	40	129	6	4400	shadow_shaman	0	16	\N	\N	\N
514	38	1302338808	1079	10	7	21	6	25979	162	130	14	4131	centaur	0	23	\N	\N	\N
515	46	1302338808	1016	10	14	8	8	22038	272	131	11	5576	sven	0	24	\N	\N	\N
516	1	1302338808	997	10	15	15	6	33300	377	132	11	913	tinker	0	25	\N	\N	\N
517	37	1302544135	949	-12	1	5	9	5729	16	0	0	0	lina	0	11	\N	\N	\N
518	29	1302544135	1074	-12	2	7	8	5866	21	1	3	48	bane	0	12	\N	\N	\N
519	10	1302544135	988	-12	0	3	3	3958	30	2	0	0	omniknight	6152	13	\N	\N	\N
520	1	1302544135	1007	-12	6	6	3	12866	167	3	7	30	windrunner	0	17	\N	\N	\N
521	15	1302544135	1032	-12	6	6	6	17349	144	4	16	0	phantom_assassin	0	15	\N	\N	\N
522	4	1302544135	924	12	2	11	4	14845	138	128	3	1935	leshrac	1500	17	\N	\N	\N
523	30	1302544135	1012	12	2	8	3	5292	49	129	16	430	rubick	1710	13	\N	\N	\N
524	3	1302544135	977	12	11	7	1	13025	265	130	23	4267	juggernaut	0	20	\N	\N	\N
525	13	1302544135	999	12	8	12	4	13832	85	131	2	935	bristleback	0	17	\N	\N	\N
526	38	1302544135	1089	12	5	13	4	6714	17	132	5	773	dazzle	6290	14	\N	\N	\N
527	1	1302689870	995	-9	5	6	6	16991	122	0	1	0	shredder	0	17	\N	\N	\N
528	29	1302689870	1062	-9	3	6	8	7131	7	1	1	0	lion	0	11	\N	\N	\N
529	15	1302689870	1020	-9	1	4	5	7923	114	2	2	192	slark	0	14	\N	\N	\N
530	10	1302689870	976	-9	3	5	8	6144	27	3	1	0	omniknight	4477	10	\N	\N	\N
531	37	1302689870	937	-9	1	9	10	7035	10	4	1	0	crystal_maiden	0	10	\N	\N	\N
532	8	1302689870	966	9	10	14	1	20745	99	128	0	1388	zuus	0	16	\N	\N	\N
533	38	1302689870	1101	9	4	15	4	6024	37	129	7	1475	dazzle	11138	13	\N	\N	\N
534	4	1302689870	936	9	13	6	4	14595	141	130	12	8402	troll_warlord	0	17	\N	\N	\N
535	13	1302689870	1011	9	2	10	3	5774	26	131	9	1154	bane	0	13	\N	\N	\N
536	17	1302689870	979	9	6	15	2	10909	65	132	2	3972	bristleback	0	15	\N	\N	\N
537	17	1302859320	988	-9	2	9	11	7626	33	0	3	317	lion	577	18	\N	\N	\N
538	37	1302859320	928	-9	3	7	10	7020	111	1	10	1834	clinkz	0	20	\N	\N	\N
539	10	1302859320	967	-9	17	8	5	43958	74	2	2	566	pudge	0	20	\N	\N	\N
540	13	1302859320	1020	-9	5	9	9	16763	304	3	16	684	juggernaut	0	21	\N	\N	\N
541	29	1302859320	1053	-9	2	10	9	9423	29	4	1	241	omniknight	5046	18	\N	\N	\N
542	6	1302859320	951	9	11	14	4	15970	265	128	1	3338	axe	0	24	\N	\N	\N
543	8	1302859320	975	9	10	19	8	28123	101	129	6	3189	witch_doctor	3050	21	\N	\N	\N
544	22	1302859320	1021	9	3	15	6	20439	217	130	9	4776	faceless_void	0	21	\N	\N	\N
545	30	1302859320	1024	9	5	8	7	10818	29	131	18	499	skywrath_mage	0	17	\N	\N	\N
546	1	1302859320	986	9	14	18	4	32224	257	132	1	1298	shredder	0	25	\N	\N	\N
547	37	1302973275	919	9	1	15	11	6755	14	0	3	703	skywrath_mage	0	14	\N	\N	\N
548	8	1302973275	984	9	12	12	10	25637	197	1	4	6682	troll_warlord	0	23	\N	\N	\N
549	47	1302973275	982	9	3	20	7	11985	103	2	1	1083	bristleback	0	19	\N	\N	\N
550	13	1302973275	1011	9	21	4	3	36194	270	3	14	4114	phantom_assassin	0	25	\N	\N	\N
551	29	1302973275	1044	9	0	25	6	11371	26	4	0	1435	vengefulspirit	0	20	\N	\N	\N
552	1	1302973275	995	-9	11	8	4	24917	298	128	13	2571	morphling	0	22	\N	\N	\N
553	10	1302973275	958	-9	2	16	11	8680	63	129	1	3628	shadow_shaman	0	16	\N	\N	\N
554	17	1302973275	979	-9	1	7	7	13617	121	130	3	698	centaur	0	17	\N	\N	\N
555	12	1302973275	990	-9	7	12	8	8454	58	131	6	23	spirit_breaker	0	17	\N	\N	\N
556	28	1302973275	1016	-9	15	13	8	25710	171	132	3	549	necrolyte	4691	22	\N	\N	\N
557	10	1303052426	949	10	13	22	8	20982	114	0	1	5650	shadow_shaman	0	25	\N	\N	\N
558	8	1303052426	993	10	12	29	13	43017	126	1	3	31	zuus	0	22	\N	\N	\N
559	15	1303052426	1011	10	23	25	9	53374	310	2	11	5717	gyrocopter	0	25	\N	\N	\N
560	11	1303052426	1080	10	9	26	11	20903	82	3	2	853	ancient_apparition	0	24	\N	\N	\N
561	6	1303052426	960	10	8	26	9	20412	194	4	9	3066	bristleback	0	25	\N	\N	\N
562	1	1303052426	986	-10	18	12	10	33418	312	128	2	29	shredder	0	25	\N	\N	\N
563	28	1303052426	1007	-10	23	12	15	45535	162	129	6	460	rattletrap	0	25	\N	\N	\N
564	29	1303052426	1053	-10	1	11	14	6551	34	130	2	325	dazzle	4859	21	\N	\N	\N
565	37	1303052426	928	-10	1	11	17	7843	30	131	12	220	vengefulspirit	0	15	\N	\N	\N
566	13	1303052426	1020	-10	7	5	10	13564	311	132	5	489	drow_ranger	0	25	\N	\N	\N
567	11	1303139272	1090	-9	10	9	7	23657	207	0	9	0	ember_spirit	0	21	\N	\N	\N
568	15	1303139272	1021	-9	6	8	6	15831	296	1	14	1197	weaver	0	22	\N	\N	\N
569	37	1303139272	918	-9	2	13	11	6514	20	2	4	94	vengefulspirit	0	14	\N	\N	\N
570	39	1303139272	971	-9	2	6	15	4776	12	3	4	65	bane	0	13	\N	\N	\N
571	1	1303139272	976	-9	6	8	5	17419	208	4	0	71	shredder	0	22	\N	\N	\N
572	13	1303139272	1010	9	8	11	2	16825	342	128	26	8124	juggernaut	0	24	\N	\N	\N
573	10	1303139272	959	9	9	16	4	15394	120	129	0	2059	mirana	0	19	\N	\N	\N
574	8	1303139272	1003	9	13	11	6	22084	216	130	3	9180	clinkz	0	25	\N	\N	\N
575	29	1303139272	1043	9	5	12	9	8594	39	131	8	1397	jakiro	0	21	\N	\N	\N
576	6	1303139272	970	9	9	15	6	19984	64	132	0	506	nyx_assassin	0	20	\N	\N	\N
577	12	1305106917	981	-11	3	16	13	9689	58	0	3	212	vengefulspirit	1222	21	\N	\N	\N
578	38	1305106917	1110	-11	4	16	9	15247	175	1	5	425	tidehunter	0	23	\N	\N	\N
579	39	1305106917	962	-11	12	9	8	25829	239	2	14	2432	templar_assassin	0	25	\N	\N	\N
580	48	1305106917	1000	-11	4	18	9	16191	107	3	3	215	ogre_magi	2832	21	\N	\N	\N
581	13	1305106917	1019	-11	18	12	4	39472	325	4	15	1683	sniper	0	25	\N	\N	\N
582	1	1305106917	967	11	10	21	6	46188	476	128	3	130	tinker	0	25	\N	\N	\N
583	46	1305106917	1026	11	4	20	13	24854	223	129	11	5633	bristleback	0	24	\N	\N	\N
584	15	1305106917	1012	11	5	14	8	17609	364	130	14	9732	lycan	772	25	\N	\N	\N
585	3	1305106917	989	11	14	11	9	22437	194	131	5	1484	witch_doctor	5384	24	\N	\N	\N
586	29	1305106917	1052	11	10	13	6	15767	62	132	2	1638	lion	0	23	\N	\N	\N
587	15	1305328543	1023	10	8	14	5	19800	212	0	4	5100	phantom_assassin	0	20	\N	\N	\N
588	46	1305328543	1037	10	5	8	6	8045	39	1	2	640	witch_doctor	5475	15	\N	\N	\N
589	3	1305328543	1000	10	2	15	5	10381	102	2	3	3417	magnataur	0	20	\N	\N	\N
590	10	1305328543	968	10	2	8	5	3983	25	3	1	1159	omniknight	6995	18	\N	\N	\N
591	1	1305328543	978	10	9	15	2	34155	291	4	9	138	tinker	1602	24	\N	\N	\N
592	6	1305328543	979	-10	8	7	8	18004	63	128	9	124	nyx_assassin	0	17	\N	\N	\N
593	38	1305328543	1099	-10	7	8	4	18585	234	129	22	546	bristleback	0	19	\N	\N	\N
594	39	1305328543	951	-10	3	3	6	4366	94	130	5	51	lion	0	16	\N	\N	\N
595	13	1305328543	1008	-10	3	2	2	9056	262	131	35	1087	troll_warlord	0	21	\N	\N	\N
596	12	1305328543	970	-10	1	5	6	5130	34	132	11	0	vengefulspirit	1096	14	\N	\N	\N
597	8	1305477778	1012	9	9	14	7	23367	125	0	1	1075	earthshaker	0	21	\N	\N	\N
598	1	1305477778	988	9	19	9	9	34367	299	1	5	10609	windrunner	0	25	\N	\N	\N
599	11	1305477778	1081	9	7	12	7	19192	332	2	21	6699	juggernaut	0	25	\N	\N	\N
600	12	1305477778	960	9	1	11	8	19655	50	3	0	0	ancient_apparition	1800	16	\N	\N	\N
601	4	1305477778	945	9	3	16	8	22679	88	4	2	332	nyx_assassin	0	23	\N	\N	\N
602	3	1305477778	1010	-9	16	11	7	28127	219	128	16	2056	invoker	0	25	\N	\N	\N
603	37	1305477778	909	-9	2	9	12	6363	71	129	9	10641	shadow_shaman	0	15	\N	\N	\N
604	13	1305477778	998	-9	6	11	6	12560	125	130	7	480	omniknight	11209	19	\N	\N	\N
605	10	1305477778	978	-9	7	13	8	12849	76	131	1	1606	mirana	0	18	\N	\N	\N
606	38	1305477778	1089	-9	8	8	8	22688	252	132	21	2481	skeleton_king	4704	24	\N	\N	\N
617	17	1305755581	970	-10	1	4	8	11919	93	0	7	136	centaur	0	15	\N	\N	\N
618	1	1305755581	1006	-10	8	5	8	18527	155	1	1	293	shredder	437	18	\N	\N	\N
619	38	1305755581	1089	-10	6	5	7	4076	46	2	3	0	dazzle	8315	11	\N	\N	\N
620	49	1305755581	991	-10	4	11	12	10944	31	3	2	110	ogre_magi	0	14	\N	\N	\N
621	12	1305755581	960	-10	1	6	8	2652	126	4	2	53	faceless_void	0	16	\N	\N	\N
622	29	1305755581	1063	10	9	24	3	10151	21	128	1	5331	jakiro	2250	16	\N	\N	\N
623	8	1305755581	1030	10	11	20	4	33549	136	129	2	859	zuus	0	18	\N	\N	\N
624	10	1305755581	978	10	4	15	4	5999	53	130	2	1568	mirana	0	14	\N	\N	\N
625	4	1305755581	963	10	6	26	8	18860	113	131	3	1914	bristleback	0	19	\N	\N	\N
626	13	1305755581	980	10	12	15	2	16336	171	132	13	4114	sniper	0	17	\N	\N	\N
627	8	1305832137	1040	10	7	13	10	13184	119	0	0	3344	death_prophet	0	20	\N	\N	\N
628	1	1305832137	996	10	5	19	7	13495	279	1	2	2302	storm_spirit	1096	25	\N	\N	\N
629	10	1305832137	988	10	1	11	6	4277	50	2	0	830	mirana	0	15	\N	\N	\N
630	12	1305832137	950	10	4	6	11	2084	19	3	3	924	shadow_shaman	0	11	\N	\N	\N
631	11	1305832137	1081	10	17	13	3	27545	230	4	38	7042	phantom_assassin	0	25	\N	\N	\N
632	15	1305832137	1033	-10	8	6	8	12104	217	128	17	85	obsidian_destroyer	0	21	\N	\N	\N
633	4	1305832137	973	-10	13	7	13	27508	78	129	2	145	rattletrap	0	19	\N	\N	\N
634	38	1305832137	1079	-10	6	14	6	8181	38	130	1	0	lion	0	15	\N	\N	\N
635	13	1305832137	990	-10	3	16	2	18356	241	131	43	497	sniper	0	19	\N	\N	\N
636	49	1305832137	981	-10	7	12	7	9489	45	132	2	126	witch_doctor	1915	13	\N	\N	\N
607	49	1305637233	1000	-9	5	9	9	17206	78	0	0	434	rattletrap	0	15	\N	\N	\N
608	12	1305637233	969	-9	6	8	6	11950	116	1	2	0	enigma	0	15	\N	\N	\N
609	13	1305637233	989	-9	4	7	5	7445	95	2	2	0	vengefulspirit	0	18	\N	\N	\N
610	6	1305637233	969	-9	1	3	11	5390	124	3	14	0	troll_warlord	0	13	\N	\N	\N
611	11	1305637233	1090	-9	7	13	10	21834	101	4	13	51	ember_spirit	0	19	\N	\N	\N
612	8	1305637233	1021	9	14	4	2	21545	295	128	2	8704	sven	0	25	\N	\N	\N
613	38	1305637233	1080	9	4	12	7	6685	50	129	9	637	dazzle	13115	16	\N	\N	\N
614	4	1305637233	954	9	3	21	3	13649	85	130	1	779	tidehunter	0	19	\N	\N	\N
615	10	1305637233	969	9	4	5	6	5532	42	131	6	648	lion	0	14	\N	\N	\N
616	1	1305637233	997	9	15	12	5	25089	161	132	10	6159	windrunner	0	23	\N	\N	\N
637	29	1305901701	1073	10	1	22	3	6014	19	0	0	1469	vengefulspirit	0	17	\N	\N	\N
638	8	1305901701	1050	10	7	20	9	26074	107	1	1	1696	zuus	0	18	\N	\N	\N
639	1	1305901701	1006	10	7	11	4	15090	123	2	0	857	shredder	0	19	\N	\N	\N
640	4	1305901701	963	10	9	15	5	39612	182	3	6	2950	skeleton_king	2849	21	\N	\N	\N
641	13	1305901701	980	10	11	8	1	12740	172	4	0	3649	ursa	0	22	\N	\N	\N
642	15	1305901701	1023	-10	9	2	5	18083	398	128	29	116	antimage	0	23	\N	\N	\N
643	37	1305901701	900	-10	0	9	10	8364	81	129	3	0	bristleback	0	15	\N	\N	\N
644	10	1305901701	998	-10	3	7	9	6876	8	130	3	0	pudge	400	11	\N	\N	\N
645	11	1305901701	1091	-10	7	9	5	20849	149	131	13	501	viper	2115	19	\N	\N	\N
646	38	1305901701	1069	-10	2	7	6	9297	50	132	7	75	rubick	0	15	\N	\N	\N
647	5	1307217153	991	10	5	6	0	11710	204	0	1	3129	broodmother	0	20	\N	\N	\N
648	13	1307217153	990	10	7	9	2	9034	195	1	1	102	axe	0	21	\N	\N	\N
649	15	1307217153	1013	10	4	11	4	12337	196	2	7	3835	sniper	0	19	\N	\N	\N
650	1	1307217153	1016	10	18	7	2	18193	99	3	11	1770	lina	0	20	\N	\N	\N
651	31	1307217153	980	10	2	6	4	1579	48	4	3	2412	shadow_shaman	0	14	\N	\N	\N
652	8	1307217153	1060	-10	4	4	8	6459	65	128	2	463	clinkz	0	17	\N	\N	\N
653	33	1307217153	989	-10	1	5	11	4359	25	129	5	8	mirana	0	11	\N	\N	\N
654	17	1307217153	960	-10	4	3	6	7995	118	130	0	78	bristleback	0	15	\N	\N	\N
655	47	1307217153	991	-10	1	5	6	4287	25	131	0	0	lion	0	13	\N	\N	\N
656	50	1307217153	1000	-10	2	0	5	4065	161	132	12	618	troll_warlord	0	16	\N	\N	\N
657	13	1307683967	1000	9	1	3	1	931	147	0	0	517	naga_siren	268	13	\N	\N	\N
658	15	1307683967	1023	9	7	2	1	6228	161	1	23	4237	juggernaut	0	18	\N	\N	\N
659	38	1307683967	1059	9	2	15	3	6545	24	2	0	196	earthshaker	0	13	\N	\N	\N
660	33	1307683967	979	9	8	10	4	16141	64	3	4	1056	venomancer	0	13	\N	\N	\N
661	1	1307683967	1026	9	9	7	0	17656	120	4	7	310	zuus	0	17	\N	\N	\N
662	5	1307683967	1001	-9	0	3	6	5699	32	128	0	0	nyx_assassin	0	12	\N	\N	\N
663	8	1307683967	1050	-9	3	2	6	6842	49	129	2	0	witch_doctor	348	13	\N	\N	\N
664	6	1307683967	960	-9	4	2	3	6343	99	130	0	0	axe	0	14	\N	\N	\N
665	11	1307683967	1081	-9	2	1	6	4164	120	131	13	0	terrorblade	0	13	\N	\N	\N
666	10	1307683967	988	-9	0	3	7	2074	15	132	3	0	omniknight	3174	9	\N	\N	\N
667	38	1307807317	1068	-10	6	9	9	12784	47	0	1	343	leshrac	0	13	\N	\N	\N
668	31	1307807317	990	-10	1	8	7	5807	126	1	4	0	alchemist	0	16	\N	\N	\N
669	3	1307807317	1001	-10	5	8	6	14321	102	2	1	362	doom_bringer	0	15	\N	\N	\N
670	15	1307807317	1032	-10	4	4	10	6950	74	3	0	2	shadow_demon	0	11	\N	\N	\N
671	10	1307807317	979	-10	8	4	10	12610	65	4	1	300	beastmaster	0	14	\N	\N	\N
672	1	1307807317	1035	10	8	18	4	21907	238	128	9	7299	spectre	0	22	\N	\N	\N
673	5	1307807317	992	10	0	21	6	11858	112	129	0	1631	dark_seer	4348	17	\N	\N	\N
674	8	1307807317	1041	10	13	17	5	32879	126	130	5	1572	zuus	0	19	\N	\N	\N
675	33	1307807317	988	10	7	14	7	11958	29	131	13	1035	ancient_apparition	0	17	\N	\N	\N
676	13	1307807317	1009	10	13	12	3	14977	143	132	0	2800	axe	0	21	\N	\N	\N
677	38	1308040018	1058	9	3	16	6	12151	66	0	3	171	earthshaker	0	15	\N	\N	\N
678	5	1308040018	1002	9	6	10	0	13701	218	1	7	4047	windrunner	0	24	\N	\N	\N
679	3	1308040018	991	9	17	10	4	22891	307	2	10	1625	storm_spirit	0	25	\N	\N	\N
680	30	1308040018	1033	9	9	7	3	23232	306	3	18	3781	phantom_lancer	0	25	\N	\N	\N
681	29	1308040018	1083	9	9	10	8	18033	51	4	4	1596	pugna	3768	17	\N	\N	\N
682	1	1308040018	1045	-9	6	3	5	10754	326	128	17	0	juggernaut	0	25	\N	\N	\N
683	8	1308040018	1051	-9	6	7	10	43203	160	129	1	0	zuus	0	18	\N	\N	\N
684	32	1308040018	1010	-9	0	7	14	3949	27	130	1	0	vengefulspirit	0	12	\N	\N	\N
685	11	1308040018	1072	-9	8	5	7	17617	189	131	2	0	bristleback	0	22	\N	\N	\N
686	25	1308040018	988	-9	1	2	9	2793	16	132	6	0	skywrath_mage	0	11	\N	\N	\N
687	1	1308149679	1036	-10	7	3	5	9730	221	0	47	431	morphling	0	21	\N	\N	\N
688	4	1308149679	973	-10	1	9	10	8085	78	1	1	0	tidehunter	0	18	\N	\N	\N
689	11	1308149679	1063	-10	16	7	6	29642	204	2	22	859	sniper	0	21	\N	\N	\N
690	32	1308149679	1001	-10	2	7	10	9181	99	3	0	90	axe	0	15	\N	\N	\N
691	30	1308149679	1042	-10	1	10	11	8460	23	4	3	0	skywrath_mage	0	13	\N	\N	\N
692	5	1308149679	1011	10	11	5	5	16205	149	128	12	9436	clinkz	0	21	\N	\N	\N
693	10	1308149679	969	10	1	11	5	6105	27	129	3	1136	mirana	0	14	\N	\N	\N
694	8	1308149679	1042	10	5	10	7	14645	96	130	6	2385	warlock	3548	17	\N	\N	\N
695	29	1308149679	1092	10	4	15	7	10641	26	131	2	1188	lion	0	18	\N	\N	\N
696	3	1308149679	1000	10	21	12	3	26783	213	132	25	4147	life_stealer	817	24	\N	\N	\N
697	8	1308225703	1052	9	9	25	9	23445	163	0	0	1427	axe	0	25	\N	\N	\N
698	11	1308225703	1053	9	9	15	9	21477	238	1	16	11045	troll_warlord	0	25	\N	\N	\N
699	1	1308225703	1026	9	9	8	13	24313	170	2	1	1012	shredder	0	22	\N	\N	\N
700	13	1308225703	1019	9	15	22	8	48399	303	3	14	2617	sniper	0	25	\N	\N	\N
701	10	1308225703	979	9	1	11	12	7264	57	4	1	3854	jakiro	0	16	\N	\N	\N
702	4	1308225703	963	-9	6	19	15	23877	157	128	1	1549	bristleback	0	23	\N	\N	\N
703	3	1308225703	1010	-9	11	15	7	32559	321	129	10	4765	queenofpain	0	25	\N	\N	\N
704	29	1308225703	1102	-9	7	13	11	10839	43	130	1	489	lion	0	22	\N	\N	\N
705	30	1308225703	1032	-9	14	15	6	36544	319	131	27	4106	phantom_assassin	0	25	\N	\N	\N
706	5	1308225703	1021	-9	10	13	6	21037	40	132	1	798	skywrath_mage	5085	21	\N	\N	\N
707	6	1308321231	951	-10	6	6	13	7294	22	0	15	0	lion	0	19	\N	\N	\N
708	10	1308321231	988	-10	1	13	11	12383	127	1	0	417	dark_seer	0	18	\N	\N	\N
709	30	1308321231	1023	-10	3	8	8	23726	146	2	15	102	chaos_knight	0	19	\N	\N	\N
710	51	1308321231	1000	-10	4	7	7	5695	18	3	2	11	vengefulspirit	1000	16	\N	\N	\N
711	8	1308321231	1061	-10	7	6	8	14975	130	4	2	310	furion	0	19	\N	\N	\N
712	1	1308321231	1035	10	24	7	3	27472	161	128	15	4958	sniper	0	24	\N	\N	\N
713	4	1308321231	954	10	5	19	6	12287	91	129	2	497	phoenix	1158	18	\N	\N	\N
714	13	1308321231	1028	10	9	8	3	14701	187	130	0	2925	ursa	0	24	\N	\N	\N
715	3	1308321231	1001	10	6	9	7	10665	208	131	9	983	juggernaut	0	21	\N	\N	\N
716	50	1308321231	990	10	3	11	3	5158	42	132	3	765	dazzle	2794	16	\N	\N	\N
717	8	1310483122	1051	-10	15	9	10	34978	111	0	1	0	zuus	0	20	\N	\N	\N
718	38	1310483122	1067	-10	3	12	10	10072	85	1	3	217	earthshaker	0	18	\N	\N	\N
719	5	1310483122	1012	-10	3	14	7	7330	29	2	1	0	undying	3972	17	\N	\N	\N
720	26	1310483122	1015	-10	5	11	9	10587	62	3	4	57	ancient_apparition	800	15	\N	\N	\N
721	10	1310483122	978	-10	4	9	9	7221	166	4	7	143	faceless_void	0	19	\N	\N	\N
722	4	1310483122	964	10	11	17	10	28262	152	128	2	3453	bristleback	0	23	\N	\N	\N
723	1	1310483122	1045	10	12	9	6	19502	201	129	7	5330	windrunner	0	22	\N	\N	\N
724	13	1310483122	1038	10	11	12	3	23153	298	130	45	4337	sniper	0	23	\N	\N	\N
725	30	1310483122	1013	10	3	16	7	6021	50	131	8	510	vengefulspirit	0	17	\N	\N	\N
726	11	1310483122	1062	10	7	12	7	10002	87	132	3	2202	silencer	0	18	\N	\N	\N
727	1	1310564249	1055	-9	13	9	7	23787	203	0	7	491	windrunner	0	22	\N	\N	\N
728	5	1310564249	1002	-9	3	14	3	13583	125	1	0	0	doom_bringer	0	19	\N	\N	\N
729	13	1310564249	1048	-9	5	15	8	16773	174	2	17	0	sniper	0	18	\N	\N	\N
730	4	1310564249	974	-9	4	7	7	15641	176	3	2	132	bristleback	0	20	\N	\N	\N
731	49	1310564249	971	-9	1	1	1	1566	5	4	0	0	vengefulspirit	0	4	\N	\N	\N
732	33	1310564249	998	9	5	7	6	11690	112	128	10	1555	undying	2364	18	\N	\N	\N
733	10	1310564249	968	9	6	8	8	18505	48	129	2	1408	pudge	0	17	\N	\N	\N
734	38	1310564249	1057	9	0	17	6	15216	116	130	3	1412	earthshaker	0	18	\N	\N	\N
735	30	1310564249	1023	9	9	4	4	14398	366	131	30	14114	antimage	166	24	\N	\N	\N
736	26	1310564249	1005	9	4	5	5	7989	60	132	4	480	lion	0	17	\N	\N	\N
737	1	1312522817	1046	10	22	15	6	25816	157	0	11	4212	storm_spirit	0	24	\N	\N	\N
738	38	1312522817	1066	10	10	16	4	26983	215	1	41	5359	slark	0	23	\N	\N	\N
739	42	1312522817	989	10	3	14	8	5150	34	2	6	1064	dazzle	9328	15	\N	\N	\N
740	26	1312522817	1014	10	9	11	6	11932	77	3	0	2225	spirit_breaker	1187	18	\N	\N	\N
741	17	1312522817	950	10	6	12	5	10152	94	4	0	5220	bristleback	0	19	\N	\N	\N
742	27	1312522817	1005	-10	3	10	12	9224	23	128	9	76	skywrath_mage	2000	14	\N	\N	\N
743	13	1312522817	1039	-10	10	8	5	21716	180	129	40	285	sniper	0	21	\N	\N	\N
744	39	1312522817	941	-10	4	9	10	6376	40	130	0	94	vengefulspirit	0	14	\N	\N	\N
745	3	1312522817	1011	-10	4	13	14	23532	61	131	1	46	rattletrap	0	16	\N	\N	\N
746	11	1312522817	1072	-10	6	11	9	14398	116	132	20	60	puck	0	20	\N	\N	\N
747	1	1312644118	1056	9	16	17	5	26133	180	0	7	4920	sniper	0	21	\N	\N	\N
748	35	1312644118	1001	9	3	9	4	4025	8	1	2	924	lion	0	15	\N	\N	\N
749	17	1312644118	960	9	7	16	6	12208	92	2	0	4579	bristleback	0	18	\N	\N	\N
750	38	1312644118	1076	9	14	17	1	23951	204	3	45	5293	slark	0	21	\N	\N	\N
751	26	1312644118	1024	9	5	18	5	9191	75	4	0	1150	ogre_magi	0	18	\N	\N	\N
752	8	1312644118	1041	-9	1	3	10	16239	83	128	1	49	centaur	0	13	\N	\N	\N
753	13	1312644118	1029	-9	8	3	3	13967	192	129	12	0	doom_bringer	0	20	\N	\N	\N
754	11	1312644118	1062	-9	9	1	9	16743	101	130	7	0	silencer	0	17	\N	\N	\N
755	3	1312644118	1001	-9	0	8	10	4681	28	131	3	0	shadow_demon	0	11	\N	\N	\N
756	10	1312644118	977	-9	1	9	13	4334	29	132	0	0	mirana	0	15	\N	\N	\N
757	26	1312772811	1033	-10	5	6	6	8606	66	0	1	108	ogre_magi	0	15	\N	\N	\N
758	10	1312772811	968	-10	10	7	9	14306	56	1	0	511	clinkz	0	17	\N	\N	\N
759	17	1312772811	969	-10	5	8	7	14892	119	2	3	37	skeleton_king	2555	17	\N	\N	\N
760	13	1312772811	1020	-10	5	6	8	11121	148	3	5	0	troll_warlord	0	18	\N	\N	\N
761	52	1312772811	1000	-10	4	10	13	7638	18	4	4	28	disruptor	0	12	\N	\N	\N
762	8	1312772811	1032	10	3	9	4	12136	305	128	6	5329	sven	0	21	\N	\N	\N
763	1	1312772811	1065	10	22	14	3	41661	196	129	14	7465	sniper	0	25	\N	\N	\N
764	35	1312772811	1010	10	4	4	6	4375	17	130	0	107	lich	1370	13	\N	\N	\N
765	20	1312772811	979	10	11	12	6	23587	162	131	4	2849	bristleback	0	20	\N	\N	\N
766	37	1312772811	890	10	0	13	10	5710	9	132	6	234	lion	0	15	\N	\N	\N
767	20	1312852600	989	-10	3	5	6	8130	78	0	4	0	batrider	0	14	\N	\N	\N
768	4	1312852600	965	-10	3	10	7	10485	218	1	4	233	troll_warlord	0	19	\N	\N	\N
769	11	1312852600	1053	-10	7	10	7	15317	100	2	5	106	ancient_apparition	0	17	\N	\N	\N
770	26	1312852600	1023	-10	5	4	7	4850	65	3	2	124	lion	0	15	\N	\N	\N
771	13	1312852600	1010	-10	4	5	3	6908	165	4	0	260	ursa	0	18	\N	\N	\N
772	8	1312852600	1042	10	7	8	1	10327	268	128	2	7126	chaos_knight	0	21	\N	\N	\N
773	37	1312852600	900	10	1	18	7	6798	15	129	7	703	venomancer	0	13	\N	\N	\N
774	35	1312852600	1020	10	2	8	4	4761	17	130	6	315	ogre_magi	0	15	\N	\N	\N
775	2	1312852600	1000	10	2	15	7	10528	129	131	2	1041	bristleback	0	19	\N	\N	\N
776	1	1312852600	1075	10	18	7	3	27980	305	132	11	6958	sniper	0	25	\N	\N	\N
777	13	1314178938	1000	9	7	7	5	5746	45	0	0	148	lion	400	15	\N	\N	\N
778	35	1314178938	1030	9	1	16	6	5497	27	1	1	884	ogre_magi	0	14	\N	\N	\N
779	10	1314178938	958	9	10	20	5	14618	79	2	0	3515	beastmaster	0	20	\N	\N	\N
780	38	1314178938	1085	9	12	12	3	19369	208	3	36	3891	slark	0	22	\N	\N	\N
781	11	1314178938	1043	9	14	17	6	18128	159	4	12	3450	storm_spirit	0	22	\N	\N	\N
782	4	1314178938	955	-9	4	9	8	9630	56	128	1	0	phoenix	375	13	\N	\N	\N
783	1	1314178938	1085	-9	14	5	5	25188	184	129	3	509	kunkka	0	21	\N	\N	\N
784	21	1314178938	980	-9	1	5	9	4573	77	130	21	216	phantom_assassin	0	16	\N	\N	\N
785	53	1314178938	1000	-9	1	6	10	7715	144	131	1	129	axe	0	17	\N	\N	\N
786	29	1314178938	1093	-9	3	11	13	9902	11	132	1	133	skywrath_mage	0	11	\N	\N	\N
787	53	1314364419	991	-10	1	0	10	5277	37	0	1	0	batrider	0	9	\N	\N	\N
788	13	1314364419	1009	-10	0	0	3	2797	64	1	0	0	ursa	0	9	\N	\N	\N
789	38	1314364419	1094	-10	0	0	5	2199	69	2	6	0	brewmaster	0	11	\N	\N	\N
790	10	1314364419	967	-10	2	1	3	4088	94	3	8	0	life_stealer	47	13	\N	\N	\N
791	11	1314364419	1052	-10	1	0	4	2141	8	4	2	0	vengefulspirit	0	6	\N	\N	\N
792	4	1314364419	946	10	10	4	0	9297	95	128	7	675	skeleton_king	554	16	\N	\N	\N
793	1	1314364419	1076	10	8	8	1	13783	103	129	7	1076	sniper	0	16	\N	\N	\N
794	29	1314364419	1084	10	0	5	1	9659	46	130	0	153	centaur	0	11	\N	\N	\N
795	45	1314364419	1010	10	1	3	2	1765	9	131	0	386	shadow_shaman	0	7	\N	\N	\N
796	3	1314364419	992	10	6	5	0	4937	127	132	0	212	axe	0	14	\N	\N	\N
797	1	1314732543	1086	-9	6	12	9	15723	127	0	9	46	sniper	0	16	\N	\N	\N
798	31	1314732543	980	-9	6	6	6	7128	125	1	0	0	axe	0	16	\N	\N	\N
799	17	1314732543	959	-9	6	6	4	8839	114	2	9	217	skeleton_king	608	18	\N	\N	\N
800	55	1314732543	1000	-9	2	6	10	3808	16	3	5	0	ogre_magi	0	12	\N	\N	\N
801	26	1314732543	1013	-9	4	7	8	6789	62	4	2	0	spirit_breaker	0	16	\N	\N	\N
802	13	1314732543	999	9	2	12	4	5883	102	128	1	180	doom_bringer	0	16	\N	\N	\N
803	46	1314732543	1047	9	15	9	1	26032	198	129	44	1621	faceless_void	0	22	\N	\N	\N
804	11	1314732543	1042	9	9	11	5	12176	120	130	20	815	viper	0	21	\N	\N	\N
805	10	1314732543	957	9	5	10	8	15710	67	131	7	487	venomancer	0	15	\N	\N	\N
806	54	1314732543	1000	9	4	9	7	6657	16	132	2	212	bane	0	15	\N	\N	\N
807	13	1314848809	1008	-9	1	1	6	2705	106	0	9	0	faceless_void	0	11	\N	\N	\N
808	10	1314848809	966	-9	2	3	8	10251	64	1	0	40	beastmaster	0	13	\N	\N	\N
809	31	1314848809	971	-9	1	3	3	3444	7	2	8	0	omniknight	990	8	\N	\N	\N
810	11	1314848809	1051	-9	3	2	6	9163	96	3	5	64	storm_spirit	0	14	\N	\N	\N
811	55	1314848809	991	-9	1	4	8	3665	5	4	13	79	bane	0	10	\N	\N	\N
812	1	1314848809	1077	9	8	11	1	11280	126	128	10	2471	sniper	0	15	\N	\N	\N
813	5	1314848809	993	9	5	8	2	4937	16	129	5	58	lion	0	11	\N	\N	\N
814	17	1314848809	950	9	4	7	1	8653	70	130	1	1653	bristleback	0	16	\N	\N	\N
815	44	1314848809	990	9	4	14	2	10611	83	131	14	672	skeleton_king	1196	15	\N	\N	\N
816	20	1314848809	979	9	9	10	2	8420	86	132	0	593	axe	0	15	\N	\N	\N
827	38	1315027871	1084	9	16	7	6	34667	281	0	23	1911	phantom_lancer	0	25	\N	\N	\N
828	5	1315027871	1002	9	4	9	6	7298	45	1	0	0	bounty_hunter	587	18	\N	\N	\N
829	40	1315027871	1010	9	6	13	6	11494	102	2	7	1256	jakiro	0	19	\N	\N	\N
830	10	1315027871	957	9	5	8	10	15801	56	3	3	0	pudge	0	18	\N	\N	\N
831	47	1315027871	981	9	2	10	4	5645	19	4	1	21	ancient_apparition	1262	14	\N	\N	\N
832	8	1315027871	1052	-9	6	2	5	17288	54	128	0	0	techies	0	11	\N	\N	\N
833	13	1315027871	999	-9	6	3	6	11109	181	129	0	672	lycan	655	20	\N	\N	\N
834	53	1315027871	981	-9	6	1	6	7578	58	130	7	83	lich	250	16	\N	\N	\N
835	17	1315027871	959	-9	2	11	7	9387	151	131	9	527	skeleton_king	1767	18	\N	\N	\N
836	11	1315027871	1042	-9	12	12	9	24642	200	132	8	770	sniper	0	23	\N	\N	\N
837	40	1317023558	1019	-9	1	10	6	4059	44	0	21	0	treant	4528	15	\N	\N	\N
838	5	1317023558	1011	-9	15	10	5	20667	44	1	3	161	spirit_breaker	0	17	\N	\N	\N
839	56	1317023558	1000	-9	9	10	4	24686	295	2	4	813	naga_siren	0	18	\N	\N	\N
840	47	1317023558	990	-9	1	7	9	7807	30	3	3	0	bane	0	13	\N	\N	\N
841	10	1317023558	966	-9	9	10	8	18874	62	4	1	158	pudge	0	19	\N	\N	\N
842	4	1317023558	956	9	7	15	4	23904	176	128	2	4958	skeleton_king	2796	22	\N	\N	\N
843	1	1317023558	1086	9	12	17	6	31558	180	129	3	4432	sniper	0	21	\N	\N	\N
844	3	1317023558	1002	9	5	14	10	23578	112	130	2	2819	bristleback	0	17	\N	\N	\N
845	13	1317023558	990	9	0	11	12	4356	16	131	2	278	lion	0	9	\N	\N	\N
846	12	1317023558	960	9	8	10	3	12451	169	132	1	2772	doom_bringer	0	21	\N	\N	\N
847	26	1317237758	1004	-7	2	1	5	3874	71	0	0	0	doom_bringer	0	12	\N	\N	\N
848	57	1317237758	1000	-7	0	0	11	2942	9	1	1	0	omniknight	900	7	\N	\N	\N
849	44	1317237758	999	-7	2	1	5	4343	38	2	3	0	phantom_lancer	0	8	\N	\N	\N
850	3	1317237758	1011	-7	0	0	8	4057	94	3	4	213	storm_spirit	0	11	\N	\N	\N
851	12	1317237758	969	-7	2	0	5	6050	92	4	6	0	dark_seer	250	12	\N	\N	\N
852	5	1317237758	1002	7	3	10	4	6275	18	128	5	883	venomancer	0	10	\N	\N	\N
853	1	1317237758	1095	7	16	6	0	18071	120	129	14	4275	troll_warlord	0	19	\N	\N	\N
854	10	1317237758	957	7	7	3	0	5165	141	130	10	2914	juggernaut	0	15	\N	\N	\N
855	9	1317237758	986	7	3	3	2	6405	113	131	3	3386	broodmother	0	16	\N	\N	\N
856	13	1317237758	999	7	5	6	0	7182	64	132	0	139	ursa	0	13	\N	\N	\N
857	1	1319817022	1102	-8	15	9	5	33710	523	0	23	6564	troll_warlord	0	25	\N	\N	\N
858	40	1319817022	1010	-8	2	7	7	4886	53	1	13	283	bane	0	17	\N	\N	\N
859	9	1319817022	993	-8	7	12	10	11621	98	2	4	195	nyx_assassin	662	22	\N	\N	\N
860	11	1319817022	1033	-8	7	11	5	27000	375	3	21	2045	slark	0	25	\N	\N	\N
861	55	1319817022	982	-8	2	3	12	7404	84	4	4	88	ogre_magi	0	17	\N	\N	\N
862	29	1319817022	1094	8	6	15	5	9686	31	128	7	1244	lion	0	22	\N	\N	\N
863	44	1319817022	992	8	8	14	9	16925	203	129	16	2272	queenofpain	0	23	\N	\N	\N
864	38	1319817022	1093	8	6	11	8	12911	281	130	4	3651	doom_bringer	0	25	\N	\N	\N
865	10	1319817022	964	8	8	14	7	23437	87	131	1	2333	centaur	0	22	\N	\N	\N
866	13	1319817022	1006	8	9	10	4	26018	325	132	17	5396	juggernaut	0	24	\N	\N	\N
867	46	1320174428	1056	10	15	6	2	17396	211	0	11	3470	faceless_void	0	22	\N	\N	\N
868	29	1320174428	1102	10	2	13	6	7565	21	1	1	1934	jakiro	0	12	\N	\N	\N
869	33	1320174428	1007	10	4	21	6	9744	86	2	1	491	sand_king	0	18	\N	\N	\N
870	11	1320174428	1025	10	9	15	6	15377	86	3	3	1477	phoenix	4918	19	\N	\N	\N
871	8	1320174428	1043	10	7	7	4	11655	97	4	2	1776	templar_assassin	0	18	\N	\N	\N
872	1	1320174428	1094	-10	5	10	2	17299	212	128	7	24	kunkka	0	20	\N	\N	\N
873	38	1320174428	1101	-10	4	10	7	14528	157	129	5	62	dark_seer	1334	18	\N	\N	\N
874	35	1320174428	1039	-10	1	5	11	2865	21	130	3	99	lion	0	11	\N	\N	\N
875	34	1320174428	992	-10	3	8	9	4716	31	131	4	0	vengefulspirit	0	13	\N	\N	\N
876	13	1320174428	1014	-10	11	5	8	12501	151	132	6	0	ursa	0	18	\N	\N	\N
877	1	1320307272	1084	10	15	6	3	22206	275	0	22	8916	juggernaut	0	24	\N	\N	\N
878	11	1320307272	1035	10	10	11	7	18259	195	1	13	4563	death_prophet	0	21	\N	\N	\N
879	38	1320307272	1091	10	4	10	12	10835	59	2	6	163	rubick	0	15	\N	\N	\N
880	13	1320307272	1004	10	9	16	8	21785	111	3	5	828	bristleback	0	20	\N	\N	\N
881	34	1320307272	982	10	0	9	6	3426	32	4	9	638	dazzle	2434	16	\N	\N	\N
882	29	1320307272	1112	-10	2	19	9	11961	112	128	7	567	enigma	0	17	\N	\N	\N
883	35	1320307272	1029	-10	5	11	5	7278	39	129	2	0	lich	526	17	\N	\N	\N
884	22	1320307272	1030	-10	10	11	7	15009	180	130	11	484	tiny	0	21	\N	\N	\N
885	10	1320307272	972	-10	4	17	8	14282	65	131	0	133	batrider	1175	17	\N	\N	\N
886	8	1320307272	1053	-10	12	13	10	31522	132	132	1	19	zuus	0	21	\N	\N	\N
887	35	1320443439	1019	10	4	9	7	2946	13	0	2	273	vengefulspirit	400	13	\N	\N	\N
888	29	1320443439	1102	10	2	13	2	7816	65	1	3	372	earthshaker	0	16	\N	\N	\N
889	1	1320443439	1094	10	14	6	1	19626	143	2	4	740	storm_spirit	0	21	\N	\N	\N
890	22	1320443439	1020	10	8	8	2	9434	243	3	20	3166	juggernaut	0	19	\N	\N	\N
891	10	1320443439	962	10	3	8	3	7207	64	4	1	1155	beastmaster	0	15	\N	\N	\N
892	11	1320443439	1045	-10	5	2	5	11004	83	128	3	79	phoenix	400	16	\N	\N	\N
893	38	1320443439	1101	-10	5	2	5	9154	227	129	36	353	phantom_lancer	0	17	\N	\N	\N
894	8	1320443439	1043	-10	1	2	8	4491	34	130	4	0	omniknight	2070	11	\N	\N	\N
895	26	1320443439	997	-10	1	0	8	1898	45	131	1	0	lion	0	11	\N	\N	\N
896	13	1320443439	1014	-10	2	7	5	15093	145	132	2	239	sniper	0	15	\N	\N	\N
897	1	1322649293	1104	8	3	10	0	9415	162	0	17	3450	troll_warlord	0	18	\N	\N	\N
898	4	1322649293	965	8	12	7	1	13991	167	1	11	2498	skeleton_king	1956	18	\N	\N	\N
899	27	1322649293	995	8	2	5	6	2749	9	2	8	439	lion	400	13	\N	\N	\N
900	33	1322649293	1017	8	1	5	3	1524	83	3	1	756	doom_bringer	0	11	\N	\N	\N
901	13	1322649293	1004	8	3	7	2	5829	90	4	0	552	bristleback	0	14	\N	\N	\N
902	45	1322649293	1020	-8	0	4	6	4818	3	128	2	45	disruptor	0	9	\N	\N	\N
903	3	1322649293	1004	-8	4	0	2	9265	135	129	5	501	windrunner	0	15	\N	\N	\N
904	42	1322649293	999	-8	1	3	5	4270	141	130	38	595	faceless_void	0	13	\N	\N	\N
905	11	1322649293	1035	-8	4	2	5	8691	78	131	4	0	shredder	0	14	\N	\N	\N
906	34	1322649293	992	-8	2	4	4	5802	9	132	1	29	lich	199	9	\N	\N	\N
907	1	1322810747	1112	-9	6	9	6	21732	129	0	11	165	windrunner	0	17	\N	\N	\N
908	3	1322810747	996	-9	5	4	7	15268	258	1	11	1548	juggernaut	0	20	\N	\N	\N
909	10	1322810747	972	-9	2	8	8	8241	55	2	3	112	beastmaster	0	15	\N	\N	\N
910	33	1322810747	1025	-9	2	6	8	6855	18	3	4	417	bane	0	15	\N	\N	\N
911	11	1322810747	1027	-9	5	6	9	8262	103	4	0	0	axe	0	14	\N	\N	\N
912	38	1322810747	1091	9	8	18	4	16541	165	128	17	1712	storm_spirit	887	21	\N	\N	\N
913	29	1322810747	1112	9	17	13	2	25225	130	129	2	7610	bristleback	0	24	\N	\N	\N
914	31	1322810747	962	9	3	13	6	5035	48	130	13	372	vengefulspirit	0	16	\N	\N	\N
915	45	1322810747	1012	9	2	9	5	4402	28	131	1	374	omniknight	4482	15	\N	\N	\N
916	4	1322810747	973	9	7	17	3	17211	188	132	4	3019	skeleton_king	2981	20	\N	\N	\N
917	50	1324856065	1000	10	7	11	7	14188	49	0	1	20	earthshaker	0	17	\N	\N	\N
918	2	1324856065	1010	10	8	13	5	18874	146	1	3	1618	shredder	1244	22	\N	\N	\N
919	35	1324856065	1029	10	3	16	6	11931	68	2	1	1732	venomancer	0	15	\N	\N	\N
920	38	1324856065	1100	10	13	17	6	31654	295	3	24	5541	storm_spirit	1698	25	\N	\N	\N
921	13	1324856065	1012	10	5	5	7	12660	372	4	14	5026	juggernaut	0	24	\N	\N	\N
922	8	1324856065	1033	-10	13	4	5	33702	81	128	0	204	techies	0	17	\N	\N	\N
923	45	1324856065	1021	-10	2	6	15	4754	57	129	3	0	lion	0	15	\N	\N	\N
924	1	1324856065	1103	-10	11	7	5	32336	452	130	12	792	phantom_lancer	0	25	\N	\N	\N
925	3	1324856065	987	-10	2	9	5	12682	267	131	4	0	magnataur	0	22	\N	\N	\N
926	5	1324856065	1009	-10	1	13	7	20761	67	132	1	0	lich	2517	17	\N	\N	\N
927	8	1325053670	1023	10	13	15	8	31976	409	0	16	3735	faceless_void	0	25	\N	\N	\N
928	10	1325053670	963	10	6	13	15	10808	64	1	1	135	lion	0	20	\N	\N	\N
929	5	1325053670	999	10	5	22	1	14566	113	2	10	1672	silencer	0	24	\N	\N	\N
930	38	1325053670	1110	10	20	18	9	71916	640	3	21	6142	sniper	0	25	\N	\N	\N
931	11	1325053670	1018	10	3	28	6	25140	156	4	10	1677	phoenix	1603	25	\N	\N	\N
932	1	1325053670	1093	-10	8	16	14	22983	446	128	13	1622	nevermore	3095	25	\N	\N	\N
933	13	1325053670	1022	-10	20	7	7	36613	377	129	9	5481	juggernaut	0	25	\N	\N	\N
934	50	1325053670	1010	-10	1	13	10	13057	103	130	0	172	dark_seer	0	20	\N	\N	\N
935	3	1325053670	977	-10	4	16	8	17309	295	131	3	1852	enigma	0	24	\N	\N	\N
936	45	1325053670	1011	-10	6	15	9	7923	32	132	4	297	witch_doctor	6602	21	\N	\N	\N
937	15	1325298819	1022	-10	6	6	6	11557	155	0	38	577	troll_warlord	0	19	\N	\N	\N
938	38	1325298819	1120	-10	4	7	10	16280	150	1	30	279	sniper	0	18	\N	\N	\N
939	5	1325298819	1009	-10	3	9	3	9231	23	2	0	0	skywrath_mage	0	16	\N	\N	\N
940	4	1325298819	982	-10	2	6	8	9519	52	3	2	59	tidehunter	0	14	\N	\N	\N
941	31	1325298819	971	-10	3	7	7	3456	20	4	2	101	lion	0	16	\N	\N	\N
942	1	1325298819	1083	10	5	7	2	11829	367	128	10	7311	phantom_assassin	0	22	\N	\N	\N
943	50	1325298819	1000	10	5	12	3	5463	37	129	7	1318	witch_doctor	4212	16	\N	\N	\N
944	10	1325298819	973	10	9	6	5	17616	60	130	5	1448	pudge	0	17	\N	\N	\N
945	13	1325298819	1012	10	14	5	2	13909	135	131	0	3115	ursa	0	21	\N	\N	\N
946	11	1325298819	1028	10	1	13	6	10541	85	132	0	678	rattletrap	0	18	\N	\N	\N
947	1	1325440798	1093	-11	21	14	7	48839	465	0	23	3661	sniper	0	25	\N	\N	\N
948	31	1325440798	961	-11	1	11	11	4471	31	1	5	0	lion	0	20	\N	\N	\N
949	4	1325440798	972	-11	11	16	8	32995	314	2	10	671	skeleton_king	3275	25	\N	\N	\N
950	5	1325440798	999	-11	4	20	8	15775	109	3	3	0	magnataur	0	23	\N	\N	\N
951	13	1325440798	1022	-11	3	13	11	7019	128	4	0	0	doom_bringer	0	19	\N	\N	\N
952	3	1325440798	967	11	16	11	4	40665	610	128	36	10807	phantom_lancer	214	25	\N	\N	\N
953	50	1325440798	1010	11	5	14	9	19341	46	129	15	441	ancient_apparition	0	19	\N	\N	\N
954	10	1325440798	983	11	6	15	11	22965	154	130	8	682	queenofpain	0	22	\N	\N	\N
955	8	1325440798	1033	11	5	17	11	16133	216	131	1	1169	axe	0	24	\N	\N	\N
956	22	1325440798	1030	11	11	15	5	31951	325	132	3	3870	mirana	0	25	\N	\N	\N
957	10	1325600389	994	-9	5	6	13	12769	42	0	1	0	rattletrap	0	15	\N	\N	\N
958	8	1325600389	1044	-9	4	5	14	27504	43	1	1	0	zuus	0	15	\N	\N	\N
959	35	1325600389	1039	-9	1	4	8	4561	18	2	1	0	witch_doctor	0	8	\N	\N	\N
960	50	1325600389	1021	-9	0	6	8	7772	32	3	2	0	shadow_shaman	0	10	\N	\N	\N
961	3	1325600389	978	-9	4	4	5	7004	148	4	14	1219	juggernaut	0	17	\N	\N	\N
962	1	1325600389	1082	9	23	11	0	26927	183	128	7	12327	tiny	0	20	\N	\N	\N
963	11	1325600389	1038	9	7	16	3	14741	52	129	3	1239	phoenix	1111	15	\N	\N	\N
964	4	1325600389	961	9	10	11	4	17665	150	130	8	2231	skeleton_king	3229	19	\N	\N	\N
965	5	1325600389	988	9	5	16	5	14985	14	131	2	679	wisp	13513	15	\N	\N	\N
966	13	1325600389	1011	9	3	10	4	5837	14	132	0	570	lion	0	12	\N	\N	\N
967	1	1325670455	1091	-10	4	11	6	11526	275	0	17	595	faceless_void	0	19	\N	\N	\N
968	35	1325670455	1030	-10	2	5	6	3543	39	1	1	203	lion	13	14	\N	\N	\N
969	3	1325670455	969	-10	15	6	6	17020	150	2	10	1011	invoker	0	17	\N	\N	\N
970	50	1325670455	1012	-10	1	11	8	12843	37	3	9	237	lich	0	16	\N	\N	\N
971	10	1325670455	985	-10	4	9	9	11835	148	4	0	107	dark_seer	1397	18	\N	\N	\N
972	8	1325670455	1035	10	1	10	5	5805	46	128	1	37	earthshaker	0	14	\N	\N	\N
973	5	1325670455	997	10	6	10	2	18229	144	129	6	7063	chaos_knight	0	20	\N	\N	\N
974	4	1325670455	970	10	5	12	9	12735	51	130	0	732	nyx_assassin	0	17	\N	\N	\N
975	13	1325670455	1020	10	10	4	1	10554	175	131	0	6196	lycan	2325	21	\N	\N	\N
976	11	1325670455	1047	10	12	11	9	19886	104	132	9	10239	shadow_shaman	0	18	\N	\N	\N
977	5	1327893173	1007	-10	2	22	8	12593	120	0	3	795	rubick	0	23	\N	\N	\N
978	11	1327893173	1057	-10	13	19	8	16286	49	1	5	1241	bane	0	22	\N	\N	\N
979	38	1327893173	1110	-10	8	18	11	17003	169	2	3	65	magnataur	0	22	\N	\N	\N
980	17	1327893173	950	-10	14	9	11	27882	224	3	2	3735	skeleton_king	3367	25	\N	\N	\N
981	10	1327893173	975	-10	11	27	4	31285	218	4	3	5699	mirana	0	24	\N	\N	\N
982	1	1327893173	1081	10	19	19	5	44508	411	128	27	6163	nevermore	0	25	\N	\N	\N
983	8	1327893173	1045	10	2	18	10	15150	239	129	7	902	enigma	1106	23	\N	\N	\N
984	25	1327893173	979	10	3	6	17	6416	33	130	3	0	lion	0	16	\N	\N	\N
985	30	1327893173	1032	10	11	12	7	42062	378	131	9	4430	phantom_lancer	0	25	\N	\N	\N
986	3	1327893173	959	10	5	16	11	16308	197	132	6	2303	doom_bringer	0	23	\N	\N	\N
987	1	1328022360	1091	-10	8	12	8	32187	251	0	2	244	kunkka	0	21	\N	\N	\N
988	25	1328022360	989	-10	1	14	7	5845	24	1	5	192	ogre_magi	0	16	\N	\N	\N
989	3	1328022360	969	-10	4	9	8	9566	69	2	0	100	magnataur	0	19	\N	\N	\N
990	8	1328022360	1055	-10	7	5	7	10257	299	3	6	611	phantom_assassin	0	22	\N	\N	\N
991	33	1328022360	1016	-10	8	13	11	22486	61	4	16	136	venomancer	0	18	\N	\N	\N
992	48	1328022360	989	10	10	15	8	12408	70	128	2	2135	spirit_breaker	0	20	\N	\N	\N
993	5	1328022360	997	10	2	21	4	9584	116	129	5	959	puck	0	22	\N	\N	\N
994	38	1328022360	1100	10	17	17	4	35439	298	130	11	5264	sniper	0	25	\N	\N	\N
995	52	1328022360	990	10	3	15	9	9256	34	131	1	83	skywrath_mage	0	17	\N	\N	\N
996	30	1328022360	1042	10	9	7	4	19627	362	132	52	5519	faceless_void	0	25	\N	\N	\N
997	13	1329883121	1030	9	4	8	1	8844	193	0	19	2581	abaddon	0	19	\N	\N	\N
998	1	1329883121	1081	9	8	4	0	9423	163	1	5	929	storm_spirit	0	20	\N	\N	\N
999	10	1329883121	965	9	5	8	7	10227	14	2	0	66	pudge	25	12	\N	\N	\N
1000	3	1329883121	959	9	4	4	1	8230	97	3	9	1970	windrunner	0	14	\N	\N	\N
1001	11	1329883121	1047	9	7	8	0	11426	189	4	3	6933	furion	0	20	\N	\N	\N
1002	45	1329883121	1001	-9	6	2	2	6067	9	128	2	0	skywrath_mage	721	11	\N	\N	\N
1003	8	1329883121	1045	-9	2	1	8	2766	132	129	6	0	juggernaut	0	13	\N	\N	\N
1004	31	1329883121	950	-9	1	4	6	3778	20	130	6	0	vengefulspirit	0	13	\N	\N	\N
1005	38	1329883121	1110	-9	0	4	6	9459	124	131	13	0	sniper	0	14	\N	\N	\N
1006	55	1329883121	974	-9	0	5	6	6482	52	132	4	0	tidehunter	0	14	\N	\N	\N
1007	55	1329991365	965	9	1	13	13	4941	108	0	6	2309	jakiro	0	22	\N	\N	\N
1008	4	1329991365	980	9	14	18	13	37352	130	1	3	548	rattletrap	0	24	\N	\N	\N
1009	10	1329991365	974	9	5	8	11	7947	174	2	1	354	sand_king	0	22	\N	\N	\N
1010	38	1329991365	1101	9	23	9	9	43406	623	3	35	9727	gyrocopter	0	24	\N	\N	\N
1011	11	1329991365	1056	9	8	11	10	10929	196	4	1	1489	magnataur	0	25	\N	\N	\N
1012	8	1329991365	1036	-9	10	20	12	28602	213	128	2	789	silencer	0	25	\N	\N	\N
1013	31	1329991365	941	-9	6	12	15	5755	69	129	11	16	disruptor	1047	23	\N	\N	\N
1014	3	1329991365	968	-9	19	14	2	58815	284	130	0	0	techies	0	24	\N	\N	\N
1015	1	1329991365	1090	-9	15	21	10	55149	573	131	14	6001	sniper	0	25	\N	\N	\N
1016	13	1329991365	1039	-9	5	14	13	29651	102	132	0	211	pudge	0	22	\N	\N	\N
1017	1	1330237858	1081	9	13	8	1	16617	94	0	7	1352	tiny	0	18	\N	\N	\N
1018	5	1330237858	1007	9	4	10	0	4597	17	1	4	584	skywrath_mage	0	11	\N	\N	\N
1019	10	1330237858	983	9	4	8	1	5237	122	2	4	2789	dragon_knight	0	13	\N	\N	\N
1020	35	1330237858	1020	9	3	6	1	2989	5	3	7	348	lion	0	10	\N	\N	\N
1021	11	1330237858	1065	9	7	9	3	9703	48	4	3	1258	phoenix	400	13	\N	\N	\N
1022	58	1330237858	1000	-9	1	1	10	7218	53	128	8	0	puck	0	10	\N	\N	\N
1023	8	1330237858	1027	-9	0	4	4	8209	28	129	0	0	earthshaker	0	9	\N	\N	\N
1024	38	1330237858	1110	-9	3	1	5	3975	131	130	19	198	phantom_assassin	0	15	\N	\N	\N
1025	13	1330237858	1030	-9	0	0	6	619	33	131	0	0	omniknight	450	10	\N	\N	\N
1026	34	1330237858	984	-9	2	1	7	4074	16	132	0	61	lina	0	7	\N	\N	\N
1027	1	1330306348	1090	10	22	4	4	25354	155	0	8	6708	templar_assassin	0	22	\N	\N	\N
1028	13	1330306348	1021	10	8	9	2	12675	113	1	3	1511	windrunner	0	17	\N	\N	\N
1029	10	1330306348	992	10	4	13	1	6337	32	2	0	1609	mirana	0	14	\N	\N	\N
1030	34	1330306348	975	10	5	11	2	7829	54	3	3	1440	lina	0	16	\N	\N	\N
1031	11	1330306348	1074	10	7	9	5	11679	168	4	24	7474	drow_ranger	0	19	\N	\N	\N
1032	5	1330306348	1016	-10	2	5	6	10871	65	128	0	0	huskar	0	14	\N	\N	\N
1033	58	1330306348	991	-10	4	3	8	7256	52	129	3	0	lich	561	15	\N	\N	\N
1034	8	1330306348	1018	-10	6	3	10	9359	86	130	2	0	witch_doctor	333	12	\N	\N	\N
1035	35	1330306348	1029	-10	1	7	6	8416	27	131	3	0	necrolyte	1122	13	\N	\N	\N
1036	38	1330306348	1101	-10	0	5	17	6077	61	132	6	0	ember_spirit	0	11	\N	\N	\N
1037	8	1330369067	1008	-11	14	7	10	38315	406	0	1	3556	sven	0	25	\N	\N	\N
1038	11	1330369067	1084	-11	5	11	8	11455	73	1	1	875	bane	0	19	\N	\N	\N
1039	10	1330369067	1002	-11	1	15	7	8590	54	2	1	615	mirana	0	18	\N	\N	\N
1040	38	1330369067	1091	-11	15	4	9	16363	161	3	17	1581	riki	0	24	\N	\N	\N
1041	58	1330369067	981	-11	5	14	9	11727	210	4	3	210	magnataur	0	22	\N	\N	\N
1042	1	1330369067	1100	11	21	17	10	41227	297	128	13	3343	sniper	0	25	\N	\N	\N
1043	35	1330369067	1019	11	0	11	13	3161	38	129	1	616	jakiro	0	16	\N	\N	\N
1044	5	1330369067	1006	11	5	22	3	27344	279	130	2	2637	skeleton_king	1512	25	\N	\N	\N
1045	34	1330369067	985	11	3	16	7	6403	41	131	1	117	rubick	0	19	\N	\N	\N
1046	13	1330369067	1031	11	13	18	7	21666	150	132	4	4704	windrunner	0	23	\N	\N	\N
1047	45	1331872548	992	-9	2	2	4	6513	54	0	2	0	magnataur	0	11	\N	\N	\N
1048	11	1331872548	1073	-9	8	3	3	12058	216	1	26	333	phantom_assassin	0	19	\N	\N	\N
1049	25	1331872548	979	-9	2	8	7	5118	31	2	5	127	jakiro	0	11	\N	\N	\N
1050	48	1331872548	999	-9	2	7	10	4493	27	3	0	137	spirit_breaker	400	12	\N	\N	\N
1051	1	1331872548	1111	-9	3	9	9	14242	126	4	3	388	tiny	0	16	\N	\N	\N
1052	29	1331872548	1121	9	3	13	7	6650	31	128	3	255	lion	0	14	\N	\N	\N
1053	5	1331872548	1017	9	5	11	0	11344	180	129	0	2303	skeleton_king	3694	19	\N	\N	\N
1054	13	1331872548	1042	9	6	16	1	13913	131	130	11	2089	windrunner	0	17	\N	\N	\N
1055	10	1331872548	991	9	14	13	5	15843	107	131	10	2195	viper	2396	18	\N	\N	\N
1056	26	1331872548	987	9	3	13	5	12248	72	132	6	716	centaur	0	15	\N	\N	\N
1057	59	1702814591	1000	10	9	13	7	19102	212	0	14	457	queenofpain	135	20	\N	\N	\N
1058	60	1702814591	1000	10	13	10	1	17709	370	1	20	8348	drow_ranger	0	23	\N	\N	\N
1059	61	1702814591	1000	10	10	18	5	19772	79	2	2	3289	visage	0	17	\N	\N	\N
1060	62	1702814591	1000	10	4	6	6	9265	154	3	14	686	bristleback	0	19	\N	\N	\N
1061	63	1702814591	1000	10	4	18	10	9235	27	4	3	757	lion	0	17	\N	\N	\N
1062	64	1702814591	1000	-10	1	9	10	4547	65	128	8	1763	shadow_shaman	0	13	\N	\N	\N
1063	65	1702814591	1000	-10	3	6	10	9663	159	129	0	0	axe	0	18	\N	\N	\N
1064	66	1702814591	1000	-10	3	6	10	8937	48	130	0	595	skywrath_mage	996	14	\N	\N	\N
1065	67	1702814591	1000	-10	15	5	3	20578	408	131	4	2193	juggernaut	0	24	\N	\N	\N
1066	68	1702814591	1000	-10	7	10	8	10094	149	132	11	476	storm_spirit	2400	19	\N	\N	\N
1067	69	1702969127	1000	-11	3	20	15	10792	59	0	0	663	naga_siren	0	18	\N	\N	\N
1068	61	1702969127	1010	-11	5	24	9	27255	90	1	2	439	witch_doctor	7291	19	\N	\N	\N
1069	59	1702969127	1010	-11	15	13	8	36849	71	2	0	242	nyx_assassin	0	24	\N	\N	\N
1070	70	1702969127	1000	-11	8	17	14	36702	258	3	5	2217	juggernaut	0	23	\N	\N	\N
1071	68	1702969127	990	-11	15	20	13	49876	212	4	17	3546	nevermore	68	22	\N	\N	\N
1072	62	1702969127	1010	11	15	31	11	29529	71	128	4	634	undying	420	23	\N	\N	\N
1073	66	1702969127	990	11	12	29	15	36591	64	129	2	960	ogre_magi	4041	21	\N	\N	\N
1074	60	1702969127	1010	11	14	21	3	39033	329	130	10	9515	phantom_lancer	1434	25	\N	\N	\N
1075	65	1702969127	990	11	11	21	10	34741	126	131	9	2276	queenofpain	0	22	\N	\N	\N
1076	64	1702969127	990	11	6	13	8	12777	127	132	3	1438	skeleton_king	4260	21	\N	\N	\N
1077	60	1703170077	1021	6	11	15	4	20631	326	0	5	7826	troll_warlord	0	22	\N	\N	\N
1078	61	1703170077	999	6	11	16	4	24806	62	1	1	976	visage	0	17	\N	\N	\N
1079	65	1703170077	1001	6	5	17	4	19753	192	2	12	2336	leshrac	135	22	\N	\N	\N
1080	66	1703170077	1001	6	6	21	10	11606	52	3	3	432	winter_wyvern	395	17	\N	\N	\N
1081	71	1703170077	1000	6	5	14	5	9127	197	4	1	409	axe	0	19	\N	\N	\N
1082	67	1703170077	990	-6	4	10	4	17004	515	128	33	1187	antimage	630	24	\N	\N	\N
1083	69	1703170077	989	-6	3	10	10	3627	48	129	1	74	dazzle	4636	14	\N	\N	\N
1084	59	1703170077	999	-6	12	11	10	18303	125	130	5	0	phoenix	1268	17	\N	\N	\N
1085	64	1703170077	1001	-6	4	8	9	10959	33	131	1	80	ogre_magi	400	14	\N	\N	\N
1086	68	1703170077	979	-6	4	13	5	15090	191	132	14	334	viper	4202	19	\N	\N	\N
1087	59	1705590212	993	-10	18	7	10	31768	168	0	9	280	lina	0	22	\N	\N	\N
1088	60	1705590212	1027	-10	5	10	11	13802	336	1	26	1756	antimage	630	20	\N	\N	\N
1089	72	1705590212	1000	-10	5	20	10	15880	33	2	6	59	winter_wyvern	0	15	\N	\N	\N
1090	64	1705590212	995	-10	2	11	13	24201	163	3	9	14	bristleback	1558	21	\N	\N	\N
1091	61	1705590212	1005	-10	5	9	8	14950	71	4	1	148	lion	400	18	\N	\N	\N
1092	73	1705590212	1000	10	12	23	4	39926	122	128	2	1127	zuus	135	20	\N	\N	\N
1093	66	1705590212	1007	10	6	17	11	13354	61	129	1	1111	rubick	400	18	\N	\N	\N
1094	74	1705590212	1000	10	7	21	7	11380	40	130	6	1121	undying	9408	20	\N	\N	\N
1095	71	1705590212	1006	10	12	13	2	36416	232	131	1	5568	skeleton_king	3473	25	\N	\N	\N
1096	65	1705590212	1007	10	14	16	13	30270	165	132	8	4372	bloodseeker	3018	23	\N	\N	\N
1097	66	1705755149	1017	10	4	24	7	11379	52	0	3	1454	undying	2025	14	\N	\N	\N
1098	69	1705755149	983	10	7	10	6	9131	17	1	1	1892	lion	0	16	\N	\N	\N
1099	61	1705755149	995	10	19	11	6	22545	36	2	0	4117	visage	0	16	\N	\N	\N
1100	65	1705755149	1017	10	8	7	7	11620	89	3	2	1531	tiny	135	15	\N	\N	\N
1101	68	1705755149	973	10	3	10	2	9060	176	4	26	5290	luna	0	17	\N	\N	\N
1102	60	1705755149	1017	-10	17	7	4	25868	264	128	18	1013	gyrocopter	0	20	\N	\N	\N
1103	59	1705755149	983	-10	2	14	6	9557	150	129	1	159	dark_seer	0	15	\N	\N	\N
1104	71	1705755149	1016	-10	2	5	9	3430	103	130	2	73	faceless_void	0	15	\N	\N	\N
1105	75	1705755149	1000	-10	2	12	13	7662	33	131	1	0	winter_wyvern	400	10	\N	\N	\N
1106	64	1705755149	985	-10	3	9	10	8142	16	132	1	0	ancient_apparition	0	9	\N	\N	\N
1107	67	1705866389	984	-5	25	13	2	45557	412	0	0	771	lina	0	25	\N	\N	\N
1108	69	1705866389	993	-5	2	28	12	13626	135	1	1	202	winter_wyvern	0	22	\N	\N	\N
1109	71	1705866389	1006	-5	3	15	12	10068	65	2	0	0	witch_doctor	9586	18	\N	\N	\N
1110	59	1705866389	973	-5	13	20	5	24108	255	3	1	87	phoenix	2431	25	\N	\N	\N
1111	68	1705866389	983	-5	13	18	4	40932	697	4	14	1662	luna	0	25	\N	\N	\N
1112	60	1705866389	1007	5	10	12	8	62364	345	128	7	54	tinker	2202	25	\N	\N	\N
1113	66	1705866389	1027	5	12	9	14	39310	270	129	8	3421	bristleback	0	25	\N	\N	\N
1114	61	1705866389	1005	5	0	4	10	2844	51	130	0	721	dazzle	4949	16	\N	\N	\N
1115	65	1705866389	1027	5	10	2	11	18143	344	131	1	12428	broodmother	0	25	\N	\N	\N
1116	64	1705866389	975	5	3	5	15	9303	47	132	6	317	lion	1755	18	\N	\N	\N
1117	59	1708245455	968	-5	9	4	5	16250	57	0	3	0	queenofpain	72	13	\N	\N	\N
1118	60	1708245455	1012	-5	1	12	5	10293	100	1	4	582	gyrocopter	0	12	\N	\N	\N
1119	76	1708245455	1000	-5	2	7	9	4413	12	2	1	0	dazzle	2710	8	\N	\N	\N
1120	71	1708245455	1001	-5	4	3	7	5570	27	3	4	0	centaur	0	11	\N	\N	\N
1121	64	1708245455	980	-5	0	11	10	3288	18	4	0	0	sand_king	0	9	\N	\N	\N
1122	61	1708245455	1010	5	3	12	2	7475	47	128	4	5151	jakiro	0	12	\N	\N	\N
1123	62	1708245455	1021	5	7	17	1	7311	16	129	7	1350	undying	1020	11	\N	\N	\N
1124	77	1708245455	1000	5	8	8	2	9481	100	130	20	3121	riki	0	14	\N	\N	\N
1125	78	1708245455	1000	5	7	19	5	9105	55	131	5	1842	necrolyte	8177	13	\N	\N	\N
1126	65	1708245455	1032	5	10	14	7	14322	44	132	5	2650	lina	0	14	\N	\N	\N
1127	78	1708341097	1005	15	6	7	3	5045	185	0	3	2653	phantom_lancer	283	20	\N	\N	\N
1128	60	1708341097	1007	15	19	15	3	28625	155	1	7	4779	leshrac	135	20	\N	\N	\N
1129	64	1708341097	975	15	2	10	11	3269	41	2	3	332	shadow_shaman	1264	11	\N	\N	\N
1130	71	1708341097	996	15	4	15	9	7794	18	3	0	18	nyx_assassin	0	14	\N	\N	\N
1131	59	1708341097	963	15	8	21	6	19629	93	4	3	390	phoenix	403	18	\N	\N	\N
1132	65	1708341097	1037	-15	12	6	8	14113	140	128	3	1745	bristleback	135	16	\N	\N	\N
1133	77	1708341097	1005	-15	4	16	6	7588	63	129	11	480	undying	620	14	\N	\N	\N
1134	62	1708341097	1026	-15	11	9	9	15600	58	130	5	1040	lina	0	14	\N	\N	\N
1135	76	1708341097	995	-15	2	6	7	8488	91	131	20	77	silencer	270	15	\N	\N	\N
1136	61	1708341097	1015	-15	2	13	11	12352	22	132	1	475	wisp	7840	11	\N	\N	\N
1137	61	1711087497	1000	10	5	10	3	15057	18	0	4	884	wisp	11790	17	\N	\N	\N
1138	60	1711087497	1022	10	16	6	3	17692	289	1	4	14309	tiny	0	20	\N	\N	\N
1139	64	1711087497	990	10	3	7	4	5561	130	2	3	2217	bristleback	318	17	\N	\N	\N
1140	62	1711087497	1011	10	3	10	1	10715	142	3	33	604	silencer	0	17	\N	\N	\N
1141	76	1711087497	980	10	2	11	4	5720	27	4	8	254	vengefulspirit	0	14	\N	\N	\N
1142	59	1711087497	978	-10	2	8	5	10461	61	128	0	0	phoenix	178	16	\N	\N	\N
1143	69	1711087497	988	-10	6	4	7	23480	133	129	9	98	zuus	32	16	\N	\N	\N
1144	66	1711087497	1032	-10	3	4	6	12124	46	130	6	0	ancient_apparition	0	13	\N	\N	\N
1145	78	1711087497	1020	-10	1	4	5	6706	246	131	12	290	gyrocopter	0	17	\N	\N	\N
1146	75	1711087497	990	-10	2	7	6	4299	32	132	6	59	witch_doctor	1290	12	\N	\N	\N
1147	60	1711229087	1032	9	5	10	3	14560	199	0	14	4872	leshrac	2286	19	\N	\N	\N
1148	68	1711229087	978	9	9	7	5	12340	224	1	37	4217	faceless_void	0	18	\N	\N	\N
1149	62	1711229087	1021	9	9	14	4	20594	117	2	26	849	bristleback	0	17	\N	\N	\N
1150	64	1711229087	1000	9	5	6	4	6051	15	3	4	770	lion	1939	15	\N	\N	\N
1151	69	1711229087	978	9	5	14	6	6445	17	4	1	1052	dazzle	6525	13	\N	\N	\N
1152	66	1711229087	1022	-9	3	6	12	8797	15	128	1	113	bounty_hunter	0	11	\N	\N	\N
1153	78	1711229087	1010	-9	6	7	5	16318	180	129	17	2264	bloodseeker	365	18	\N	\N	\N
1154	71	1711229087	1011	-9	1	6	7	7829	82	130	16	311	centaur	0	13	\N	\N	\N
1155	76	1711229087	990	-9	7	6	5	12607	46	131	6	521	lina	0	14	\N	\N	\N
1156	59	1711229087	968	-9	5	10	5	14391	70	132	3	324	phoenix	607	15	\N	\N	\N
1157	62	1711327870	1030	-9	2	16	7	14273	89	0	10	0	tidehunter	0	18	\N	\N	\N
1158	78	1711327870	1001	-9	4	7	10	18074	158	1	10	1289	luna	0	15	\N	\N	\N
1159	64	1711327870	1009	-9	3	9	11	6764	13	2	3	0	bane	0	13	\N	\N	\N
1160	68	1711327870	987	-9	7	8	10	11244	88	3	16	0	storm_spirit	0	15	\N	\N	\N
1161	69	1711327870	987	-9	4	11	8	15548	37	4	1	0	rubick	0	14	\N	\N	\N
1162	60	1711327870	1041	9	23	16	6	36131	179	128	7	8214	leshrac	2243	21	\N	\N	\N
1163	66	1711327870	1013	9	6	20	3	9954	50	129	1	912	winter_wyvern	400	16	\N	\N	\N
1164	59	1711327870	959	9	11	17	4	38275	102	130	7	2915	skeleton_king	1324	19	\N	\N	\N
1165	71	1711327870	1002	9	2	17	4	4314	104	131	0	997	dark_seer	5710	16	\N	\N	\N
1166	79	1711327870	1000	9	3	14	6	14313	50	132	0	896	rattletrap	0	14	\N	\N	\N
1167	66	1711418546	1022	-10	10	23	15	36072	112	0	5	1051	phoenix	3004	21	\N	\N	\N
1168	69	1711418546	978	-10	9	22	12	38463	74	1	2	1116	pudge	535	22	\N	\N	\N
1169	64	1711418546	1000	-10	3	15	7	20353	288	2	0	5922	furion	0	23	\N	\N	\N
1170	68	1711418546	978	-10	10	9	11	17920	225	3	19	0	juggernaut	0	22	\N	\N	\N
1171	62	1711418546	1021	-10	6	17	16	15105	65	4	0	1003	spirit_breaker	0	19	\N	\N	\N
1172	60	1711418546	1050	10	18	17	3	38088	335	128	17	5887	gyrocopter	0	25	\N	\N	\N
1173	59	1711418546	968	10	6	20	11	17986	80	129	2	377	tusk	0	20	\N	\N	\N
1174	79	1711418546	1009	10	7	20	11	20439	79	130	1	529	earthshaker	0	17	\N	\N	\N
1175	67	1711418546	979	10	22	20	5	48188	257	131	0	8984	dragon_knight	0	25	\N	\N	\N
1176	78	1711418546	992	10	8	13	11	7948	65	132	2	998	dazzle	11060	20	\N	\N	\N
1177	65	1713230455	1022	-9	6	4	7	14498	72	0	1	0	storm_spirit	225	14	\N	\N	\N
1178	66	1713230455	1012	-9	3	0	11	2956	18	1	8	0	dazzle	2429	11	\N	\N	\N
1179	62	1713230455	1011	-9	3	5	5	7823	101	2	16	0	bloodseeker	0	13	\N	\N	\N
1180	80	1713230455	1000	-9	3	4	12	5565	22	3	1	0	witch_doctor	1244	11	\N	\N	\N
1181	70	1713230455	989	-9	3	5	7	14941	91	4	8	264	necrolyte	1567	13	\N	\N	\N
1182	60	1713230455	1060	9	19	8	3	26773	157	128	3	14593	tiny	0	17	\N	\N	\N
1183	59	1713230455	978	9	4	19	6	14804	32	129	0	171	tusk	0	14	\N	\N	\N
1184	77	1713230455	990	9	4	7	3	9096	109	130	7	2177	bristleback	0	15	\N	\N	\N
1185	71	1713230455	1011	9	8	6	4	12521	8	131	0	95	techies	0	11	\N	\N	\N
1186	61	1713230455	1010	9	4	16	2	15252	21	132	6	853	wisp	13908	15	\N	\N	\N
1187	59	1713395218	987	-8	7	16	8	22148	68	0	8	266	tusk	135	18	\N	\N	\N
1188	66	1713395218	1003	-8	9	15	9	15998	43	1	0	463	winter_wyvern	0	17	\N	\N	\N
1189	71	1713395218	1020	-8	8	16	7	24631	78	2	0	725	necrolyte	4574	18	\N	\N	\N
1190	61	1713395218	1019	-8	6	19	10	19503	104	3	7	1282	enigma	2697	16	\N	\N	\N
1191	77	1713395218	999	-8	7	12	8	11572	157	4	2	1560	phantom_lancer	0	17	\N	\N	\N
1192	60	1713395218	1069	8	6	11	6	18553	155	128	9	1114	shredder	0	18	\N	\N	\N
1193	67	1713395218	989	8	6	11	5	13060	172	129	1	5485	dragon_knight	0	18	\N	\N	\N
1194	70	1713395218	980	8	11	21	8	25352	191	130	8	3533	gyrocopter	0	19	\N	\N	\N
1195	65	1713395218	1013	8	7	21	6	21871	116	131	4	2738	skeleton_king	2958	20	\N	\N	\N
1196	62	1713395218	1002	8	12	21	12	13926	44	132	5	918	undying	270	15	\N	\N	\N
1197	70	1716057540	988	-7	12	11	8	26575	427	0	12	3308	antimage	0	25	\N	\N	\N
1198	61	1716057540	1011	-7	14	11	5	28129	170	1	4	1139	brewmaster	0	23	\N	\N	\N
1199	72	1716057540	990	-7	4	17	6	14648	124	2	7	115	winter_wyvern	210	19	\N	\N	\N
1200	78	1716057540	1002	-7	1	12	12	16710	198	3	1	294	dark_seer	4892	17	\N	\N	\N
1201	79	1716057540	1019	-7	5	16	16	18785	118	4	6	0	earthshaker	0	18	\N	\N	\N
1202	60	1716057540	1077	7	11	25	7	42158	342	128	2	4687	leshrac	5013	25	\N	\N	\N
1203	62	1716057540	1010	7	5	26	8	27765	82	129	2	261	zuus	0	21	\N	\N	\N
1204	81	1716057540	1000	7	2	10	8	5082	34	130	4	358	lion	0	14	\N	\N	\N
1205	59	1716057540	979	7	21	10	4	34290	282	131	5	5688	bloodseeker	508	25	\N	\N	\N
1206	64	1716057540	990	7	3	27	9	17017	152	132	6	2888	bristleback	2656	22	\N	\N	\N
1207	60	1716321142	1084	7	18	18	6	28024	233	0	8	7874	templar_assassin	711	25	\N	\N	\N
1208	75	1716321142	980	7	4	17	14	8232	30	1	2	875	lion	400	16	\N	\N	\N
1209	59	1716321142	986	7	8	27	13	20498	65	2	1	450	tusk	0	18	\N	\N	\N
1210	61	1716321142	1004	7	21	31	7	30470	52	3	2	2892	visage	0	22	\N	\N	\N
1211	66	1716321142	995	7	10	24	11	15922	189	4	1	6451	phantom_lancer	1352	21	\N	\N	\N
1212	78	1716321142	995	-7	7	15	11	10255	97	128	4	890	spirit_breaker	659	18	\N	\N	\N
1213	62	1716321142	1017	-7	19	14	5	43182	118	129	3	197	zuus	275	22	\N	\N	\N
1214	64	1716321142	997	-7	10	9	15	11258	98	130	2	611	lina	0	16	\N	\N	\N
1215	79	1716321142	1012	-7	5	29	15	21671	67	131	6	650	pugna	0	16	\N	\N	\N
1216	70	1716321142	981	-7	8	21	15	16821	205	132	7	1286	gyrocopter	0	19	\N	\N	\N
1217	60	1716522810	1091	6	10	22	7	25776	207	0	17	2742	gyrocopter	0	19	\N	\N	\N
1218	75	1716522810	987	6	6	20	5	15782	135	1	1	4086	skeleton_king	4103	21	\N	\N	\N
1219	64	1716522810	990	6	7	22	12	9979	29	2	2	693	undying	5311	17	\N	\N	\N
1220	67	1716522810	997	6	11	18	6	25331	151	3	3	5326	dragon_knight	0	21	\N	\N	\N
1221	79	1716522810	1005	6	10	24	6	22249	67	4	2	1557	tidehunter	0	19	\N	\N	\N
1222	59	1716522810	993	-6	17	6	9	24224	138	128	0	0	bloodseeker	967	19	\N	\N	\N
1223	78	1716522810	988	-6	7	13	8	19977	132	129	6	1748	clinkz	0	19	\N	\N	\N
1224	61	1716522810	1011	-6	5	17	9	14026	96	130	11	75	brewmaster	0	17	\N	\N	\N
1225	66	1716522810	1002	-6	0	16	11	15091	53	131	6	65	winter_wyvern	400	13	\N	\N	\N
1226	62	1716522810	1010	-6	7	17	9	21153	59	132	3	68	spirit_breaker	0	16	\N	\N	\N
1227	70	1716819375	974	-6	3	10	11	14718	68	0	7	0	windrunner	0	17	\N	\N	\N
1228	59	1716819375	987	-6	8	7	15	11142	69	1	1	0	bloodseeker	747	17	\N	\N	\N
1229	73	1716819375	1010	-6	2	5	3	12895	28	2	1	0	zuus	0	9	\N	\N	\N
1230	67	1716819375	1003	-6	1	2	6	2230	5	3	2	0	lich	0	8	\N	\N	\N
1231	79	1716819375	1011	-6	11	4	15	18063	56	4	0	32	tiny	0	17	\N	\N	\N
1232	78	1716819375	982	6	7	6	6	11647	143	128	10	5845	juggernaut	0	17	\N	\N	\N
1233	60	1716819375	1097	6	11	13	4	19708	116	129	3	2879	queenofpain	315	20	\N	\N	\N
1234	62	1716819375	1004	6	18	15	5	17299	44	130	4	622	tusk	0	19	\N	\N	\N
1235	69	1716819375	968	6	8	12	7	19743	36	131	2	4378	techies	400	13	\N	\N	\N
1236	64	1716819375	996	6	4	7	4	5144	53	132	3	572	earthshaker	0	14	\N	\N	\N
1237	79	1716998000	1005	-6	4	1	5	8116	90	0	10	286	gyrocopter	0	11	\N	\N	\N
1238	69	1716998000	974	-6	0	3	9	2336	3	1	2	0	winter_wyvern	400	7	\N	\N	\N
1239	73	1716998000	1004	-6	0	2	4	4907	41	2	2	0	queenofpain	0	10	\N	\N	\N
1240	78	1716998000	988	-6	3	3	8	5503	76	3	3	506	bloodseeker	351	12	\N	\N	\N
1241	64	1716998000	1002	-6	0	1	4	2514	10	4	1	0	earthshaker	400	7	\N	\N	\N
1242	75	1716998000	993	6	2	6	3	2291	20	128	1	555	lion	0	9	\N	\N	\N
1243	82	1716998000	1000	6	1	9	1	2372	24	129	2	265	dazzle	4616	11	\N	\N	\N
1244	60	1716998000	1103	6	9	17	1	25998	147	130	5	76	tinker	190	15	\N	\N	\N
1245	59	1716998000	981	6	11	6	3	9990	36	131	1	147	tusk	0	13	\N	\N	\N
1246	70	1716998000	968	6	6	9	0	9206	120	132	10	1999	phantom_lancer	0	14	\N	\N	\N
1247	60	1719147866	1109	6	14	14	3	26359	86	0	1	662	zuus	405	16	\N	\N	\N
1248	59	1719147866	987	6	11	11	5	10672	84	1	1	236	bloodseeker	799	15	\N	\N	\N
1249	79	1719147866	999	6	4	11	5	5779	23	2	1	250	spirit_breaker	0	13	\N	\N	\N
1250	64	1719147866	996	6	0	12	4	2715	19	3	8	384	rubick	0	11	\N	\N	\N
1251	70	1719147866	974	6	6	10	3	7640	142	4	13	2733	gyrocopter	0	15	\N	\N	\N
1252	61	1719147866	1005	-6	3	9	9	6057	21	128	2	0	lina	0	9	\N	\N	\N
1253	75	1719147866	999	-6	1	9	10	9618	34	129	2	105	rattletrap	0	9	\N	\N	\N
1254	71	1719147866	1012	-6	7	4	7	4546	4	130	2	0	bane	0	11	\N	\N	\N
1255	66	1719147866	996	-6	7	6	8	7435	74	131	2	250	queenofpain	14	13	\N	\N	\N
1256	76	1719147866	981	-6	2	6	2	9613	123	132	14	129	life_stealer	757	14	\N	\N	\N
1257	65	1719624915	1021	-6	8	16	11	25297	161	0	5	585	gyrocopter	0	19	\N	\N	\N
1258	83	1719624915	1000	-6	9	16	12	15707	77	1	4	421	witch_doctor	2576	17	\N	\N	\N
1259	59	1719624915	993	-6	5	17	11	20347	72	2	2	501	tusk	0	17	\N	\N	\N
1260	71	1719624915	1006	-6	9	18	9	25525	156	3	4	830	necrolyte	4504	21	\N	\N	\N
1261	70	1719624915	980	-6	7	18	15	18542	55	4	0	641	crystal_maiden	0	18	\N	\N	\N
1262	60	1719624915	1115	6	20	12	2	39189	286	128	25	10369	morphling	0	25	\N	\N	\N
1263	66	1719624915	990	6	10	18	13	19990	63	129	3	720	lion	0	21	\N	\N	\N
1264	61	1719624915	999	6	13	21	8	28186	114	130	4	3871	brewmaster	2782	22	\N	\N	\N
1265	64	1719624915	1002	6	5	17	10	11514	102	131	2	184	bristleback	0	18	\N	\N	\N
1266	69	1719624915	968	6	9	21	9	12228	35	132	0	1481	spirit_breaker	1475	19	\N	\N	\N
1267	62	1719764895	1010	-5	14	10	12	29964	115	0	13	0	slardar	0	19	\N	\N	\N
1268	66	1719764895	996	-5	10	18	13	35009	144	1	5	1109	bristleback	0	20	\N	\N	\N
1269	64	1719764895	1008	-5	11	20	12	19455	61	2	1	504	spirit_breaker	1627	18	\N	\N	\N
1270	75	1719764895	993	-5	4	17	8	31704	179	3	7	823	lina	0	18	\N	\N	\N
1271	70	1719764895	974	-5	5	15	13	16319	103	4	1	173	keeper_of_the_light	0	16	\N	\N	\N
1272	60	1719764895	1121	5	12	20	12	27836	186	128	5	703	queenofpain	9	22	\N	\N	\N
1273	59	1719764895	987	5	18	25	6	67343	169	129	1	7403	skeleton_king	1921	24	\N	\N	\N
1274	69	1719764895	974	5	11	16	12	13526	9	130	0	509	bounty_hunter	1790	17	\N	\N	\N
1275	71	1719764895	1000	5	6	16	8	12404	34	131	0	1948	ogre_magi	4182	20	\N	\N	\N
1276	83	1719764895	994	5	9	19	8	19774	114	132	4	1140	tidehunter	0	20	\N	\N	\N
1277	59	1719882456	992	-5	21	6	11	38184	196	0	11	947	bloodseeker	842	25	\N	\N	\N
1278	62	1719882456	1005	-5	5	18	13	24244	150	1	4	171	centaur	0	19	\N	\N	\N
1279	79	1719882456	1005	-5	7	21	9	21979	143	2	1	0	tiny	0	20	\N	\N	\N
1280	69	1719882456	979	-5	13	24	12	46256	138	3	2	41	zuus	851	21	\N	\N	\N
1281	75	1719882456	988	-5	4	14	11	15056	37	4	2	42	lich	3316	16	\N	\N	\N
1282	60	1719882456	1126	5	18	26	5	63504	308	128	2	14	tinker	1173	25	\N	\N	\N
1283	78	1719882456	982	5	5	25	9	18560	217	129	5	5772	skeleton_king	2198	24	\N	\N	\N
1284	66	1719882456	991	5	19	21	10	34733	139	130	7	5174	bristleback	0	24	\N	\N	\N
1285	64	1719882456	1003	5	4	15	13	7706	27	131	3	381	lion	2706	16	\N	\N	\N
1286	70	1719882456	969	5	6	25	14	15518	152	132	0	1223	sand_king	0	21	\N	\N	\N
1287	60	1720012133	1131	5	6	20	3	27174	203	0	5	3318	gyrocopter	0	20	\N	\N	\N
1288	67	1720012133	997	5	13	20	1	35417	212	1	4	9678	dragon_knight	0	24	\N	\N	\N
1289	78	1720012133	987	5	10	15	5	12508	57	2	2	1222	lion	365	18	\N	\N	\N
1290	84	1720012133	1000	5	14	10	3	15750	124	3	1	1617	axe	0	19	\N	\N	\N
1291	70	1720012133	974	5	4	18	6	16405	113	4	1	1501	magnataur	1223	19	\N	\N	\N
1292	64	1720012133	1008	-5	2	7	11	17128	120	128	4	143	bristleback	6	15	\N	\N	\N
1293	62	1720012133	1000	-5	6	4	7	8140	120	129	8	1134	dazzle	3088	17	\N	\N	\N
1294	59	1720012133	987	-5	6	2	9	20566	225	130	6	6512	death_prophet	1300	21	\N	\N	\N
1295	79	1720012133	1000	-5	1	4	12	12163	62	131	1	2191	jakiro	0	15	\N	\N	\N
1296	66	1720012133	996	-5	2	5	8	7592	142	132	11	854	juggernaut	0	16	\N	\N	\N
1297	61	1721993868	1005	-5	6	12	7	12873	64	0	2	292	skywrath_mage	0	15	\N	\N	\N
1298	78	1721993868	992	-5	7	13	4	21156	184	1	4	1079	necrolyte	8075	17	\N	\N	\N
1299	71	1721993868	1005	-5	1	15	10	7138	34	2	2	546	dazzle	3673	12	\N	\N	\N
1300	85	1721993868	1000	-5	5	13	7	17200	111	3	9	328	undying	2560	17	\N	\N	\N
1301	59	1721993868	982	-5	12	9	6	19524	145	4	4	570	bloodseeker	746	18	\N	\N	\N
1302	72	1721993868	983	5	0	11	8	6537	21	128	4	438	omniknight	4371	13	\N	\N	\N
1303	86	1721993868	1000	5	3	10	8	11290	134	129	0	291	bristleback	0	16	\N	\N	\N
1304	67	1721993868	1002	5	12	12	6	32442	220	130	4	6117	troll_warlord	0	23	\N	\N	\N
1305	60	1721993868	1136	5	13	13	3	29230	184	131	1	2519	storm_spirit	1981	21	\N	\N	\N
1306	70	1721993868	979	5	3	15	6	27168	181	132	4	2091	skeleton_king	5086	19	\N	\N	\N
1307	61	1722191943	1000	-5	3	10	4	8066	24	0	2	41	abaddon	3242	14	\N	\N	\N
1308	86	1722191943	1005	-5	4	10	10	9142	38	1	4	168	spirit_breaker	721	13	\N	\N	\N
1309	65	1722191943	1015	-5	7	10	7	11838	120	2	5	310	storm_spirit	0	17	\N	\N	\N
1310	78	1722191943	987	-5	5	11	13	10001	52	3	4	17	witch_doctor	3927	13	\N	\N	\N
1311	85	1722191943	995	-5	7	10	6	14013	134	4	10	55	gyrocopter	0	15	\N	\N	\N
1312	60	1722191943	1141	5	10	19	2	34865	221	128	7	111	tinker	2961	22	\N	\N	\N
1313	59	1722191943	977	5	16	10	5	24592	187	129	9	1285	bloodseeker	318	20	\N	\N	\N
1314	64	1722191943	1003	5	1	7	6	3117	47	130	1	154	vengefulspirit	542	12	\N	\N	\N
1315	71	1722191943	1000	5	2	4	5	1943	8	131	1	56	ogre_magi	0	11	\N	\N	\N
1316	62	1722191943	995	5	10	17	8	11538	69	132	14	397	undying	0	16	\N	\N	\N
1317	60	1725032466	1146	5	24	20	4	57072	249	0	8	1121	tinker	1810	25	\N	\N	\N
1318	61	1725032466	995	5	11	16	5	23433	100	1	7	4902	brewmaster	0	21	\N	\N	\N
1319	78	1725032466	982	5	2	12	13	8157	39	2	1	3352	jakiro	0	15	\N	\N	\N
1320	62	1725032466	1000	5	13	13	9	27349	109	3	9	1362	bristleback	0	20	\N	\N	\N
1321	88	1725032466	1000	5	1	6	7	4314	23	4	2	756	dazzle	7862	12	\N	\N	\N
1322	65	1725032466	1010	-5	18	9	12	26510	131	128	6	242	bloodseeker	2410	19	\N	\N	\N
1323	71	1725032466	1005	-5	4	20	12	15726	51	129	1	88	earthshaker	0	16	\N	\N	\N
1324	89	1725032466	1000	-5	8	13	7	18884	94	130	8	438	windrunner	0	16	\N	\N	\N
1325	90	1725032466	1000	-5	4	20	6	15687	176	131	18	0	skeleton_king	3671	21	\N	\N	\N
1326	70	1725032466	984	-5	2	15	14	7842	15	132	4	115	vengefulspirit	135	12	\N	\N	\N
1327	91	2154515714	1000	-10	4	2	6	4117	13	0	3	0	visage	\N	13	8656	192	223
1328	92	2154515714	1000	-10	3	3	11	18040	197	1	7	15	shredder	\N	18	21746	367	427
1329	93	2154515714	1000	-10	4	4	3	12102	287	2	38	960	morphling	\N	22	13751	557	654
1330	94	2154515714	1000	-10	4	9	11	16634	52	3	6	19	pudge	\N	16	31238	239	332
1331	95	2154515714	1000	-10	9	7	12	15870	124	4	1	0	bloodseeker	\N	16	16330	324	338
1332	96	2154515714	1000	10	13	9	4	17140	195	128	1	3069	ursa	\N	24	12534	554	733
1333	97	2154515714	1000	10	4	15	5	16172	184	129	3	1450	ember_spirit	\N	19	14406	442	496
1334	98	2154515714	1000	10	18	10	5	24239	215	130	21	3081	invoker	\N	23	14791	641	684
1335	99	2154515714	1000	10	6	15	4	20474	171	131	9	2295	life_stealer	\N	22	9731	474	633
1336	100	2154515714	1000	10	1	8	7	5823	165	132	5	923	phoenix	\N	19	7428	405	450
1337	98	2154635335	1010	-8	4	3	4	4942	86	0	8	155	storm_spirit	\N	12	6478	459	500
1338	92	2154635335	990	-8	1	2	2	1196	32	1	1	29	omniknight	\N	8	3273	253	221
1339	101	2154635335	1000	-8	1	0	2	1005	11	2	0	0	lion	\N	8	2020	169	222
1340	95	2154635335	990	-8	0	0	4	2243	102	3	1	198	troll_warlord	\N	9	3759	299	283
1341	102	2154635335	1000	-8	1	2	2	4410	15	4	0	0	spirit_breaker	\N	8	5768	232	252
1342	96	2154635335	1010	8	1	7	2	9140	65	128	3	0	zuus	\N	11	3404	376	448
1343	91	2154635335	990	8	4	3	2	3021	11	129	6	0	bane	\N	9	2605	292	265
1344	97	2154635335	1010	8	2	2	0	2662	9	130	0	0	dazzle	\N	7	1368	220	163
1345	103	2154635335	1000	8	4	3	2	4482	85	131	29	0	spectre	\N	11	3368	445	423
1346	99	2154635335	1010	8	3	2	1	1993	107	132	2	1159	broodmother	\N	13	3051	505	570
1347	104	2156775205	1000	-10	3	4	4	15655	256	0	27	200	legion_commander	\N	21	15011	560	592
1348	91	2156775205	998	-10	4	2	6	9731	28	1	0	0	abaddon	\N	13	14166	226	227
1349	101	2156775205	992	-10	2	2	9	7018	20	2	3	45	bane	\N	11	12093	177	169
1350	100	2156775205	1010	-10	1	3	2	6342	99	3	1	262	spirit_breaker	\N	15	14178	277	336
1351	98	2156775205	1002	-10	6	6	4	13065	255	4	11	3611	templar_assassin	\N	20	11953	538	571
1352	96	2156775205	1018	10	8	9	2	22211	221	128	6	4470	obsidian_destroyer	\N	20	12321	525	524
1353	97	2156775205	1018	10	3	14	3	7923	20	129	1	911	lion	\N	14	7379	249	279
1354	93	2156775205	990	10	9	6	4	17119	344	130	48	7092	juggernaut	\N	21	13671	651	610
1355	92	2156775205	982	10	1	5	3	3510	49	131	8	672	dazzle	\N	13	6516	265	252
1356	95	2156775205	982	10	4	12	4	12963	60	132	3	778	phoenix	\N	16	8249	326	359
1357	96	2158744285	1028	-13	0	3	5	5413	159	0	3	786	spectre	\N	14	7709	348	337
1358	105	2158744285	1000	-13	6	1	4	3126	18	1	1	14	techies	\N	11	4500	264	210
1359	95	2158744285	992	-13	6	5	5	12795	130	2	2	439	necrolyte	\N	16	9637	415	457
1360	106	2158744285	1000	-13	3	7	10	19771	58	3	0	327	pudge	\N	12	21777	306	278
1361	97	2158744285	1028	-13	1	3	10	5018	25	4	2	0	witch_doctor	\N	11	11723	201	195
1362	101	2158744285	982	13	2	8	5	2472	58	128	10	1119	shadow_shaman	\N	11	4468	361	236
1363	92	2158744285	992	13	13	6	4	16323	91	129	17	4003	obsidian_destroyer	\N	15	10964	504	421
1364	91	2158744285	988	13	8	12	3	9412	80	130	6	2632	brewmaster	\N	16	8697	468	446
1365	103	2158744285	1008	13	5	9	3	9560	106	131	8	1122	doom_bringer	\N	16	8615	503	456
1366	100	2158744285	1000	13	3	14	1	9394	31	132	0	897	bounty_hunter	\N	13	5194	476	325
1367	91	2158848463	1001	14	8	18	9	7659	42	0	2	1065	visage	\N	18	16731	316	353
1368	95	2158848463	979	14	6	18	11	18804	71	1	0	620	tusk	\N	19	18393	321	387
1369	106	2158848463	987	14	5	23	7	16942	55	2	1	869	ogre_magi	\N	20	22583	322	447
1370	98	2158848463	992	14	8	15	11	30131	307	3	3	1614	ember_spirit	\N	24	18826	540	622
1371	93	2158848463	1000	14	9	10	6	17507	331	4	10	10394	drow_ranger	\N	23	16710	582	588
1372	96	2158848463	1015	-14	14	19	6	27777	180	128	4	783	ursa	\N	23	19499	436	602
1373	92	2158848463	1005	-14	8	16	7	22784	239	129	6	1721	death_prophet	\N	20	18182	416	456
1374	97	2158848463	1015	-14	9	17	10	14074	54	130	1	18	earth_spirit	\N	19	20131	309	388
1375	101	2158848463	995	-14	2	10	9	3941	99	131	7	209	shadow_shaman	\N	18	13635	285	357
1376	103	2158848463	1021	-14	11	16	7	24667	127	132	5	799	enchantress	\N	19	19596	356	421
1377	96	2159000477	1001	-8	6	6	9	17083	203	0	10	532	obsidian_destroyer	\N	19	16100	364	418
1378	97	2159000477	1001	-8	4	15	3	31115	369	1	7	1330	ember_spirit	\N	21	11951	484	480
1379	107	2159000477	1000	-8	4	11	11	8725	34	2	9	28	rubick	\N	15	13971	245	265
1380	106	2159000477	1001	-8	6	14	11	13367	57	3	2	548	disruptor	\N	15	19546	248	264
1381	101	2159000477	981	-8	4	6	7	9183	117	4	2	783	bristleback	\N	16	16951	267	308
1382	98	2159000477	1006	8	17	12	0	27255	329	128	18	2724	queenofpain	\N	25	8834	731	675
1383	92	2159000477	991	8	13	16	4	29083	400	129	20	12705	sven	\N	25	20854	707	675
1384	91	2159000477	1015	8	2	17	8	7783	116	130	3	2984	brewmaster	\N	19	19083	357	426
1385	100	2159000477	1013	8	5	15	2	3436	68	131	2	1876	witch_doctor	\N	19	7661	331	419
1386	95	2159000477	993	8	4	11	11	18355	29	132	1	884	pudge	\N	16	30434	297	315
1387	101	2160882034	973	10	5	24	13	15899	70	0	6	845	vengefulspirit	\N	19	24516	335	384
1388	95	2160882034	1001	10	15	14	10	32896	153	1	0	0	axe	\N	24	34810	446	602
1389	91	2160882034	1023	10	8	26	13	9051	59	2	3	2753	visage	\N	17	21000	329	297
1390	105	2160882034	987	10	3	20	13	19891	261	3	21	3648	drow_ranger	\N	22	24564	442	490
1391	92	2160882034	999	10	22	23	9	79421	310	4	9	2610	necrolyte	\N	25	33818	619	611
1392	97	2160882034	993	-10	1	25	15	25209	83	128	5	2561	chaos_knight	\N	20	36120	323	410
1393	108	2160882034	1000	-10	5	27	12	16631	29	129	8	1302	shadow_demon	\N	19	14909	313	366
1394	103	2160882034	1007	-10	15	20	7	45130	251	130	2	4389	skeleton_king	\N	23	37445	519	542
1395	109	2160882034	1000	-10	11	26	13	21518	78	131	4	1171	undying	\N	20	33316	376	408
1396	96	2160882034	993	-10	25	19	7	43102	131	132	2	4753	night_stalker	\N	25	48250	535	611
1397	110	2331151196	1000	10	3	13	5	7416	29	0	1	1501	vengefulspirit	\N	16	10074	344	329
1398	109	2331151196	990	10	3	6	5	11246	36	1	2	187	pudge	\N	13	13935	270	213
1399	97	2331151196	983	10	13	5	3	24597	265	2	12	10824	slark	\N	24	22552	702	697
1400	92	2331151196	1009	10	6	13	6	6770	114	3	1	1650	slardar	\N	19	12598	456	436
1401	111	2331151196	1000	10	9	9	2	23475	396	4	3	8233	phantom_assassin	\N	24	10136	751	680
1402	96	2331151196	983	-10	6	11	6	15353	213	128	7	621	invoker	\N	20	10844	498	501
1403	107	2331151196	992	-10	6	8	4	15870	333	129	10	2362	sven	\N	22	14086	497	586
1404	112	2331151196	1000	-10	2	10	9	7229	17	130	7	0	ancient_apparition	\N	12	11084	194	201
1405	113	2331151196	1000	-10	3	9	9	4370	24	131	0	173	lion	\N	12	13247	213	199
1406	95	2331151196	1011	-10	2	11	6	14530	133	132	1	86	tidehunter	\N	16	12300	313	335
1407	96	2331291800	973	-6	2	6	2	6499	186	0	1	108	antimage	\N	15	10993	398	449
1408	112	2331291800	990	-6	0	1	4	2282	17	1	0	0	techies	\N	9	3741	137	146
1409	113	2331291800	990	-6	1	8	6	5511	18	2	0	0	spirit_breaker	\N	10	12419	226	190
1410	110	2331291800	1010	-6	2	5	6	5569	66	3	4	54	invoker	\N	13	11982	297	332
1411	108	2331291800	990	-6	4	5	10	15575	80	4	3	72	phoenix	\N	14	12193	338	396
1412	111	2331291800	1010	6	2	7	1	8097	198	128	11	7683	terrorblade	\N	16	6760	547	484
1413	97	2331291800	993	6	8	6	1	13354	182	129	6	5925	windrunner	\N	18	6580	619	603
1414	92	2331291800	1019	6	3	13	3	7846	36	130	3	742	skeleton_king	\N	13	10094	362	344
1415	114	2331291800	1000	6	9	6	2	11659	17	131	3	358	lich	\N	13	5075	360	318
1416	95	2331291800	1001	6	2	6	3	10383	156	132	2	1076	bristleback	\N	15	6938	481	447
1417	97	2331397959	999	9	4	13	9	8500	24	0	8	1558	lion	\N	16	12037	311	331
1418	113	2331397959	984	9	7	19	6	13062	147	1	1	2886	bristleback	\N	19	19801	471	472
1419	112	2331397959	984	9	19	11	6	33075	94	2	1	1799	zuus	\N	20	13746	510	538
1420	95	2331397959	1007	9	8	21	9	21128	186	3	0	2819	bloodseeker	\N	19	17789	495	488
1421	111	2331397959	1016	9	8	13	3	26842	315	4	7	13555	slark	\N	25	29440	724	774
1422	96	2331397959	967	-9	7	13	5	14775	264	128	24	221	invoker	\N	21	19641	548	556
1423	110	2331397959	1004	-9	4	9	14	4121	21	129	1	0	witch_doctor	\N	13	14908	198	224
1424	92	2331397959	1025	-9	15	10	6	43796	310	130	26	1722	spectre	\N	23	21972	586	667
1425	114	2331397959	1006	-9	3	12	9	9016	16	131	1	0	lich	\N	13	13660	197	236
1426	108	2331397959	984	-9	2	8	12	12235	67	132	1	41	tidehunter	\N	16	23556	251	351
1427	95	2331504469	1016	-6	1	9	15	10433	111	0	1	0	axe	\N	15	26208	281	318
1428	96	2331504469	958	-6	4	5	11	10941	239	1	21	196	nevermore	\N	20	23325	482	557
1429	113	2331504469	993	-6	2	9	14	5557	22	2	2	0	lion	\N	11	18278	204	195
1430	97	2331504469	1008	-6	6	8	7	32661	245	3	0	1553	ember_spirit	\N	22	23257	520	669
1431	108	2331504469	975	-6	6	6	11	10248	24	4	2	14	rubick	\N	17	15983	377	409
1432	114	2331504469	997	6	10	24	5	7453	21	128	2	2669	witch_doctor	\N	18	12209	415	433
1433	111	2331504469	1025	6	12	14	6	21998	221	129	1	6472	ursa	\N	21	20401	581	578
1434	92	2331504469	1016	6	15	23	7	22362	173	130	7	8993	viper	\N	22	19424	575	664
1435	110	2331504469	995	6	4	21	1	13314	67	131	1	2370	winter_wyvern	\N	17	5178	379	413
1436	112	2331504469	993	6	15	29	2	41759	103	132	3	1352	zuus	\N	21	12463	517	609
1437	96	2461818948	952	11	16	14	8	50774	500	0	8	1870	shredder	\N	25	43925	683	540
1438	97	2461818948	1002	11	10	23	9	34441	220	1	0	3224	bristleback	\N	25	45473	482	549
1439	115	2461818948	1000	11	1	12	17	6436	22	2	2	34	bane	\N	15	21209	208	209
1440	98	2461818948	1014	11	16	20	6	40610	409	3	16	9290	invoker	\N	25	25508	651	540
1441	113	2461818948	987	11	2	23	12	8315	56	4	9	368	ogre_magi	\N	21	28042	263	390
1442	95	2461818948	1010	-11	7	24	11	14748	249	128	0	670	slardar	\N	24	25379	365	528
1443	108	2461818948	969	-11	4	22	14	24683	103	129	5	222	riki	\N	20	21054	260	360
1444	106	2461818948	993	-11	11	22	10	55084	317	130	18	2898	slark	\N	25	60305	451	543
1445	92	2461818948	1022	-11	22	21	7	52533	326	131	11	1698	storm_spirit	\N	25	31841	554	541
1446	109	2461818948	1000	-11	7	15	3	26636	240	132	8	295	lion	\N	24	11524	386	517
1447	92	2461941311	1011	5	4	7	3	9929	98	0	2	684	bristleback	\N	14	12314	435	475
1448	97	2461941311	1013	5	1	11	1	7503	18	1	0	589	lich	\N	12	4819	283	366
1449	115	2461941311	1011	5	2	13	1	3968	23	2	2	400	ancient_apparition	\N	11	2717	295	271
1450	98	2461941311	1025	5	14	2	0	14299	284	3	15	4849	sven	\N	19	3631	923	889
1451	109	2461941311	989	5	5	15	1	13017	89	4	24	1979	viper	\N	15	7127	456	571
1452	106	2461941311	982	-5	3	1	5	11083	79	128	12	595	dragon_knight	\N	13	15943	342	411
1453	96	2461941311	963	-5	0	3	2	17884	135	129	7	69	skeleton_king	\N	12	17422	357	370
1454	95	2461941311	999	-5	0	1	7	3014	53	130	0	0	elder_titan	\N	9	10216	208	233
1455	108	2461941311	958	-5	3	1	8	7151	3	131	0	0	silencer	\N	7	8447	191	146
1456	113	2461941311	998	-5	0	2	5	2516	72	132	0	0	alchemist	\N	9	7728	292	212
1457	115	2462017743	1016	5	5	20	10	8094	40	0	2	1183	vengefulspirit	\N	16	14262	327	392
1458	109	2462017743	994	5	16	17	2	29669	80	1	9	3380	skeleton_king	\N	21	22472	505	650
1459	97	2462017743	1018	5	4	14	6	4502	123	2	1	976	beastmaster	\N	16	13781	408	376
1460	98	2462017743	1030	5	11	22	2	23504	223	3	5	4549	life_stealer	\N	23	15426	639	809
1461	116	2462017743	1000	5	3	25	7	17608	143	4	5	568	venomancer	\N	16	17233	416	413
1462	95	2462017743	994	-5	4	9	7	14027	33	128	0	103	oracle	\N	11	10613	215	199
1463	96	2462017743	958	-5	6	8	7	42974	183	129	6	1097	huskar	\N	18	39864	479	524
1464	106	2462017743	977	-5	2	15	8	2966	24	130	0	567	witch_doctor	\N	13	13188	211	259
1465	108	2462017743	953	-5	7	13	11	19159	101	131	9	244	necrolyte	\N	15	18013	318	364
1466	113	2462017743	993	-5	7	9	6	24428	180	132	13	261	bristleback	\N	21	22079	511	672
1467	96	2794477637	953	10	13	3	4	25810	441	0	7	18601	luna	\N	24	12511	809	738
1468	111	2794477637	1031	10	9	8	7	28683	153	1	5	2578	dragon_knight	\N	18	27352	467	457
1469	92	2794477637	1016	10	5	13	11	18604	60	2	2	3379	shadow_demon	\N	14	11317	345	272
1470	106	2794477637	972	10	6	16	4	12967	25	3	2	406	lion	\N	19	9199	342	465
1471	97	2794477637	1023	10	2	15	6	11574	117	4	0	1990	slardar	\N	19	15238	395	492
1472	116	2794477637	1005	-10	13	13	6	21700	162	128	13	661	death_prophet	\N	21	30736	454	588
1473	115	2794477637	1021	-10	1	19	10	12289	18	129	0	15	pudge	\N	13	26019	182	228
1474	95	2794477637	989	-10	2	11	14	22641	140	130	0	274	centaur	\N	16	35170	306	343
1475	105	2794477637	997	-10	5	7	3	20830	359	131	29	0	kunkka	\N	23	10314	566	679
1476	117	2794477637	1000	-10	11	15	4	11948	75	132	4	0	silencer	\N	15	9190	328	328
1477	96	2794553406	963	5	5	10	1	7635	221	0	17	11251	luna	\N	16	3809	728	598
1478	97	2794553406	1033	5	3	17	2	6601	45	1	0	1910	spirit_breaker	\N	13	8170	395	385
1479	111	2794553406	1041	5	7	8	2	12109	121	2	2	4246	juggernaut	\N	15	8525	561	507
1480	106	2794553406	982	5	3	12	3	5084	24	3	2	2000	shadow_demon	\N	12	5280	363	357
1481	92	2794553406	1026	5	7	10	2	5796	122	4	0	957	venomancer	\N	14	6125	543	452
1482	117	2794553406	990	-5	4	2	1	9422	36	128	9	0	ancient_apparition	\N	11	1614	268	289
1483	115	2794553406	1011	-5	0	3	9	2117	15	129	0	0	mirana	\N	8	6968	141	136
1484	95	2794553406	979	-5	0	5	3	4917	55	130	1	96	weaver	\N	11	8509	242	327
1485	105	2794553406	987	-5	2	3	6	5015	122	131	32	0	phantom_assassin	\N	13	8008	350	360
1486	116	2794553406	995	-5	4	2	6	10438	114	132	6	0	death_prophet	\N	13	12126	358	408
1487	96	2794609120	968	15	20	17	3	38067	207	0	8	439	tinker	\N	22	5672	795	866
1488	95	2794609120	974	15	8	14	7	15106	100	1	0	653	bloodseeker	\N	16	12275	470	463
1489	105	2794609120	982	15	8	8	1	8455	348	2	25	22474	luna	\N	22	6111	849	837
1490	106	2794609120	987	15	2	13	5	6528	36	3	0	1033	ogre_magi	\N	14	10721	360	381
1491	115	2794609120	1006	15	10	15	8	15413	27	4	5	203	rattletrap	\N	15	11320	413	414
1492	97	2794609120	1038	-15	3	8	10	3698	59	128	0	0	faceless_void	\N	13	21127	256	302
1493	111	2794609120	1046	-15	4	15	12	19713	114	129	5	25	sniper	\N	15	18836	410	431
1494	116	2794609120	990	-15	6	6	7	9782	149	130	29	0	drow_ranger	\N	18	16328	477	594
1495	117	2794609120	985	-15	1	10	11	6222	5	131	4	25	crystal_maiden	\N	9	13191	160	170
1496	92	2794609120	1031	-15	8	5	10	6684	32	132	0	0	visage	\N	14	14087	364	361
1497	118	2794661867	1000	9	4	26	9	23079	260	0	3	35	enigma	\N	21	17474	347	345
1498	96	2794661867	983	9	12	28	8	71627	913	1	2	13374	naga_siren	\N	25	30996	818	497
1499	95	2794661867	989	9	4	27	10	33407	223	2	0	465	tidehunter	\N	25	31224	396	486
1500	111	2794661867	1031	9	22	17	5	54731	463	3	8	5442	morphling	\N	25	34778	595	489
1501	105	2794661867	997	9	7	25	8	14257	58	4	11	451	rubick	\N	21	19314	284	349
1502	117	2794661867	970	-9	5	13	9	10038	54	128	11	168	vengefulspirit	\N	21	21313	262	347
1503	106	2794661867	1002	-9	13	18	6	44497	457	129	7	3787	spectre	\N	25	55834	541	483
1504	97	2794661867	1023	-9	12	9	9	36149	339	130	5	9257	windrunner	\N	25	43435	507	483
1505	116	2794661867	975	-9	6	21	16	22794	283	131	1	464	dark_seer	\N	21	36592	369	345
1506	115	2794661867	1021	-9	4	19	11	20308	156	132	0	56	sand_king	\N	21	39927	321	368
1507	96	2996445772	992	7	15	16	7	39432	304	0	10	20780	tiny	\N	25	37196	632	552
1508	135	2996445772	1000	7	13	24	9	31950	151	1	3	483	enigma	\N	25	22280	532	551
1509	136	2996445772	1000	7	3	35	9	17432	161	2	2	1396	dark_seer	\N	25	24468	441	550
1510	106	2996445772	993	7	3	33	6	18616	84	3	2	972	ogre_magi	\N	25	27014	411	550
1511	111	2996445772	1040	7	10	22	8	42631	256	4	16	1880	necrolyte	\N	25	31962	539	550
1512	117	2996445772	961	-7	4	21	6	11349	95	128	5	1173	night_stalker	\N	23	21685	362	485
1513	115	2996445772	1012	-7	8	19	11	37398	213	129	6	1035	death_prophet	\N	25	32931	410	550
1514	104	2996445772	990	-7	15	14	8	47860	248	130	1	2790	bloodseeker	\N	25	36573	547	564
1515	127	2996445772	1000	-7	6	20	10	27847	151	131	5	789	bristleback	\N	23	30147	340	456
1516	97	2996445772	1014	-7	6	8	9	18466	298	132	23	2327	morphling	\N	24	28725	434	512
1517	96	2996520603	999	6	22	14	6	57742	286	0	14	346	tinker	\N	25	15161	687	683
1518	135	2996520603	1007	6	1	29	8	12925	169	1	5	6456	centaur	\N	22	21026	435	506
1519	106	2996520603	1000	6	5	32	10	20284	44	2	1	1382	spirit_breaker	\N	23	23188	413	571
1520	136	2996520603	1007	6	6	22	10	5595	15	3	0	845	bounty_hunter	\N	20	15858	377	419
1521	111	2996520603	1047	6	12	13	6	27752	305	4	19	9928	lone_druid	\N	25	15030	677	671
1522	104	2996520603	983	-6	6	12	6	17243	73	128	0	0	nyx_assassin	\N	23	16927	406	553
1523	115	2996520603	1005	-6	5	15	9	17322	144	129	3	0	ember_spirit	\N	21	19627	415	481
1524	117	2996520603	954	-6	1	14	14	7503	32	130	0	0	rubick	\N	17	17881	283	321
1525	97	2996520603	1007	-6	10	13	11	19878	199	131	5	0	queenofpain	\N	24	33557	485	617
1526	98	2996520603	1035	-6	18	12	7	38821	47	132	0	0	pudge	\N	25	46810	475	672
1527	96	2996574726	1005	5	3	11	5	36512	655	0	6	18938	naga_siren	\N	25	21238	789	500
1528	135	2996574726	1013	5	4	8	13	22465	72	1	0	314	phoenix	\N	24	23593	384	463
1529	136	2996574726	1013	5	2	9	8	6038	48	2	2	287	lion	\N	21	14603	316	341
1530	111	2996574726	1053	5	11	12	17	43662	296	3	1	233	shredder	\N	25	53611	521	501
1531	98	2996574726	1029	5	17	10	4	58349	336	4	12	3997	invoker	\N	25	26043	665	500
1532	117	2996574726	948	-5	11	14	3	25316	111	128	3	35	ancient_apparition	\N	25	25235	459	517
1533	115	2996574726	999	-5	9	13	7	28271	452	129	7	785	abyssal_underlord	\N	25	41031	603	500
1534	106	2996574726	1006	-5	16	13	11	42440	323	130	0	393	phantom_assassin	\N	25	42684	565	508
1535	97	2996574726	1001	-5	5	13	12	14542	91	131	1	42	earth_spirit	\N	21	28490	254	331
1536	104	2996574726	977	-5	5	16	4	53818	224	132	0	0	pudge	\N	25	54885	497	500
1537	96	3000196297	1010	5	11	12	3	19710	217	0	17	7603	nevermore	\N	23	7172	715	754
1538	135	3000196297	1018	5	5	16	3	11542	129	1	3	810	enigma	\N	21	4906	622	645
1539	98	3000196297	1034	5	13	4	1	22884	180	2	12	4347	slark	\N	23	14063	681	812
1540	95	3000196297	998	5	3	14	4	9825	166	3	4	2551	abyssal_underlord	\N	19	9287	534	544
1541	152	3000196297	1000	5	6	12	3	3449	39	4	2	1439	witch_doctor	\N	17	4854	400	444
1542	117	3000196297	943	-5	1	3	7	3604	126	128	2	19	troll_warlord	\N	15	9503	325	367
1543	115	3000196297	994	-5	2	2	9	8682	112	129	8	72	magnataur	\N	15	17622	305	353
1544	113	3000196297	988	-5	3	5	7	4721	51	130	1	70	mirana	\N	14	9372	271	288
1545	109	3000196297	999	-5	4	2	8	5758	108	131	0	0	axe	\N	17	11273	335	440
1546	153	3000196297	1000	-5	3	5	8	9617	54	132	8	27	bounty_hunter	\N	14	11740	282	315
1547	95	3000306747	1003	-10	5	13	13	14582	94	0	2	0	sand_king	\N	16	18241	305	328
1548	106	3000306747	1001	-10	6	18	5	16470	73	1	2	159	ogre_magi	\N	19	17546	352	444
1549	111	3000306747	1058	-10	12	8	7	14363	133	2	5	0	bounty_hunter	\N	22	10758	522	587
1550	139	3000306747	1000	-10	7	5	7	7869	64	3	3	0	vengefulspirit	\N	18	12237	332	410
1551	92	3000306747	1016	-10	12	10	8	29498	182	4	9	2264	sniper	\N	21	13601	506	556
1552	135	3000306747	1023	10	1	14	14	7495	109	128	6	48	enigma	\N	17	14454	376	382
1553	96	3000306747	1015	10	11	10	4	25020	261	129	20	2399	morphling	\N	25	20120	640	787
1554	154	3000306747	1000	10	4	9	12	3786	44	130	4	200	witch_doctor	\N	18	14482	279	403
1555	98	3000306747	1039	10	16	12	7	24365	108	131	10	454	invoker	\N	24	17229	549	772
1556	113	3000306747	983	10	4	17	5	19362	69	132	3	171	centaur	\N	21	24142	342	535
1557	135	3000358491	1033	-14	1	10	5	11103	152	0	5	98	enigma	\N	18	11817	412	365
1558	154	3000358491	1010	-14	2	15	4	8324	43	1	2	293	crystal_maiden	\N	19	10093	250	390
1559	96	3000358491	1025	-14	5	12	6	15076	338	2	12	2570	nevermore	\N	24	15848	566	656
1560	111	3000358491	1048	-14	15	6	6	27045	265	3	14	2368	luna	\N	24	19426	555	638
1561	92	3000358491	1006	-14	4	19	8	9146	77	4	4	636	warlock	\N	18	16721	266	343
1562	95	3000358491	993	14	5	13	8	11650	66	128	4	1508	tusk	\N	18	12232	321	339
1563	106	3000358491	991	14	3	11	8	8619	75	129	3	464	ogre_magi	\N	22	18863	334	494
1564	98	3000358491	1049	14	15	9	1	37797	253	130	11	3964	phantom_assassin	\N	25	16304	666	671
1565	139	3000358491	990	14	1	8	7	4410	17	131	5	1016	vengefulspirit	\N	16	10139	251	280
1566	140	3000358491	1000	14	4	7	5	11429	238	132	13	8362	juggernaut	\N	23	13156	523	583
1567	96	3000419525	1011	5	8	17	7	41848	604	0	50	8705	antimage	\N	25	34652	709	438
1568	135	3000419525	1019	5	5	19	9	24322	210	1	4	335	enigma	\N	25	19811	446	439
1569	98	3000419525	1063	5	19	14	8	48131	409	2	25	2499	invoker	\N	25	30712	647	436
1570	154	3000419525	996	5	2	20	4	16178	314	3	0	537	dark_seer	\N	25	13083	457	437
1571	106	3000419525	1005	5	6	12	12	6955	86	4	1	691	witch_doctor	\N	25	21545	295	441
1572	117	3000419525	938	-5	5	8	7	20714	114	128	4	229	nyx_assassin	\N	25	19743	389	452
1573	155	3000419525	1000	-5	4	14	10	12699	165	129	7	0	crystal_maiden	\N	25	21531	375	436
1574	129	3000419525	1000	-5	17	5	12	49438	521	130	13	2729	nevermore	\N	25	26030	620	436
1575	156	3000419525	1000	-5	11	6	8	37280	377	131	16	1577	slark	\N	25	62653	500	439
1576	104	3000419525	972	-5	3	6	6	14462	284	132	0	0	earthshaker	\N	25	22267	426	436
1577	95	3001863568	1007	9	4	20	9	18333	59	0	0	1313	oracle	\N	25	21333	304	443
1578	154	3001863568	1001	9	7	11	10	18200	220	1	5	5216	abyssal_underlord	\N	25	27675	425	444
1579	135	3001863568	1024	9	3	18	10	11709	63	2	8	1087	lion	\N	24	18690	283	419
1580	96	3001863568	1016	9	11	16	5	70324	603	3	1	10303	alchemist	\N	25	69643	1028	449
1581	92	3001863568	992	9	11	14	9	63569	223	4	23	10990	chaos_knight	\N	25	68480	432	445
1582	129	3001863568	995	-9	10	20	8	41003	268	128	5	252	windrunner	\N	25	21528	403	449
1583	157	3001863568	1000	-9	2	22	10	13060	40	129	5	118	disruptor	\N	22	20847	266	335
1584	117	3001863568	933	-9	7	22	4	34520	243	130	11	390	silencer	\N	25	25676	479	444
1585	98	3001863568	1068	-9	14	10	8	31525	416	131	6	12638	legion_commander	\N	25	31367	532	443
1586	111	3001863568	1034	-9	9	18	7	33412	611	132	3	4168	luna	\N	25	30416	660	444
1587	135	3002034420	1033	6	1	9	2	4727	9	0	7	1308	ogre_magi	\N	14	4788	325	343
1588	96	3002034420	1025	6	5	8	4	6144	172	1	15	1741	storm_spirit	\N	18	8825	593	567
1589	95	3002034420	1016	6	5	13	3	10069	102	2	3	559	tidehunter	\N	16	8194	485	428
1590	92	3002034420	1001	6	1	10	2	5062	145	3	10	7045	lone_druid	\N	15	3617	569	412
1591	104	3002034420	967	6	9	9	1	9026	98	4	0	2981	bloodseeker	\N	19	4652	590	624
1592	117	3002034420	924	-6	5	4	4	5692	12	128	2	0	nyx_assassin	\N	13	7053	251	290
1593	98	3002034420	1059	-6	3	5	2	6061	113	129	0	405	night_stalker	\N	16	6473	394	432
1594	107	3002034420	982	-6	2	5	5	12224	109	130	5	111	slark	\N	16	12486	377	430
1595	140	3002034420	1014	-6	1	7	5	7748	122	131	5	394	death_prophet	\N	15	8815	375	413
1596	113	3002034420	993	-6	0	8	5	3056	7	132	1	32	witch_doctor	\N	11	4906	175	215
1597	135	3002118520	1039	-5	4	15	7	14807	151	0	3	219	enigma	\N	20	11524	354	324
1598	96	3002118520	1031	-5	13	9	7	48613	288	1	21	667	arc_warden	\N	25	40383	579	559
1599	116	3002118520	966	-5	3	13	9	17523	269	2	23	409	troll_warlord	\N	24	27978	425	521
1600	92	3002118520	1007	-5	3	18	9	20219	126	3	8	174	batrider	\N	22	22162	298	394
1601	117	3002118520	918	-5	2	13	7	7868	28	4	1	36	ogre_magi	\N	23	19428	265	430
1602	95	3002118520	1022	5	5	19	8	26562	231	128	5	2644	necrolyte	\N	25	27160	438	529
1603	98	3002118520	1053	5	10	4	3	31871	323	129	16	3148	slark	\N	25	26472	585	547
1604	104	3002118520	973	5	14	17	4	38733	256	130	2	9966	bloodseeker	\N	25	23133	601	533
1605	140	3002118520	1008	5	5	13	5	10909	114	131	3	1513	lion	\N	24	13387	394	506
1606	113	3002118520	987	5	4	17	6	19717	189	132	5	2137	bristleback	\N	24	25195	408	490
1607	98	3002216481	1058	-8	6	7	4	16639	207	0	30	405	skeleton_king	\N	22	33631	507	631
1608	104	3002216481	978	-8	5	4	11	7847	85	1	0	0	vengefulspirit	\N	20	15489	364	474
1609	135	3002216481	1034	-8	3	6	8	6890	34	2	2	244	phoenix	\N	15	14457	267	302
1610	140	3002216481	1013	-8	0	3	9	4551	45	3	1	0	tidehunter	\N	14	19218	218	270
1611	117	3002216481	913	-8	4	6	10	15885	137	4	6	0	viper	\N	20	23861	442	513
1612	96	3002216481	1026	8	14	20	2	37357	235	128	13	3080	spectre	\N	24	12630	688	712
1613	106	3002216481	1010	8	2	13	5	9697	35	129	4	716	ogre_magi	\N	16	11187	339	322
1614	116	3002216481	961	8	6	10	5	9394	57	130	8	835	ancient_apparition	\N	16	7297	423	352
1615	95	3002216481	1027	8	11	21	4	29503	101	131	3	627	zuus	\N	22	11433	492	586
1616	92	3002216481	1002	8	9	14	3	20705	231	132	3	10000	furion	\N	22	9265	691	610
1617	106	3008178398	1018	15	3	24	1	11880	23	0	1	1968	ogre_magi	\N	14	8625	329	324
1618	98	3008178398	1050	15	21	10	0	28382	216	1	94	10913	phantom_assassin	\N	22	9054	746	683
1619	97	3008178398	996	15	15	13	1	20570	108	2	5	5955	ember_spirit	\N	20	7707	557	564
1620	114	3008178398	1003	15	3	23	5	6671	9	3	0	1870	ancient_apparition	\N	14	5607	345	296
1621	117	3008178398	905	15	2	19	2	6525	62	4	1	1027	slardar	\N	17	9431	394	432
1622	96	3008178398	1034	-15	1	3	9	15565	166	128	3	39	alchemist	\N	16	24762	496	373
1623	95	3008178398	1035	-15	2	2	9	10011	79	129	0	0	bristleback	\N	12	12777	237	223
1624	154	3008178398	1010	-15	2	4	8	5370	5	130	3	12	dazzle	\N	11	11001	197	182
1625	91	3008178398	1033	-15	4	3	7	18628	104	131	22	641	chaos_knight	\N	15	23966	342	334
1626	161	3008178398	1000	-15	0	3	11	4611	24	132	5	0	vengefulspirit	\N	9	15283	176	151
1627	92	3008343435	1010	5	14	11	2	22696	177	0	12	8971	lone_druid	\N	21	8275	610	584
1628	106	3008343435	1033	5	4	9	4	7448	38	1	0	636	omniknight	\N	16	14049	344	358
1629	98	3008343435	1065	5	15	7	4	34064	258	2	25	5852	nevermore	\N	23	14919	760	743
1630	116	3008343435	969	5	1	18	3	6119	48	3	0	390	slardar	\N	17	13336	367	412
1631	154	3008343435	995	5	1	17	4	5955	15	4	3	416	ogre_magi	\N	14	10697	291	279
1632	117	3008343435	920	-5	1	8	9	9179	14	128	0	0	silencer	\N	10	8973	180	152
1633	96	3008343435	1019	-5	9	4	2	27797	238	129	21	912	arc_warden	\N	21	19782	696	617
1634	97	3008343435	1011	-5	4	6	5	13557	157	130	9	532	ember_spirit	\N	18	19515	378	457
1635	113	3008343435	992	-5	1	9	8	8993	82	131	0	31	bristleback	\N	16	16750	280	349
1636	95	3008343435	1020	-5	2	11	11	7572	34	132	4	0	spirit_breaker	\N	15	17084	226	319
1637	95	3008451294	1015	5	1	6	3	3709	107	0	3	1642	doom_bringer	\N	15	5607	452	402
1638	96	3008451294	1014	5	6	7	2	9969	156	1	9	4288	bloodseeker	\N	16	8014	568	465
1639	106	3008451294	1038	5	10	1	2	11762	159	2	28	3522	phantom_assassin	\N	16	5662	610	477
1640	114	3008451294	1018	5	2	11	0	3787	8	3	1	818	ogre_magi	\N	14	3241	348	364
1641	154	3008451294	1000	5	1	9	3	4629	10	4	4	1352	disruptor	\N	9	3255	236	180
1642	116	3008451294	974	-5	4	3	5	5363	15	128	1	0	skywrath_mage	\N	9	4564	233	181
1643	98	3008451294	1070	-5	1	6	4	4907	183	129	30	975	antimage	\N	16	7799	486	482
1644	92	3008451294	1015	-5	2	3	5	10676	112	130	25	618	queenofpain	\N	14	9318	369	381
1645	117	3008451294	915	-5	1	3	2	2198	22	131	0	0	earthshaker	\N	10	2951	225	213
1646	113	3008451294	987	-5	0	2	4	2635	40	132	1	0	tidehunter	\N	12	9224	213	254
1647	107	3008536849	976	12	9	19	9	17367	140	0	0	2481	slardar	\N	25	24726	500	614
1648	96	3008536849	1019	12	9	15	3	31945	292	1	9	5722	invoker	\N	25	13600	695	615
1649	92	3008536849	1010	12	1	24	5	12802	81	2	1	1515	elder_titan	\N	20	24093	354	394
1650	114	3008536849	1023	12	3	15	11	12044	29	3	3	1344	oracle	\N	20	17387	345	382
1651	116	3008536849	969	12	19	14	4	43918	269	4	9	14007	slark	\N	25	40850	664	621
1652	117	3008536849	910	-12	7	6	8	8349	158	128	4	312	broodmother	\N	23	21247	393	506
1653	106	3008536849	1043	-12	11	8	9	25309	208	129	5	2098	phantom_assassin	\N	22	28992	408	458
1654	95	3008536849	1020	-12	0	13	14	11716	36	130	4	269	ogre_magi	\N	17	26312	229	299
1655	98	3008536849	1065	-12	11	11	7	47412	315	131	36	636	sniper	\N	24	16936	551	599
1656	154	3008536849	1005	-12	3	14	4	13485	64	132	0	748	mirana	\N	17	10204	242	276
1677	117	3008858859	903	-7	6	8	10	9306	89	0	2	124	night_stalker	\N	21	23904	334	409
1678	96	3008858859	1026	-7	6	6	9	23296	280	1	16	1464	invoker	\N	23	18676	483	497
1679	106	3008858859	1036	-7	3	6	9	21271	209	2	4	1642	weaver	\N	22	20524	361	434
1680	129	3008858859	996	-7	3	11	16	20675	95	3	3	278	leshrac	\N	20	20827	274	371
1681	135	3008858859	1021	-7	2	11	7	17320	196	4	4	136	enigma	\N	20	13908	330	364
1682	95	3008858859	1013	7	7	26	4	24257	161	128	1	4004	tidehunter	\N	25	18922	419	586
1683	98	3008858859	1048	7	16	20	2	13742	91	129	5	1224	disruptor	\N	25	12162	468	587
1684	116	3008858859	976	7	14	18	5	29089	208	130	7	8672	life_stealer	\N	25	21191	557	585
1685	107	3008858859	973	7	2	17	6	9293	105	131	8	4233	vengefulspirit	\N	23	17028	359	474
1686	92	3008858859	1027	7	12	25	4	21458	228	132	5	6190	storm_spirit	\N	25	22565	527	593
1687	107	3010553346	980	-6	4	25	11	6957	62	0	5	795	witch_doctor	\N	23	29515	245	399
1688	92	3010553346	1034	-6	12	20	7	46343	370	1	18	6400	nevermore	\N	25	44129	514	467
1689	162	3010553346	1000	-6	3	30	5	25766	95	2	3	422	nyx_assassin	\N	25	32095	321	473
1690	98	3010553346	1055	-6	24	13	6	59450	480	3	31	2275	necrolyte	\N	25	50247	664	466
1691	113	3010553346	982	-6	4	20	16	6569	40	4	2	75	lion	\N	20	26740	209	296
1692	96	3010553346	1019	6	24	12	4	58777	521	128	18	18835	antimage	\N	25	32023	767	467
1693	91	3010553346	1018	6	4	22	12	20234	78	129	0	2008	enchantress	\N	23	25629	316	414
1694	114	3010553346	1035	6	3	30	18	11410	30	130	1	493	spirit_breaker	\N	22	35985	267	347
1695	95	3010553346	1020	6	2	32	11	23058	222	131	1	1797	abyssal_underlord	\N	25	27035	377	469
1696	106	3010553346	1029	6	11	28	4	69247	234	132	3	1015	zuus	\N	25	24413	495	468
1657	96	3008653479	1031	-15	7	16	5	35420	644	0	3	2378	naga_siren	\N	25	15236	671	551
1658	98	3008653479	1053	-15	12	15	2	35716	287	1	13	2930	morphling	\N	25	20472	553	547
1659	116	3008653479	981	-15	10	23	9	29648	204	2	4	0	phoenix	\N	25	23501	474	539
1660	135	3008653479	1026	-15	4	9	17	8794	53	3	2	198	lion	\N	20	18773	271	333
1661	107	3008653479	988	-15	6	5	13	14251	29	4	1	161	nyx_assassin	\N	18	16914	237	292
1662	95	3008653479	1008	15	13	7	9	29298	249	128	16	8427	clinkz	\N	25	28856	546	540
1663	106	3008653479	1031	15	2	22	9	19472	77	129	2	185	ogre_magi	\N	23	29622	346	464
1664	154	3008653479	993	15	4	23	7	12152	43	130	2	520	crystal_maiden	\N	22	15802	331	436
1665	92	3008653479	1022	15	12	13	9	30508	178	131	13	3859	queenofpain	\N	25	26692	491	548
1666	117	3008653479	898	15	13	21	5	3257	297	132	12	4299	lone_druid	\N	25	22648	680	544
1667	116	3008777193	966	10	1	20	6	6897	51	0	2	432	winter_wyvern	\N	16	14127	332	332
1668	96	3008777193	1016	10	8	10	5	29399	346	1	19	9743	terrorblade	\N	24	9202	759	750
1669	98	3008777193	1038	10	12	11	3	24644	203	2	25	10388	nevermore	\N	23	9640	646	707
1670	135	3008777193	1011	10	7	19	3	8893	30	3	1	395	witch_doctor	\N	22	7287	374	636
1671	129	3008777193	986	10	9	22	4	14104	111	4	13	1116	slardar	\N	22	19388	495	635
1672	117	3008777193	913	-10	4	13	10	13936	46	128	2	0	spirit_breaker	\N	18	14902	325	420
1673	95	3008777193	1023	-10	2	9	11	6631	116	129	0	154	axe	\N	16	19661	309	356
1674	106	3008777193	1046	-10	10	7	8	19947	222	130	17	1751	sven	\N	23	17392	539	673
1675	154	3008777193	1008	-10	1	7	5	6363	44	131	4	72	vengefulspirit	\N	16	10934	260	364
1676	92	3008777193	1037	-10	4	8	6	12385	164	132	5	757	magnataur	\N	22	20666	436	592
1707	117	3010796852	896	15	2	10	8	11876	131	0	2	1469	bristleback	\N	19	22319	422	415
1708	96	3010796852	1014	15	8	8	3	15829	246	1	6	1366	juggernaut	\N	25	11232	613	724
1709	98	3010796852	1060	15	20	3	1	36919	419	2	71	16012	antimage	\N	25	10094	984	732
1710	113	3010796852	965	15	2	9	8	3967	15	3	1	231	lion	\N	15	8403	324	275
1711	132	3010796852	1011	15	1	11	6	4276	32	4	0	520	winter_wyvern	\N	17	11533	303	347
1712	95	3010796852	1015	-15	7	6	8	15691	169	128	13	2050	clinkz	\N	22	20083	428	536
1713	106	3010796852	1046	-15	4	11	8	22239	195	129	3	17	zuus	\N	22	18866	406	583
1714	157	3010796852	1002	-15	5	5	5	21793	204	130	2	244	life_stealer	\N	21	25982	418	503
1715	135	3010796852	1014	-15	5	9	8	5758	47	131	5	0	witch_doctor	\N	14	9261	230	230
1716	109	3010796852	1005	-15	5	10	5	8835	77	132	0	84	nyx_assassin	\N	21	9410	361	499
1697	96	3010695767	1025	-11	24	12	9	76392	576	0	10	9671	slark	\N	25	98575	765	445
1698	95	3010695767	1026	-11	15	19	18	36794	71	1	4	309	nyx_assassin	\N	24	39713	390	439
1699	114	3010695767	1041	-11	7	25	17	18659	42	2	5	703	rubick	\N	25	28422	352	451
1700	92	3010695767	1028	-11	17	22	8	34136	278	3	14	7688	magnataur	\N	25	45564	506	447
1701	113	3010695767	976	-11	3	26	12	23013	46	4	2	626	ogre_magi	\N	25	37522	336	466
1702	132	3010695767	1000	11	3	26	22	14750	55	128	0	0	lion	\N	23	27183	333	376
1703	157	3010695767	991	11	15	16	12	42665	198	129	0	2989	axe	\N	25	40358	455	444
1704	98	3010695767	1049	11	18	24	11	44792	174	130	0	1480	doom_bringer	\N	25	39636	627	462
1705	106	3010695767	1035	11	12	34	14	98006	393	131	4	1953	zuus	\N	25	29632	545	447
1706	109	3010695767	994	11	13	21	10	35264	210	132	15	5220	slardar	\N	25	37866	491	447
1717	95	3012327928	1000	15	4	23	7	28096	118	0	2	1666	centaur	\N	21	25024	415	522
1718	96	3012327928	1029	15	23	17	0	38412	320	1	39	17232	morphling	\N	25	10792	868	792
1719	157	3012327928	987	15	4	33	6	10044	31	2	5	217	disruptor	\N	21	10068	410	566
1720	91	3012327928	1024	15	16	22	3	12772	77	3	6	939	visage	\N	20	13187	528	515
1721	117	3012327928	911	15	10	19	1	25306	24	4	0	1537	pudge	\N	18	18609	392	420
1722	107	3012327928	974	-15	3	6	9	10058	107	128	0	15	tidehunter	\N	15	17097	298	303
1723	98	3012327928	1075	-15	5	5	12	15414	178	129	13	93	obsidian_destroyer	\N	21	16617	434	541
1724	106	3012327928	1031	-15	3	8	13	11724	41	130	3	135	ogre_magi	\N	19	18032	279	443
1725	135	3012327928	999	-15	1	7	14	4854	10	131	3	58	rubick	\N	12	15751	191	201
1726	125	3012327928	1000	-15	4	5	9	23341	171	132	17	0	life_stealer	\N	18	34844	379	418
1727	96	3012422428	1044	15	17	15	5	29098	314	0	17	4872	nevermore	\N	25	16324	621	662
1728	106	3012422428	1016	15	3	10	11	8591	41	1	1	358	lion	\N	21	13275	283	440
1729	111	3012422428	1025	15	13	20	6	42726	221	2	18	2547	slark	\N	25	35190	514	648
1730	117	3012422428	926	15	8	14	11	13564	140	3	2	518	sand_king	\N	24	20070	426	583
1731	135	3012422428	984	15	5	17	5	11482	169	4	4	889	enigma	\N	23	9846	412	561
1732	98	3012422428	1060	-15	20	10	3	40460	317	128	25	3304	sniper	\N	25	14676	682	668
1733	140	3012422428	1005	-15	6	14	9	10097	62	129	8	311	slardar	\N	22	21690	363	504
1734	95	3012422428	1015	-15	7	12	12	13178	56	130	0	85	riki	\N	22	15440	328	468
1735	157	3012422428	1002	-15	1	16	15	9843	24	131	3	474	disruptor	\N	20	22275	266	393
1736	92	3012422428	1017	-15	4	15	9	10537	160	132	9	2164	troll_warlord	\N	21	20790	370	445
1737	95	3012523678	1000	7	1	16	4	14189	134	0	2	780	warlock	\N	19	9400	426	460
1738	96	3012523678	1059	7	13	8	2	24588	294	1	7	8183	antimage	\N	25	8685	741	791
1739	106	3012523678	1031	7	7	15	3	36109	149	2	0	1920	zuus	\N	22	6857	477	586
1740	157	3012523678	987	7	6	16	4	12780	83	3	1	455	spirit_breaker	\N	20	10233	410	511
1741	135	3012523678	999	7	1	15	7	5670	16	4	0	85	disruptor	\N	14	7891	264	268
1742	117	3012523678	941	-7	3	14	3	7258	59	128	1	284	undying	\N	17	17774	358	377
1743	98	3012523678	1045	-7	1	4	6	5537	35	129	2	276	lion	\N	16	9127	290	321
1744	111	3012523678	1040	-7	4	3	5	3702	197	130	11	3946	lycan	\N	19	22993	490	466
1745	140	3012523678	990	-7	7	6	7	11083	88	131	13	271	slardar	\N	18	21509	358	404
1746	92	3012523678	1002	-7	5	11	7	15628	152	132	9	71	death_prophet	\N	18	22075	414	421
1747	95	3012602214	1007	12	1	19	15	8918	37	0	1	440	lion	\N	19	21724	317	324
1748	111	3012602214	1033	12	11	19	8	53051	249	1	4	12973	dragon_knight	\N	25	47832	574	567
1749	106	3012602214	1038	12	4	21	7	13461	50	2	1	1116	disruptor	\N	21	14776	370	391
1750	157	3012602214	994	12	9	19	7	30587	219	3	2	3068	legion_commander	\N	25	26736	539	568
1751	107	3012602214	959	12	11	11	4	30209	221	4	13	2296	necrolyte	\N	25	18912	550	566
1752	92	3012602214	995	-12	3	22	10	14199	114	128	15	0	slardar	\N	20	29467	298	368
1753	96	3012602214	1066	-12	5	25	5	35475	578	129	8	4403	naga_siren	\N	25	24933	680	561
1754	98	3012602214	1038	-12	24	8	6	47462	281	130	12	611	phantom_assassin	\N	25	26933	593	561
1755	140	3012602214	983	-12	7	31	6	10967	40	131	2	82	bounty_hunter	\N	23	18875	372	502
1756	135	3012602214	1006	-12	0	21	10	3912	40	132	4	0	dazzle	\N	20	18053	242	362
1757	95	3012695636	1019	11	18	34	12	112825	186	0	1	839	zuus	\N	25	27312	458	404
1758	106	3012695636	1050	11	13	31	12	95629	355	1	8	3926	spectre	\N	25	47046	520	406
1759	157	3012695636	1006	11	8	30	17	44213	103	2	6	466	ancient_apparition	\N	25	24784	396	407
1760	117	3012695636	934	11	14	27	4	9849	444	3	3	5598	lone_druid	\N	25	22906	673	404
1761	113	3012695636	980	11	3	28	8	32093	66	4	0	982	disruptor	\N	25	17382	346	408
1762	107	3012695636	971	-11	3	12	17	10057	149	128	6	377	winter_wyvern	\N	23	41558	286	351
1767	106	3013953614	1061	-12	25	33	15	110392	525	0	18	3342	spectre	\N	25	68665	630	377
1763	96	3012695636	1054	-11	14	8	13	102229	714	129	5	2691	meepo	\N	25	185600	723	404
1764	98	3012695636	1026	-11	25	8	4	78997	475	130	14	6765	slark	\N	25	76673	642	404
1765	135	3012695636	994	-11	3	29	7	18008	387	131	2	834	dark_seer	\N	25	34265	467	404
1766	92	3012695636	983	-11	7	13	20	34110	65	132	0	30	pudge	\N	23	60484	302	363
1768	111	3013953614	1045	-12	13	18	17	51594	535	1	7	3413	sven	\N	25	68020	561	367
1769	157	3013953614	1017	-12	8	38	13	70489	399	2	7	4427	bristleback	\N	25	88362	515	378
1770	114	3013953614	1030	-12	20	33	20	24661	46	3	2	200	witch_doctor	\N	25	54620	367	367
1771	113	3013953614	991	-12	3	32	22	22914	101	4	1	307	disruptor	\N	25	39226	312	367
1772	129	3013953614	989	12	17	41	14	61018	404	128	5	8710	magnataur	\N	25	47923	636	367
1773	96	3013953614	1043	12	14	40	8	94784	627	129	3	2982	shredder	\N	25	65795	698	367
1774	163	3013953614	1000	12	8	41	21	34689	152	130	2	967	lion	\N	25	35110	427	372
1775	132	3013953614	1026	12	17	29	15	66366	60	131	4	996	pudge	\N	25	89368	394	366
1776	91	3013953614	1039	12	28	12	16	85224	302	132	12	5863	phantom_assassin	\N	25	65042	514	368
1777	95	3014167185	1030	7	4	14	5	7055	82	0	2	1923	undying	\N	17	12257	409	419
1778	96	3014167185	1055	7	18	11	2	33341	230	1	14	5828	slark	\N	25	23764	742	918
1779	157	3014167185	1005	7	6	12	10	8387	55	2	3	1079	ogre_magi	\N	19	13677	397	529
1780	111	3014167185	1033	7	2	12	1	25513	239	3	4	6359	alchemist	\N	22	21858	825	717
1781	163	3014167185	1012	7	1	15	8	7868	33	4	1	852	bane	\N	14	8251	295	316
1782	91	3014167185	1051	-7	6	11	4	25550	176	128	9	2751	sven	\N	19	20356	458	536
1783	129	3014167185	1001	-7	6	10	8	11595	81	129	1	341	spirit_breaker	\N	15	18332	329	339
1784	98	3014167185	1015	-7	8	9	4	5107	52	130	5	39	witch_doctor	\N	18	6791	337	464
1785	132	3014167185	1038	-7	4	6	9	17040	124	131	2	0	axe	\N	15	14283	328	329
1786	113	3014167185	979	-7	1	9	8	4714	19	132	0	177	lion	\N	9	6601	209	151
1787	91	3014257086	1044	9	4	14	7	6168	25	0	0	497	visage	\N	18	11335	381	352
1788	96	3014257086	1062	9	15	15	2	26261	247	1	14	5166	invoker	\N	25	13941	700	708
1789	95	3014257086	1037	9	7	16	7	17126	109	2	1	585	elder_titan	\N	23	19013	441	621
1790	98	3014257086	1008	9	23	4	0	35064	399	3	73	12315	antimage	\N	25	4978	957	708
1791	113	3014257086	972	9	1	10	10	2460	8	4	0	516	shadow_shaman	\N	12	11467	268	183
1792	132	3014257086	1031	-9	8	5	8	15705	124	128	4	0	clinkz	\N	22	14775	379	517
1793	129	3014257086	994	-9	6	6	12	17968	208	129	45	743	gyrocopter	\N	20	20524	424	434
1794	106	3014257086	1049	-9	2	12	10	5580	48	130	0	0	ancient_apparition	\N	16	11279	277	288
1795	157	3014257086	1012	-9	2	5	13	6029	59	131	7	199	warlock	\N	17	21569	300	329
1796	163	3014257086	1019	-9	8	6	7	15452	99	132	1	0	faceless_void	\N	22	18932	379	543
1797	132	3014358368	1022	-6	6	4	5	7091	24	0	1	21	witch_doctor	\N	18	12271	275	419
1798	116	3014358368	983	-6	2	4	8	7696	141	1	19	132	slark	\N	17	22978	329	367
1799	98	3014358368	1017	-6	9	5	4	27743	224	2	35	0	sniper	\N	22	12978	541	649
1800	157	3014358368	1003	-6	0	9	6	5945	37	3	4	0	disruptor	\N	14	11016	239	286
1801	91	3014358368	1053	-6	4	4	9	17617	55	4	13	0	rattletrap	\N	15	23324	248	301
1802	129	3014358368	985	6	8	4	3	19468	222	128	35	2173	skeleton_king	\N	23	18609	572	683
1803	96	3014358368	1071	6	3	12	1	39657	340	129	2	5572	alchemist	\N	25	32567	961	816
1804	95	3014358368	1046	6	9	4	7	14379	125	130	1	264	bloodseeker	\N	19	13591	411	455
1805	106	3014358368	1040	6	2	7	4	7670	25	131	2	296	rubick	\N	16	7975	272	342
1806	163	3014358368	1010	6	9	7	6	18150	45	132	1	265	nyx_assassin	\N	21	10107	377	587
1807	116	3014446376	977	15	5	35	10	37418	203	0	3	4174	centaur	\N	25	42384	381	466
1808	92	3014446376	972	15	17	14	9	34305	364	1	28	4059	juggernaut	\N	25	32793	539	470
1809	157	3014446376	997	15	7	27	9	16324	102	2	1	1644	silencer	\N	24	27794	354	462
1810	129	3014446376	991	15	18	14	10	54376	444	3	20	16687	nevermore	\N	25	23295	612	468
1811	98	3014446376	1011	15	16	28	2	59561	130	4	2	1476	pudge	\N	25	53532	529	476
1812	96	3014446376	1077	-15	13	14	6	52191	583	128	15	11826	antimage	\N	25	32658	757	468
1813	106	3014446376	1046	-15	5	27	14	15458	76	129	1	503	spirit_breaker	\N	24	37374	306	447
1814	91	3014446376	1047	-15	4	15	19	15717	44	130	0	356	disruptor	\N	21	27972	321	338
1815	95	3014446376	1052	-15	4	24	8	14976	205	131	1	2308	abyssal_underlord	\N	25	31561	400	466
1816	132	3014446376	1016	-15	14	16	16	49388	141	132	0	178	zuus	\N	25	40351	397	466
1817	106	3014586927	1031	6	3	12	2	5225	20	0	1	1342	ogre_magi	\N	13	6601	284	288
1818	95	3014586927	1037	6	5	12	2	8177	121	1	5	1871	faceless_void	\N	19	5936	502	574
1819	92	3014586927	987	6	3	19	0	12124	126	2	11	6513	dragon_knight	\N	16	5533	448	421
1820	163	3014586927	1016	6	3	15	4	5232	41	3	0	1032	witch_doctor	\N	13	5856	329	283
1821	98	3014586927	1026	6	18	7	0	21320	189	4	39	4064	bloodseeker	\N	23	2322	747	806
1822	116	3014586927	992	-6	1	4	6	5620	97	128	4	0	windrunner	\N	13	11599	290	297
1823	96	3014586927	1062	-6	4	0	4	5755	199	129	23	98	antimage	\N	18	8561	480	511
1824	114	3014586927	1018	-6	0	5	8	4356	23	130	1	0	rubick	\N	10	8227	163	188
1825	107	3014586927	960	-6	1	1	8	1942	59	131	0	0	slardar	\N	12	12938	238	233
1826	132	3014586927	1001	-6	1	4	7	6614	29	132	0	0	winter_wyvern	\N	9	8792	179	166
1827	96	3016359318	1056	13	8	20	6	52804	481	0	10	168	tinker	\N	25	13109	581	447
1828	129	3016359318	1006	13	10	22	12	21037	101	1	1	1036	spirit_breaker	\N	25	32660	347	452
1829	157	3016359318	1012	13	10	17	10	23185	335	2	5	8667	weaver	\N	25	24654	504	468
1830	155	3016359318	995	13	0	11	17	2542	52	3	0	0	shadow_shaman	\N	23	21963	264	365
1831	92	3016359318	993	13	18	11	5	35389	434	4	30	11672	juggernaut	\N	25	20511	652	448
1832	95	3016359318	1043	-13	2	17	13	9784	204	128	2	910	night_stalker	\N	25	36206	320	451
1833	98	3016359318	1032	-13	24	13	4	68027	477	129	26	4388	phantom_assassin	\N	25	30334	718	444
1834	91	3016359318	1032	-13	15	16	7	9467	270	130	7	633	visage	\N	25	25800	581	448
1835	164	3016359318	1000	-13	4	14	11	8484	78	131	5	166	disruptor	\N	22	20740	245	340
1836	163	3016359318	1022	-13	5	18	12	17135	107	132	1	366	lion	\N	23	21877	316	378
1837	106	3016597449	1037	7	0	17	8	8126	45	0	2	603	ogre_magi	\N	20	17326	299	387
1838	98	3016597449	1019	7	9	3	0	20699	555	1	34	16026	antimage	\N	25	7603	925	640
1839	129	3016597449	1019	7	2	17	7	12041	49	2	1	1452	shadow_demon	\N	19	10242	307	383
1840	92	3016597449	1006	7	6	9	8	23404	147	3	9	199	shredder	\N	21	19922	410	449
1841	91	3016597449	1019	7	16	7	6	47219	182	4	19	9758	dragon_knight	\N	25	48820	560	647
1842	95	3016597449	1030	-7	1	8	10	8940	79	128	1	27	phoenix	\N	19	13198	299	370
1843	113	3016597449	981	-7	3	16	7	11768	86	129	1	0	sand_king	\N	20	17168	298	417
1844	107	3016597449	954	-7	19	6	3	32305	261	130	10	819	phantom_assassin	\N	25	19534	575	641
1845	114	3016597449	1012	-7	2	14	9	7398	9	131	0	0	disruptor	\N	16	15683	222	277
1846	96	3016597449	1069	-7	2	16	4	25602	240	132	8	334	legion_commander	\N	22	28006	419	480
1847	106	3016673220	1044	5	11	14	5	9608	52	0	3	1145	witch_doctor	\N	22	12316	344	419
1848	98	3016673220	1026	5	13	10	2	32097	388	1	3	1663	bloodseeker	\N	25	18438	651	529
1849	129	3016673220	1026	5	10	25	4	37359	326	2	9	6444	skeleton_king	\N	25	32009	609	559
1850	95	3016673220	1023	5	2	20	8	16359	113	3	1	351	elder_titan	\N	22	15143	319	417
1851	92	3016673220	1013	5	7	14	7	27410	344	4	5	8309	leshrac	\N	25	24138	567	528
1852	114	3016673220	1005	-5	1	7	12	8509	26	128	1	0	ogre_magi	\N	16	20736	209	232
1853	96	3016673220	1062	-5	11	7	5	42287	503	129	6	496	ember_spirit	\N	25	27417	604	529
1854	116	3016673220	986	-5	6	9	2	25710	300	130	45	362	morphling	\N	24	25463	429	493
1855	163	3016673220	1009	-5	3	10	10	17937	172	131	2	44	tidehunter	\N	24	29444	331	489
1856	113	3016673220	974	-5	3	11	14	7401	19	132	1	0	disruptor	\N	17	19573	228	252
1857	95	3016745235	1028	11	13	12	4	21555	166	0	9	16814	clinkz	\N	22	12562	615	606
1858	98	3016745235	1031	11	19	10	0	27311	232	1	36	2502	bloodseeker	\N	24	11308	719	732
1859	106	3016745235	1049	11	5	23	1	13309	76	2	9	1091	ogre_magi	\N	22	8208	439	584
1860	163	3016745235	1004	11	6	13	3	10782	72	3	4	1634	faceless_void	\N	19	10053	405	460
1861	114	3016745235	1000	11	4	20	5	10320	50	4	7	2019	ancient_apparition	\N	19	6039	494	450
1862	132	3016745235	995	-11	1	6	7	10468	14	128	0	0	undying	\N	14	15290	231	265
1863	96	3016745235	1057	-11	6	2	7	18092	224	129	19	105	slark	\N	22	20860	492	610
1864	111	3016745235	1040	-11	0	6	12	6128	75	130	1	0	omniknight	\N	14	22654	256	266
1865	129	3016745235	1031	-11	5	2	10	15862	141	131	15	266	nevermore	\N	17	19208	336	368
1866	92	3016745235	1018	-11	1	4	11	4840	21	132	3	52	lion	\N	10	12485	172	150
1867	135	3020583453	983	-6	2	6	10	4681	35	0	1	14	lion	\N	15	12458	229	259
1868	95	3020583453	1039	-6	1	9	5	7092	99	1	0	0	tidehunter	\N	18	14503	288	337
1869	129	3020583453	1020	-6	5	8	7	16062	222	2	41	1083	life_stealer	\N	23	21531	474	578
1870	98	3020583453	1042	-6	14	5	4	26298	326	3	10	2477	invoker	\N	25	13696	674	673
1871	113	3020583453	969	-6	3	13	12	5995	36	4	0	0	spirit_breaker	\N	14	18237	238	236
1872	116	3020583453	981	6	3	17	7	13145	69	128	0	1221	nyx_assassin	\N	21	12664	354	453
1873	96	3020583453	1046	6	7	17	3	24932	350	129	4	3894	ember_spirit	\N	25	7932	690	674
1874	106	3020583453	1060	6	5	23	4	9289	34	130	2	1095	ogre_magi	\N	21	12305	324	488
1875	92	3020583453	1007	6	18	7	3	26494	385	131	52	15592	juggernaut	\N	25	16895	775	671
1876	157	3020583453	1025	6	4	21	8	6565	45	132	3	267	disruptor	\N	16	10332	336	298
1877	135	3020726832	977	13	5	9	15	7854	36	0	1	0	lion	\N	20	22093	282	295
1878	96	3020726832	1052	13	12	17	1	65573	698	1	3	16441	naga_siren	\N	25	20299	852	492
1879	95	3020726832	1033	13	6	20	12	19113	77	2	0	401	tusk	\N	23	29367	348	392
1880	92	3020726832	1013	13	12	10	9	25039	350	3	26	941	juggernaut	\N	25	30633	520	483
1881	113	3020726832	963	13	3	21	9	12574	16	4	0	215	ogre_magi	\N	22	23385	305	376
1882	114	3020726832	1011	-13	2	29	11	34559	184	128	6	1736	centaur	\N	25	46192	378	484
1883	116	3020726832	987	-13	27	9	2	49637	358	129	8	10531	templar_assassin	\N	25	19323	652	484
1884	106	3020726832	1066	-13	4	33	6	15460	59	130	3	1041	disruptor	\N	24	24555	359	446
1885	157	3020726832	1031	-13	2	26	11	12516	49	131	13	1414	vengefulspirit	\N	22	21009	280	384
1886	99	3020726832	1018	-13	11	18	9	29891	309	132	4	9855	weaver	\N	25	35360	529	482
1897	132	3021019294	984	14	3	11	11	10778	17	0	3	443	lion	\N	20	15492	276	359
1898	98	3021019294	1030	14	8	26	9	39536	65	1	1	260	pudge	\N	23	40514	387	522
1899	116	3021019294	968	14	13	18	5	43506	408	2	23	14650	luna	\N	25	21666	681	586
1900	106	3021019294	1059	14	17	19	4	36774	216	3	1	6072	queenofpain	\N	25	20225	566	588
1901	157	3021019294	1012	14	10	18	5	33501	162	4	7	2890	slardar	\N	25	35817	486	597
1902	96	3021019294	1071	-14	13	13	5	83270	502	128	1	3551	alchemist	\N	25	72585	1025	596
1903	113	3021019294	982	-14	6	17	11	15656	29	129	0	0	spirit_breaker	\N	21	27135	256	402
1904	99	3021019294	1011	-14	4	16	11	11166	55	130	1	0	disruptor	\N	21	21314	296	391
1905	95	3021019294	1040	-14	2	8	13	10103	70	131	3	0	sand_king	\N	16	26550	222	252
1906	92	3021019294	1032	-14	7	5	12	19751	334	132	36	560	juggernaut	\N	24	22743	514	580
1887	99	3020905680	1005	6	1	12	11	12573	56	0	0	0	nyx_assassin	\N	18	17453	324	355
1888	96	3020905680	1065	6	5	9	3	57981	392	1	2	12786	alchemist	\N	25	58395	1009	687
1889	106	3020905680	1053	6	3	7	10	3390	77	2	1	90	shadow_shaman	\N	18	14871	348	343
1890	92	3020905680	1026	6	8	3	2	14810	342	3	30	7049	juggernaut	\N	25	11819	689	697
1891	113	3020905680	976	6	4	6	8	4213	44	4	1	371	spirit_breaker	\N	14	14878	335	215
1892	135	3020905680	990	-6	7	10	7	8767	22	128	3	600	lion	\N	16	10356	283	298
1893	98	3020905680	1036	-6	2	19	2	11433	84	129	4	297	disruptor	\N	21	8682	386	481
1894	116	3020905680	974	-6	10	10	5	19073	344	130	22	6021	luna	\N	23	13828	618	618
1895	157	3020905680	1018	-6	3	11	3	15433	138	131	9	1111	slardar	\N	21	20608	375	477
1896	95	3020905680	1046	-6	11	13	4	34875	148	132	4	390	zuus	\N	21	11658	411	485
1907	132	3021150471	998	-9	2	7	9	19881	110	0	1	0	sniper	\N	16	14728	341	301
1908	98	3021150471	1044	-9	9	1	3	16149	219	1	2	597	necrolyte	\N	23	11795	527	601
1909	99	3021150471	997	-9	0	1	11	11268	166	2	1	0	shredder	\N	17	21988	284	340
1910	157	3021150471	1026	-9	0	5	10	6752	205	3	28	540	drow_ranger	\N	19	15027	387	406
1911	113	3021150471	968	-9	0	6	6	7041	16	4	0	0	ancient_apparition	\N	12	9320	202	186
1912	116	3021150471	982	9	6	13	3	13307	289	128	19	25532	luna	\N	22	14196	667	556
1913	129	3021150471	1014	9	6	16	3	9693	75	129	5	1887	slardar	\N	21	16931	418	510
1914	96	3021150471	1057	9	16	14	0	31673	239	130	5	6065	phantom_assassin	\N	25	12840	716	733
1915	114	3021150471	998	9	7	10	3	11187	22	131	2	1375	ogre_magi	\N	15	13270	396	289
1916	164	3021150471	987	9	3	5	3	5840	48	132	4	2845	shadow_demon	\N	14	2696	344	251
1917	135	3022990507	984	5	8	14	2	12114	183	0	8	907	enigma	\N	22	5905	456	561
1918	96	3022990507	1066	5	17	18	3	46941	349	1	17	5780	slark	\N	25	30704	706	705
1919	95	3022990507	1026	5	11	19	3	29195	150	2	1	752	zuus	\N	24	8350	455	649
1920	114	3022990507	1007	5	5	29	6	25043	70	3	8	988	centaur	\N	23	25569	378	578
1921	155	3022990507	1008	5	5	13	7	9827	76	4	3	1043	crystal_maiden	\N	20	7203	350	437
1922	99	3022990507	988	-5	6	9	10	24794	260	128	21	906	nevermore	\N	22	30692	481	562
1923	98	3022990507	1035	-5	6	10	7	8620	72	129	4	34	disruptor	\N	18	16332	283	369
1924	107	3022990507	947	-5	8	4	8	18333	210	130	20	919	juggernaut	\N	21	18271	430	473
1925	157	3022990507	1017	-5	0	5	11	4661	98	131	8	0	slardar	\N	16	23384	250	302
1926	113	3022990507	959	-5	1	9	10	3008	13	132	0	0	dazzle	\N	13	16126	160	197
1927	135	3023089967	989	5	7	18	9	11540	62	0	7	215	ogre_magi	\N	22	21038	323	387
1928	96	3023089967	1071	5	9	13	1	53802	852	1	6	19891	naga_siren	\N	25	12486	983	494
1929	95	3023089967	1031	5	12	10	10	37947	215	2	5	758	necrolyte	\N	25	31998	445	492
1930	114	3023089967	1012	5	3	20	11	12085	34	3	3	489	rubick	\N	22	21353	338	396
1931	103	3023089967	997	5	6	15	14	17784	185	4	0	574	sand_king	\N	25	34572	460	505
1932	97	3023089967	1006	-5	9	15	4	33612	376	128	26	1384	viper	\N	25	28809	507	495
1933	98	3023089967	1030	-5	16	22	1	20116	56	129	0	0	riki	\N	25	13227	358	494
1934	107	3023089967	942	-5	9	14	12	27703	131	130	23	0	rattletrap	\N	24	32494	338	453
1935	99	3023089967	983	-5	6	16	10	27438	487	131	8	1100	phantom_lancer	\N	25	31045	588	493
1936	157	3023089967	1012	-5	5	21	10	12578	134	132	3	15	vengefulspirit	\N	25	27583	343	491
1937	98	3023257102	1025	-5	2	0	2	2275	128	0	50	14	antimage	\N	13	3031	421	454
1938	97	3023257102	1001	-5	2	3	3	8740	60	1	2	0	windrunner	\N	11	5943	300	310
1939	99	3023257102	978	-5	1	2	4	4174	8	2	0	0	shadow_demon	\N	8	4197	171	188
1940	157	3023257102	1007	-5	0	1	4	1675	50	3	0	0	slardar	\N	9	4541	249	257
1941	94	3023257102	990	-5	0	1	7	1243	20	4	0	0	undying	\N	8	7252	186	195
1942	95	3023257102	1036	5	2	9	2	3072	7	128	3	447	witch_doctor	\N	8	3885	223	209
1943	96	3023257102	1076	5	3	7	3	6503	103	129	5	0	legion_commander	\N	14	7950	460	477
1944	129	3023257102	1023	5	12	4	0	11282	101	130	25	1805	phantom_assassin	\N	14	1724	571	479
1945	164	3023257102	996	5	0	4	0	1907	24	131	6	510	tidehunter	\N	11	2557	239	302
1946	135	3023257102	994	5	3	10	0	2164	8	132	5	100	lion	\N	9	1955	245	254
1947	96	3025296499	1081	15	16	7	1	31816	376	0	59	14603	morphling	\N	25	12312	835	763
1948	116	3025296499	991	15	5	13	5	14039	180	1	25	1322	invoker	\N	24	14881	512	723
1949	157	3025296499	1002	15	6	13	8	15900	115	2	2	683	tidehunter	\N	21	17069	416	524
1950	164	3025296499	1001	15	3	16	4	11879	44	3	1	382	rubick	\N	17	6763	330	353
1951	107	3025296499	937	15	4	16	2	10569	76	4	1	621	ogre_magi	\N	20	10546	357	467
1952	129	3025296499	1028	-15	4	4	10	18192	165	128	31	1251	bloodseeker	\N	18	19124	392	395
1953	114	3025296499	1017	-15	4	10	5	13560	124	129	10	89	magnataur	\N	20	15545	381	477
1954	95	3025296499	1041	-15	6	8	6	6887	33	130	5	419	witch_doctor	\N	15	13426	236	300
1955	135	3025296499	999	-15	2	10	6	8992	145	131	11	141	enigma	\N	20	10624	352	462
1956	111	3025296499	1029	-15	4	9	8	13940	145	132	0	0	doom_bringer	\N	22	25484	488	578
1957	96	3025348109	1096	5	15	14	2	40775	410	0	25	7958	slark	\N	25	32275	717	605
1958	132	3025348109	989	5	15	21	8	29349	106	1	1	508	zuus	\N	21	15456	418	417
1959	164	3025348109	1016	5	5	12	5	7427	17	2	3	324	lion	\N	20	5036	301	384
1960	107	3025348109	952	5	4	15	2	13893	130	3	1	2056	ogre_magi	\N	24	11372	424	576
1961	95	3025348109	1026	5	2	25	3	14835	241	4	5	5080	abyssal_underlord	\N	23	14343	464	524
1962	129	3025348109	1013	-5	7	6	8	22564	153	128	12	1273	windrunner	\N	21	18455	336	408
1963	116	3025348109	1006	-5	7	7	7	23048	317	129	25	475	luna	\N	22	20756	468	468
1964	157	3025348109	1017	-5	1	4	10	3062	111	130	3	0	faceless_void	\N	18	24731	266	306
1965	140	3025348109	971	-5	3	9	9	13271	21	131	1	22	shadow_demon	\N	15	13587	205	239
1966	135	3025348109	984	-5	2	10	9	2047	17	132	1	0	shadow_shaman	\N	15	14260	186	228
1967	157	3027083936	1012	5	4	20	6	10330	198	0	7	3792	slardar	\N	24	17604	449	569
1968	96	3027083936	1101	5	21	16	5	46638	404	1	22	9444	slark	\N	25	39533	721	605
1969	95	3027083936	1031	5	12	26	1	47523	167	2	5	1650	zuus	\N	25	8301	444	597
1970	106	3027083936	1073	5	1	22	8	6765	48	3	0	1912	lion	\N	21	11174	311	425
1971	107	3027083936	957	5	3	27	3	16994	104	4	2	2043	ogre_magi	\N	22	15963	392	472
1972	129	3027083936	1008	-5	5	12	7	24673	240	128	15	5112	nevermore	\N	20	26166	426	374
1973	164	3027083936	1021	-5	5	12	7	27246	27	129	0	0	phoenix	\N	18	15646	264	301
1974	135	3027083936	979	-5	6	9	14	10296	14	130	7	665	witch_doctor	\N	18	23230	257	300
1975	98	3027083936	1020	-5	2	12	5	5330	94	131	1	814	dazzle	\N	21	15262	318	427
1976	114	3027083936	1002	-5	4	12	10	10742	167	132	16	5429	dragon_knight	\N	20	33658	388	394
1977	107	3027168796	962	-5	6	5	5	12380	254	0	4	4001	clinkz	\N	23	17927	484	583
1978	98	3027168796	1015	-5	5	22	2	20245	82	1	1	21	ogre_magi	\N	19	11254	318	409
1979	157	3027168796	1017	-5	9	7	8	15649	163	2	20	555	legion_commander	\N	20	21379	395	427
1980	95	3027168796	1036	-5	5	12	9	20718	55	3	5	0	rattletrap	\N	14	17403	243	230
1981	114	3027168796	997	-5	7	9	11	9261	19	4	4	127	bane	\N	16	17057	236	304
1982	135	3027168796	974	5	2	10	8	5754	19	128	2	634	witch_doctor	\N	16	10526	234	295
1983	96	3027168796	1106	5	3	13	8	19124	289	129	6	0	tinker	\N	22	11215	572	555
1984	106	3027168796	1078	5	7	16	6	20158	92	130	0	3355	slardar	\N	23	31152	427	597
1985	164	3027168796	1016	5	0	12	6	4606	12	131	1	322	winter_wyvern	\N	17	8757	243	326
1986	129	3027168796	1003	5	22	12	4	40213	254	132	19	7116	phantom_assassin	\N	25	21438	697	705
1987	106	3027253660	1083	8	9	13	6	26144	244	0	11	21497	luna	\N	22	17295	688	674
1988	132	3027253660	994	8	6	4	7	10823	107	1	0	186	axe	\N	18	12466	460	419
1989	98	3027253660	1010	8	11	8	6	10237	56	2	6	117	ogre_magi	\N	22	7855	481	629
1990	95	3027253660	1031	8	2	13	8	14680	69	3	3	1268	abaddon	\N	18	18601	389	438
1991	114	3027253660	992	8	2	14	7	7700	82	4	6	2968	windrunner	\N	18	11366	425	423
1992	96	3027253660	1111	-8	12	9	4	19263	257	128	29	541	nevermore	\N	25	11778	654	834
1993	135	3027253660	979	-8	2	18	7	10367	136	129	4	25	enigma	\N	16	9869	317	354
1994	140	3027253660	966	-8	3	10	7	7661	61	130	6	0	slardar	\N	17	19412	271	399
1995	129	3027253660	1008	-8	13	5	6	21593	199	131	14	420	phantom_assassin	\N	24	15231	534	767
1996	164	3027253660	1021	-8	3	13	6	4862	10	132	7	0	vengefulspirit	\N	15	9457	222	314
1997	135	3027302752	971	7	1	17	7	11677	223	0	2	1025	dark_seer	\N	20	12827	443	402
1998	96	3027302752	1103	7	11	8	5	26681	434	1	2	10986	meepo	\N	25	36035	721	611
1999	129	3027302752	1000	7	18	4	3	29523	325	2	17	7332	juggernaut	\N	25	13417	704	611
2000	167	3027302752	1000	7	3	13	10	14527	230	3	0	1626	crystal_maiden	\N	24	16468	572	556
2001	109	3027302752	990	7	7	15	5	14059	32	4	20	356	ogre_magi	\N	21	13735	364	405
2002	132	3027302752	1002	-7	5	13	12	24597	143	128	5	274	lich	\N	23	19514	402	546
2003	168	3027302752	1000	-7	15	2	4	34323	312	129	4	2121	life_stealer	\N	25	32274	595	612
2004	140	3027302752	958	-7	4	12	7	12892	84	130	7	81	lion	\N	23	11246	389	519
2005	164	3027302752	1013	-7	1	8	11	3178	16	131	1	56	shadow_shaman	\N	15	13076	187	234
2006	95	3027302752	1039	-7	4	10	8	20307	69	132	0	0	nyx_assassin	\N	21	23172	323	410
2007	116	3028769261	1001	5	21	16	1	33391	188	0	1	9194	phantom_assassin	\N	25	15219	692	739
2008	106	3028769261	1091	5	13	19	4	23890	215	1	17	10905	weaver	\N	24	15758	681	655
2009	95	3028769261	1032	5	7	14	4	10160	82	2	2	2829	slardar	\N	22	15003	435	543
2010	107	3028769261	957	5	1	12	6	6236	67	3	4	650	ogre_magi	\N	18	9964	395	388
2011	114	3028769261	1000	5	4	21	7	4504	20	4	5	3253	witch_doctor	\N	19	11840	340	411
2012	99	3028769261	973	-5	7	5	8	19332	273	128	16	2065	lone_druid	\N	22	18289	541	554
2013	98	3028769261	1018	-5	7	5	5	14667	327	129	26	1483	faceless_void	\N	25	12730	692	728
2014	129	3028769261	1007	-5	1	9	11	9579	86	130	2	53	mirana	\N	15	13890	255	271
2015	157	3028769261	1012	-5	5	6	10	17447	56	131	7	0	nyx_assassin	\N	18	19286	292	392
2016	135	3028769261	978	-5	2	6	13	6759	18	132	0	0	vengefulspirit	\N	12	13986	193	191
2017	107	3029116101	962	5	3	17	3	11840	96	0	7	3681	ogre_magi	\N	22	10331	440	509
2018	96	3029116101	1110	5	18	13	1	36688	326	1	52	15647	morphling	\N	25	16947	811	688
2019	116	3029116101	1006	5	18	14	7	35515	205	2	14	6406	phantom_assassin	\N	25	18752	661	689
2020	95	3029116101	1037	5	1	22	9	11717	124	3	2	499	abyssal_underlord	\N	19	17160	400	413
2021	169	3029116101	1000	5	1	12	3	12151	83	4	0	889	keeper_of_the_light	\N	20	10368	396	418
2022	135	3029116101	973	-5	0	13	13	7099	23	128	2	0	lion	\N	16	20416	220	301
2023	98	3029116101	1013	-5	9	5	3	26003	294	129	11	1771	invoker	\N	25	16406	621	698
2024	104	3029116101	970	-5	7	7	7	15608	158	130	21	333	ursa	\N	21	32291	416	486
2025	170	3029116101	1000	-5	1	9	8	16723	79	131	1	107	shredder	\N	18	22373	254	350
2026	109	3029116101	997	-5	6	10	10	8125	71	132	2	63	shadow_shaman	\N	15	16425	270	276
2027	129	3029210893	1002	5	8	9	3	10508	141	0	6	696	magnataur	\N	19	8330	497	531
2028	96	3029210893	1115	5	12	8	2	26075	276	1	23	4936	slark	\N	24	16790	702	861
2029	155	3029210893	1013	5	5	18	1	9722	49	2	1	457	crystal_maiden	\N	18	6894	352	505
2030	167	3029210893	1007	5	0	8	3	6606	135	3	2	682	winter_wyvern	\N	19	5755	451	537
2031	109	3029210893	992	5	4	11	3	3462	95	4	12	304	slardar	\N	17	6852	387	458
2032	132	3029210893	995	-5	0	4	9	6989	74	128	1	0	tidehunter	\N	13	13033	230	278
2033	98	3029210893	1008	-5	6	2	3	12921	186	129	12	967	invoker	\N	22	7741	566	752
2034	168	3029210893	993	-5	4	0	5	5588	122	130	6	0	phantom_assassin	\N	15	8107	347	373
2035	135	3029210893	968	-5	0	5	5	4676	107	131	3	0	enigma	\N	14	5729	301	313
2036	170	3029210893	995	-5	2	4	8	6534	32	132	1	0	ogre_magi	\N	12	13850	223	218
2037	96	3069482442	1120	-5	13	12	9	50309	440	0	18	4469	terrorblade	\N	25	23853	607	496
2038	129	3069482442	1007	-5	11	8	12	40149	293	1	14	1952	nevermore	\N	25	36673	453	530
2039	107	3069482442	967	-5	6	10	8	21043	65	2	2	0	ogre_magi	\N	24	33601	306	456
2040	135	3069482442	963	-5	0	14	9	3199	32	3	2	118	dazzle	\N	20	21867	216	304
2041	109	3069482442	997	-5	4	9	11	28172	102	4	0	44	nyx_assassin	\N	25	23391	340	500
2042	106	3069482442	1096	5	4	32	8	14919	109	128	1	1823	rubick	\N	25	22662	405	503
2043	98	3069482442	1003	5	21	14	6	68973	420	129	59	621	bloodseeker	\N	25	37586	684	496
2044	157	3069482442	1007	5	1	29	9	12265	75	130	1	1288	disruptor	\N	24	21253	309	479
2045	116	3069482442	1011	5	19	12	5	32763	347	131	22	20220	templar_assassin	\N	25	22987	654	508
2046	95	3069482442	1042	5	1	25	7	6579	100	132	1	946	slardar	\N	25	34498	312	501
2047	107	3069593212	962	-5	7	22	7	9200	111	0	5	257	dazzle	\N	22	15342	280	403
2048	98	3069593212	1008	-5	18	14	9	54234	375	1	6	2710	meepo	\N	25	93658	580	536
2049	95	3069593212	1047	-5	2	23	10	33533	209	2	0	143	centaur	\N	21	47471	306	382
2050	157	3069593212	1012	-5	1	14	10	7393	96	3	4	14	ogre_magi	\N	22	20598	294	423
2051	116	3069593212	1016	-5	14	13	7	26807	241	4	11	1585	invoker	\N	25	26652	489	543
2052	129	3069593212	1002	5	18	9	7	38937	401	128	17	10955	juggernaut	\N	25	13187	691	534
2053	96	3069593212	1115	5	9	16	9	51705	474	129	8	2582	ember_spirit	\N	25	17954	668	537
2054	135	3069593212	958	5	6	19	7	22554	48	130	4	60	lion	\N	23	10309	346	457
2055	106	3069593212	1101	5	3	25	16	18554	72	131	1	1549	spirit_breaker	\N	22	30235	303	404
2056	109	3069593212	992	5	6	20	5	26697	80	132	8	251	nyx_assassin	\N	25	14208	382	562
2057	106	3075313946	1106	8	4	17	11	18886	157	0	2	1238	doom_bringer	\N	23	30318	424	449
2058	98	3075313946	1003	8	11	14	1	24564	245	1	1	2942	earthshaker	\N	25	13521	532	541
2059	109	3075313946	997	8	7	11	5	30514	299	2	24	11026	life_stealer	\N	25	32164	513	534
2060	114	3075313946	1005	8	7	24	8	28081	100	3	4	2850	centaur	\N	23	28886	369	466
2061	157	3075313946	1007	8	8	17	5	21474	255	4	0	2376	axe	\N	24	19695	453	484
2062	96	3075313946	1120	-8	14	13	3	38330	390	128	12	384	necrolyte	\N	25	25192	518	524
2063	164	3075313946	1006	-8	0	14	7	6615	23	129	0	0	ogre_magi	\N	19	13326	201	297
2064	116	3075313946	1011	-8	9	10	9	31855	381	130	36	303	phantom_assassin	\N	25	25252	503	525
2065	135	3075313946	963	-8	4	7	12	9054	58	131	1	0	witch_doctor	\N	17	13703	191	250
2066	170	3075313946	990	-8	2	21	6	15588	205	132	3	0	slardar	\N	24	22904	341	510
2067	129	3075486152	1007	15	33	16	13	77805	206	0	5	7126	monkey_king	\N	25	56429	474	383
2068	109	3075486152	1005	15	2	24	9	32234	308	1	2	1365	keeper_of_the_light	\N	25	27437	427	376
2069	106	3075486152	1114	15	1	27	10	45320	206	2	7	3467	slardar	\N	25	72445	376	375
2070	135	3075486152	955	15	3	21	18	18170	88	3	6	231	disruptor	\N	24	30552	261	352
2071	107	3075486152	957	15	15	16	8	55026	456	4	7	9740	slark	\N	25	78565	546	375
2072	157	3075486152	1015	-15	15	17	11	69177	610	128	9	1939	juggernaut	\N	25	40405	584	375
2073	96	3075486152	1112	-15	20	21	11	64694	571	129	15	1259	storm_spirit	\N	25	35676	566	375
2074	164	3075486152	998	-15	2	24	13	18110	132	130	1	618	jakiro	\N	25	26427	272	382
2075	98	3075486152	1011	-15	12	30	12	26872	66	131	1	0	riki	\N	25	22163	325	377
2076	114	3075486152	1013	-15	9	25	14	47347	414	132	10	327	axe	\N	25	64656	440	380
2077	98	3077353510	996	-11	9	10	3	23418	140	0	1	128	ogre_magi	\N	25	13471	321	479
2078	96	3077353510	1097	-11	15	14	9	65527	534	1	11	1151	slark	\N	25	54736	584	480
2079	116	3077353510	1003	-11	8	15	11	33925	360	2	29	913	viper	\N	25	27798	423	479
2080	114	3077353510	998	-11	4	23	9	28522	292	3	13	622	bristleback	\N	25	35278	382	479
2081	105	3077353510	1006	-11	5	20	8	12443	68	4	6	155	rubick	\N	21	11660	259	320
2082	129	3077353510	1022	11	18	13	6	42861	283	128	3	3890	bloodseeker	\N	25	28495	516	480
2083	91	3077353510	1026	11	8	18	12	21052	103	129	13	1417	rattletrap	\N	24	30327	330	440
2084	109	3077353510	1020	11	7	14	3	42248	322	130	58	13210	life_stealer	\N	25	45630	529	488
2085	157	3077353510	1000	11	3	22	14	9806	46	131	0	836	disruptor	\N	22	18392	287	380
2086	175	3077353510	1000	11	3	23	8	16272	215	132	3	1640	magnataur	\N	25	30287	479	485
2087	109	3077525860	1031	15	9	26	10	13906	95	0	6	5746	skeleton_king	\N	23	26889	371	541
2088	98	3077525860	985	15	7	13	4	19859	283	1	11	2148	windrunner	\N	25	9115	553	622
2089	175	3077525860	1011	15	14	14	3	21868	292	2	11	15001	omniknight	\N	25	18338	695	617
2090	157	3077525860	1011	15	5	15	11	17372	34	3	0	1301	pudge	\N	21	23139	310	419
2091	105	3077525860	995	15	4	18	0	13711	224	4	2	1910	shredder	\N	25	8501	451	617
2092	129	3077525860	1033	-15	10	6	12	24535	138	128	13	888	monkey_king	\N	18	19152	314	338
2093	96	3077525860	1086	-15	6	7	5	16974	363	129	42	3740	phantom_lancer	\N	24	15250	536	591
2094	116	3077525860	992	-15	4	12	9	13430	200	130	0	254	slardar	\N	22	17900	363	465
2095	91	3077525860	1037	-15	1	11	5	8164	52	131	2	124	lion	\N	14	9544	199	221
2096	114	3077525860	987	-15	4	10	8	15252	18	132	4	126	ogre_magi	\N	17	17243	251	300
2097	96	3077715640	1071	10	9	16	6	55985	349	0	13	194	tinker	\N	25	9365	530	526
2098	105	3077715640	1010	10	4	10	10	14409	122	1	7	526	sand_king	\N	24	21429	315	481
2099	98	3077715640	1000	10	3	16	6	11563	171	2	0	0	keeper_of_the_light	\N	25	12543	385	530
2100	175	3077715640	1026	10	11	6	8	49084	322	3	11	4180	sven	\N	25	37134	573	544
2101	157	3077715640	1026	10	2	16	8	31237	240	4	8	4182	centaur	\N	25	36858	399	530
2102	106	3077715640	1129	-10	11	11	8	27271	216	128	7	0	slardar	\N	25	43692	392	525
2103	111	3077715640	1014	-10	8	16	4	33678	211	129	2	636	night_stalker	\N	25	39690	415	527
2104	116	3077715640	977	-10	5	12	8	16742	335	130	16	2253	lone_druid	\N	24	27745	457	505
2105	91	3077715640	1022	-10	6	18	2	8170	70	131	1	167	dazzle	\N	21	12040	249	375
2106	176	3077715640	1000	-10	6	15	7	18543	35	132	2	0	disruptor	\N	21	26186	264	350
2107	116	3077845335	967	6	9	13	1	17902	258	0	43	12270	luna	\N	23	7990	734	786
2108	96	3077845335	1081	6	16	7	1	21971	282	1	30	12394	nevermore	\N	23	6346	785	791
2109	106	3077845335	1119	6	2	11	2	10199	117	2	0	1436	slardar	\N	19	13182	423	519
2110	114	3077845335	972	6	5	16	4	8054	18	3	5	359	vengefulspirit	\N	16	7350	344	374
2111	176	3077845335	990	6	1	14	5	2974	8	4	2	1087	ogre_magi	\N	16	5915	287	372
2112	157	3077845335	1036	-6	4	5	9	7542	32	128	2	0	silencer	\N	12	9820	202	237
2113	175	3077845335	1036	-6	1	6	6	9167	120	129	3	0	magnataur	\N	17	13974	316	412
2114	129	3077845335	1018	-6	4	4	6	11909	211	130	43	84	phantom_assassin	\N	17	11317	427	437
2115	111	3077845335	1004	-6	1	5	6	7284	117	131	0	0	legion_commander	\N	17	14676	317	416
2116	107	3077845335	972	-6	3	6	8	4091	35	132	5	0	rubick	\N	14	10523	233	292
2117	157	3077914435	1030	-12	9	19	14	17957	103	0	4	28	night_stalker	\N	24	31702	328	518
2118	96	3077914435	1087	-12	6	14	15	46079	327	1	5	0	tinker	\N	25	25917	420	557
2119	129	3077914435	1012	-12	11	19	11	16679	147	2	10	118	slardar	\N	25	35464	355	527
2120	107	3077914435	966	-12	7	19	14	15828	132	3	0	36	ancient_apparition	\N	23	20623	382	473
2121	175	3077914435	1030	-12	13	11	10	62679	294	4	32	239	chaos_knight	\N	25	62531	539	528
2122	98	3077914435	1010	12	10	31	7	24237	79	128	4	422	disruptor	\N	25	20057	360	528
2123	116	3077914435	973	12	26	22	5	60797	245	129	13	6286	obsidian_destroyer	\N	25	23514	606	524
2124	106	3077914435	1125	12	20	17	6	54477	299	130	8	10073	slark	\N	25	47079	587	525
2125	114	3077914435	978	12	4	27	10	34294	145	131	5	528	centaur	\N	25	45214	360	542
2126	176	3077914435	996	12	3	35	19	10563	57	132	1	112	spirit_breaker	\N	23	31489	290	451
2127	95	3078009474	1042	-15	5	22	7	11731	141	0	2	379	slardar	\N	25	26386	287	422
2128	116	3078009474	985	-15	18	13	11	47601	434	1	15	247	obsidian_destroyer	\N	25	32438	539	423
2129	106	3078009474	1137	-15	8	17	7	35485	527	2	11	12443	weaver	\N	25	25818	555	423
2130	175	3078009474	1018	-15	6	22	3	20215	303	3	0	724	enigma	\N	25	18514	490	423
2131	176	3078009474	1008	-15	5	22	8	10782	54	4	1	449	shadow_demon	\N	22	17794	244	340
2132	96	3078009474	1075	15	13	12	5	46609	463	128	25	3124	invoker	\N	25	32102	569	421
2133	114	3078009474	990	15	1	11	15	9541	53	129	1	294	lion	\N	25	17234	314	421
2134	129	3078009474	1000	15	3	7	7	10560	385	130	3	3135	sven	\N	25	29665	426	424
2135	98	3078009474	1022	15	19	8	3	38073	752	131	14	13218	antimage	\N	25	10909	845	421
2136	107	3078009474	954	15	0	19	13	34009	242	132	7	515	centaur	\N	25	53746	359	421
2137	107	3079846890	969	14	2	11	1	7870	78	0	3	2590	abaddon	\N	19	8000	325	387
2138	96	3079846890	1090	14	10	10	2	29937	286	1	12	61	tinker	\N	25	10815	628	709
2139	129	3079846890	1015	14	10	9	1	21156	325	2	57	12100	phantom_assassin	\N	24	5992	698	635
2140	92	3079846890	1018	14	1	12	2	4452	121	3	10	2174	slardar	\N	20	9177	360	425
2141	105	3079846890	1020	14	3	8	4	4078	12	4	8	1561	lion	\N	15	6378	273	274
2142	116	3079846890	970	-14	4	3	6	11746	192	128	16	207	obsidian_destroyer	\N	19	14960	344	388
2143	106	3079846890	1122	-14	4	3	7	7082	226	129	15	6683	troll_warlord	\N	20	18315	391	426
2144	98	3079846890	1037	-14	0	7	3	3810	133	130	3	0	ogre_magi	\N	16	8700	277	314
2145	109	3079846890	1046	-14	1	4	4	7795	100	131	2	121	nyx_assassin	\N	17	9374	236	350
2146	157	3079846890	1018	-14	1	7	6	13341	138	132	9	207	centaur	\N	16	19556	271	315
2147	157	3079950374	1004	10	3	9	6	6710	132	0	8	1283	slardar	\N	20	14488	410	480
2148	96	3079950374	1104	10	17	9	3	39817	271	1	28	7763	slark	\N	25	20582	674	735
2149	107	3079950374	983	10	2	16	5	5469	74	2	2	827	omniknight	\N	20	11361	354	452
2150	105	3079950374	1034	10	2	15	4	5820	48	3	4	698	shadow_shaman	\N	18	7348	299	374
2151	129	3079950374	1029	10	7	11	4	25596	315	4	32	10067	nevermore	\N	24	11946	652	718
2152	92	3079950374	1032	-10	8	5	8	14896	224	128	59	2013	juggernaut	\N	22	16814	475	582
2153	106	3079950374	1108	-10	5	6	8	12385	145	129	5	0	tidehunter	\N	20	18562	338	450
2154	98	3079950374	1023	-10	5	9	4	9249	63	130	2	78	winter_wyvern	\N	18	10128	270	403
2155	111	3079950374	998	-10	3	12	2	13775	228	131	8	684	medusa	\N	22	9611	419	566
2156	114	3079950374	1005	-10	1	9	11	5388	5	132	3	46	ogre_magi	\N	14	18265	174	264
2157	96	3080043012	1114	12	17	21	5	52577	314	0	14	3674	phantom_assassin	\N	25	31830	583	556
2158	98	3080043012	1013	12	21	13	5	49316	433	1	26	10298	nevermore	\N	25	21297	740	582
2159	116	3080043012	956	12	2	20	6	11361	59	2	3	337	disruptor	\N	20	17798	299	353
2160	114	3080043012	995	12	2	17	6	5875	70	3	6	462	omniknight	\N	22	16702	309	422
2161	105	3080043012	1044	12	4	15	10	5580	101	4	2	810	slardar	\N	24	27238	310	512
2162	106	3080043012	1098	-12	0	16	11	16642	94	128	0	40	keeper_of_the_light	\N	19	18074	264	314
2163	129	3080043012	1039	-12	12	11	5	37542	260	129	36	2704	juggernaut	\N	25	19363	485	557
2164	92	3080043012	1022	-12	3	18	9	18508	206	130	5	3906	weaver	\N	23	27284	358	458
2165	157	3080043012	1014	-12	7	18	9	39065	180	131	1	909	centaur	\N	24	44394	367	539
2166	107	3080043012	993	-12	10	15	13	17559	94	132	2	168	witch_doctor	\N	22	30045	336	436
2167	98	3080142706	1025	-10	8	9	7	20325	220	0	0	349	magnataur	\N	24	28935	430	620
2168	96	3080142706	1126	-10	5	12	6	20838	405	1	14	165	naga_siren	\N	23	19491	519	525
2169	116	3080142706	968	-10	8	9	8	18843	235	2	8	478	windrunner	\N	24	20682	426	617
2170	176	3080142706	993	-10	5	12	10	10302	71	3	0	0	sven	\N	17	19249	230	292
2171	114	3080142706	1007	-10	4	18	10	11093	20	4	3	21	disruptor	\N	17	17078	220	310
2172	129	3080142706	1027	10	3	16	7	8088	99	128	6	2539	slardar	\N	24	20463	388	572
2173	106	3080142706	1086	10	10	7	4	28404	320	129	22	12084	phantom_assassin	\N	25	19078	669	631
2174	92	3080142706	1010	10	9	18	8	28731	223	130	8	9114	sniper	\N	22	11301	541	499
2175	111	3080142706	988	10	14	12	4	26855	94	131	0	1198	skywrath_mage	\N	24	15350	489	608
2176	157	3080142706	1002	10	4	13	8	13357	60	132	4	1585	lich	\N	24	15209	365	579
2177	114	3081724512	997	5	3	12	3	4702	1	0	4	658	ogre_magi	\N	15	7949	261	328
2178	92	3081724512	1020	5	3	15	4	6578	90	1	5	824	slardar	\N	18	10589	320	452
2179	98	3081724512	1015	5	13	5	3	17693	301	2	50	7772	antimage	\N	24	8446	729	806
2180	96	3081724512	1116	5	12	12	0	26458	303	3	10	0	tinker	\N	22	4092	661	656
2181	105	3081724512	1056	5	3	13	4	2474	12	4	1	369	shadow_demon	\N	12	6867	228	211
2182	97	3081724512	996	-5	5	3	7	11268	108	128	7	0	ember_spirit	\N	18	14397	326	447
2183	95	3081724512	1027	-5	2	5	5	5736	95	129	1	0	sand_king	\N	15	11666	268	342
2184	99	3081724512	968	-5	4	6	8	7619	32	130	1	0	skywrath_mage	\N	15	8336	296	331
2185	135	3081724512	970	-5	1	7	8	3501	17	131	2	0	disruptor	\N	13	11803	210	236
2186	116	3081724512	958	-5	2	6	6	9819	148	132	27	0	spectre	\N	17	11703	347	420
2187	129	3081813180	1037	15	10	11	3	21720	217	0	23	10588	juggernaut	\N	23	8309	601	633
2188	135	3081813180	965	15	1	8	10	4461	36	1	4	256	lion	\N	15	9196	290	276
2189	98	3081813180	1020	15	11	11	0	26319	250	2	8	6399	invoker	\N	25	7595	697	752
2190	107	3081813180	981	15	6	12	4	7072	54	3	3	616	ogre_magi	\N	19	11409	387	419
2191	99	3081813180	963	15	4	21	6	18366	94	4	1	1335	phoenix	\N	23	10155	507	619
2192	95	3081813180	1022	-15	10	6	11	8230	88	128	1	0	slardar	\N	17	20705	290	349
2193	96	3081813180	1121	-15	6	6	4	16640	264	129	18	708	nevermore	\N	21	15057	473	514
2194	105	3081813180	1061	-15	1	15	7	7114	18	130	1	247	jakiro	\N	14	16268	184	263
2195	97	3081813180	991	-15	5	1	7	11450	223	131	15	382	phantom_assassin	\N	20	15105	420	464
2196	114	3081813180	1002	-15	0	13	3	3230	10	132	4	87	dazzle	\N	16	10803	179	319
2197	135	3081894892	980	-15	1	4	15	5387	21	0	0	0	lion	\N	13	18234	200	255
2198	129	3081894892	1052	-15	8	4	11	16572	133	1	21	120	juggernaut	\N	17	17329	355	395
2199	106	3081894892	1096	-15	7	7	10	20659	109	2	2	1039	skeleton_king	\N	16	30086	315	361
2200	105	3081894892	1046	-15	2	4	9	8351	100	3	2	284	windrunner	\N	16	15707	289	358
2201	95	3081894892	1007	-15	2	3	11	4794	33	4	1	13	monkey_king	\N	13	14099	181	225
2202	116	3081894892	953	15	18	12	2	25649	170	128	4	878	shredder	\N	25	14805	604	828
2203	96	3081894892	1106	15	16	17	1	32851	222	129	43	5563	morphling	\N	25	11246	644	818
2204	99	3081894892	978	15	2	20	11	8878	35	130	1	346	disruptor	\N	16	12819	325	371
2205	98	3081894892	1035	15	16	10	1	36360	274	131	6	11141	slark	\N	25	21407	761	818
2206	114	3081894892	987	15	3	30	6	4467	19	132	2	1813	witch_doctor	\N	18	8236	317	452
2207	135	3081966950	965	5	1	13	5	4644	86	0	3	660	sven	\N	17	7376	324	409
2208	96	3081966950	1121	5	15	7	0	19510	220	1	11	6154	morphling	\N	23	6158	621	751
2209	106	3081966950	1081	5	7	17	2	21340	134	2	0	2303	centaur	\N	20	16179	474	591
2210	105	3081966950	1031	5	3	16	3	6393	19	3	1	328	ancient_apparition	\N	13	6131	273	255
2211	99	3081966950	993	5	9	11	4	16969	110	4	5	5658	lina	\N	20	9504	467	552
2212	116	3081966950	968	-5	1	2	7	7607	162	128	11	372	obsidian_destroyer	\N	17	15253	361	451
2213	98	3081966950	1050	-5	10	0	6	20133	189	129	23	0	slark	\N	21	20502	513	626
2214	114	3081966950	1002	-5	1	5	6	6658	57	130	2	0	keeper_of_the_light	\N	13	7888	228	258
2215	92	3081966950	1025	-5	1	7	6	5578	94	131	7	0	slardar	\N	14	12232	264	298
2216	95	3081966950	992	-5	0	6	11	4782	7	132	1	15	witch_doctor	\N	10	12391	131	169
2217	135	3082037038	970	12	2	21	2	9308	11	0	2	3750	sven	\N	11	6509	369	307
2218	98	3082037038	1045	12	9	10	3	9548	123	1	25	4782	juggernaut	\N	16	4032	646	543
2219	106	3082037038	1086	12	8	16	3	10158	9	2	0	1418	ogre_magi	\N	12	8271	417	325
2220	99	3082037038	998	12	17	11	8	26458	62	3	6	2554	monkey_king	\N	14	11959	564	474
2221	95	3082037038	987	12	2	14	6	7558	23	4	1	340	tidehunter	\N	11	8577	359	303
2222	157	3082037038	1012	-12	0	12	10	4470	24	128	0	0	slardar	\N	10	16258	269	255
2223	96	3082037038	1126	-12	3	7	9	7685	35	129	0	117	magnataur	\N	10	12915	309	255
2224	175	3082037038	1003	-12	3	5	8	7453	58	130	8	73	phantom_assassin	\N	11	10819	332	307
2225	105	3082037038	1036	-12	5	10	5	12276	33	131	3	0	rubick	\N	12	8793	377	345
2226	116	3082037038	963	-12	2	6	7	7464	18	132	1	0	omniknight	\N	12	14245	329	363
2257	96	3085744568	1118	10	14	15	2	23306	215	0	7	4091	sniper	\N	23	7002	580	722
2258	129	3085744568	1033	10	11	10	6	14261	202	1	26	3415	faceless_void	\N	21	12196	567	604
2259	105	3085744568	1029	10	9	9	1	11406	185	2	0	919	shredder	\N	25	11593	535	852
2260	97	3085744568	976	10	4	12	6	4313	44	3	3	599	shadow_shaman	\N	17	9331	291	410
2261	155	3085744568	1013	10	3	19	3	5622	12	4	0	433	ogre_magi	\N	17	9149	280	405
2262	106	3085744568	1114	-10	1	11	8	16847	189	128	10	328	slark	\N	19	19823	396	502
2263	98	3085744568	1063	-10	7	3	4	8381	190	129	14	122	invoker	\N	23	10226	499	693
2264	92	3085744568	1015	-10	1	6	7	6793	27	130	1	16	monkey_king	\N	13	7982	205	257
2265	157	3085744568	1000	-10	5	4	11	6303	24	131	2	151	disruptor	\N	15	11640	247	311
2266	95	3085744568	993	-10	4	10	12	17827	74	132	6	0	rattletrap	\N	18	16117	296	436
2227	129	3083980806	1037	6	6	12	6	25667	131	0	16	3834	queenofpain	\N	21	15503	419	442
2228	98	3083980806	1057	6	6	20	0	26422	216	1	2	442	keeper_of_the_light	\N	25	6921	553	646
2229	106	3083980806	1098	6	4	15	8	13682	45	2	0	1492	lion	\N	20	15017	339	425
2230	135	3083980806	982	6	3	21	1	23019	87	3	0	1630	phoenix	\N	23	7493	458	542
2231	107	3083980806	996	6	14	8	2	35602	293	4	12	10361	slark	\N	25	41350	620	648
2232	95	3083980806	999	-6	1	10	10	27985	118	128	2	245	centaur	\N	16	34390	234	286
2233	96	3083980806	1114	-6	5	5	4	22582	285	129	34	104	lone_druid	\N	22	19605	438	484
2234	109	3083980806	1032	-6	2	8	5	6574	25	130	2	152	omniknight	\N	16	19743	219	283
2235	114	3083980806	997	-6	1	2	10	5699	18	131	1	17	ogre_magi	\N	14	18746	203	207
2236	116	3083980806	951	-6	7	7	6	20967	202	132	12	224	shredder	\N	23	29431	393	547
2237	129	3084053502	1043	-5	11	14	8	28907	157	0	14	167	phantom_assassin	\N	25	19384	490	757
2238	135	3084053502	988	-5	1	16	8	7099	25	1	3	0	disruptor	\N	20	14801	356	480
2239	95	3084053502	993	-5	11	10	8	37286	136	2	5	0	zuus	\N	20	17681	386	483
2240	111	3084053502	998	-5	2	8	13	8166	54	3	0	0	earth_spirit	\N	15	25812	281	275
2241	109	3084053502	1026	-5	5	8	8	10209	104	4	18	109	slardar	\N	21	20845	334	498
2242	98	3084053502	1063	5	18	14	3	28986	191	128	17	6867	invoker	\N	25	15645	696	738
2243	106	3084053502	1104	5	4	19	14	9490	36	129	2	839	lion	\N	20	18576	372	470
2244	96	3084053502	1108	5	10	20	3	68854	371	130	5	12065	alchemist	\N	25	58562	1069	736
2245	114	3084053502	991	5	5	10	8	5562	29	131	4	1761	sven	\N	16	12906	324	306
2246	107	3084053502	1002	5	5	14	3	13932	242	132	5	1510	magnataur	\N	24	14279	588	688
2247	155	3085593226	1018	-5	5	23	16	20627	158	0	0	1016	crystal_maiden	\N	25	27150	343	414
2248	98	3085593226	1068	-5	17	21	2	79164	521	1	10	5147	invoker	\N	25	30665	678	409
2249	92	3085593226	1020	-5	22	11	10	45343	266	2	24	4545	ursa	\N	25	40771	486	410
2250	129	3085593226	1038	-5	7	32	10	43675	319	3	12	2470	slardar	\N	25	48464	473	410
2251	114	3085593226	996	-5	3	31	10	23960	50	4	1	735	disruptor	\N	24	30348	320	393
2252	105	3085593226	1024	5	5	18	13	13483	51	128	0	1379	shadow_demon	\N	21	25059	253	298
2253	96	3085593226	1113	5	9	22	4	62929	925	129	7	15123	naga_siren	\N	25	36088	860	409
2254	106	3085593226	1109	5	3	17	16	20931	59	130	1	151	ogre_magi	\N	25	43496	262	414
2255	111	3085593226	993	5	20	9	11	61392	365	131	7	4374	slark	\N	25	84026	561	410
2256	95	3085593226	988	5	11	23	10	34732	259	132	2	1086	abyssal_underlord	\N	25	40169	405	412
2267	129	3085816017	1043	6	9	27	11	26958	225	0	7	5599	skeleton_king	\N	24	37454	515	577
2268	106	3085816017	1104	6	7	15	11	17982	299	1	6	8987	magnataur	\N	25	29134	538	579
2269	98	3085816017	1053	6	22	12	3	39423	276	2	4	1490	necrolyte	\N	25	11742	678	579
2270	155	3085816017	1023	6	3	17	8	7954	39	3	0	614	ogre_magi	\N	22	16835	345	443
2271	157	3085816017	990	6	3	22	10	22500	191	4	1	5666	centaur	\N	24	26527	430	558
2272	105	3085816017	1039	-6	11	10	6	40442	317	128	12	701	kunkka	\N	25	20506	553	579
2273	96	3085816017	1128	-6	18	10	5	48622	416	129	25	2194	slark	\N	25	47003	630	580
2274	97	3085816017	986	-6	4	18	8	13279	81	130	0	160	lion	\N	23	14953	337	490
2275	92	3085816017	1005	-6	4	12	14	26006	88	131	2	0	pudge	\N	21	35236	281	404
2276	95	3085816017	983	-6	5	10	11	15356	71	132	1	64	nyx_assassin	\N	21	19132	257	414
2277	95	3085905223	977	-9	4	14	9	16311	59	0	2	0	tusk	\N	18	17522	290	372
2278	96	3085905223	1122	-9	5	15	5	48190	332	1	0	1891	alchemist	\N	25	45111	774	713
2279	105	3085905223	1033	-9	6	11	6	21986	128	2	0	157	earthshaker	\N	20	12198	343	442
2280	164	3085905223	983	-9	3	13	7	9474	16	3	1	0	lion	\N	16	14072	229	297
2281	107	3085905223	1007	-9	10	9	8	23071	222	4	11	1780	slark	\N	24	31590	486	666
2282	97	3085905223	980	9	9	12	4	25704	210	128	7	7153	enchantress	\N	24	16783	577	701
2283	106	3085905223	1110	9	3	12	5	11533	59	129	2	2800	shadow_demon	\N	17	10953	356	357
2284	92	3085905223	999	9	4	13	8	12632	46	130	4	1868	jakiro	\N	18	14095	326	394
2285	157	3085905223	996	9	10	10	5	30381	251	131	7	7088	centaur	\N	24	35168	620	690
2286	129	3085905223	1049	9	7	14	7	17433	228	132	15	14438	troll_warlord	\N	24	19223	598	644
2287	105	3085967050	1024	-5	1	6	13	10033	91	0	1	0	omniknight	\N	20	24866	236	360
2288	157	3085967050	1005	-5	2	11	15	14705	88	1	0	0	nyx_assassin	\N	22	22938	293	432
2289	129	3085967050	1058	-5	9	11	11	35258	356	2	37	850	antimage	\N	25	20158	524	580
2290	111	3085967050	998	-5	12	7	12	37193	180	3	13	169	lina	\N	23	27267	398	511
2291	114	3085967050	991	-5	6	14	12	19852	45	4	0	0	lion	\N	23	18058	349	494
2292	109	3085967050	1021	5	23	18	5	34221	230	128	28	14873	legion_commander	\N	25	35334	610	580
2293	96	3085967050	1113	5	20	19	3	34378	284	129	33	2444	bloodseeker	\N	25	19598	591	589
2294	106	3085967050	1119	5	6	26	11	9318	69	130	0	696	ogre_magi	\N	22	20518	322	450
2295	95	3085967050	968	5	6	22	8	19529	254	131	1	789	doom_bringer	\N	25	22417	523	579
2296	92	3085967050	1008	5	6	28	6	9063	68	132	1	1847	winter_wyvern	\N	23	12396	357	494
2297	129	3087776760	1053	11	6	10	7	27682	273	0	32	4680	nevermore	\N	24	15254	556	587
2298	96	3087776760	1118	11	14	8	1	46165	531	1	14	19296	terrorblade	\N	25	11132	877	636
2299	105	3087776760	1019	11	5	11	4	12349	129	2	0	368	earthshaker	\N	21	9939	373	448
2300	92	3087776760	1013	11	5	15	5	13846	24	3	1	2073	shadow_demon	\N	20	8463	296	403
2301	95	3087776760	973	11	1	13	8	4768	34	4	1	1058	ogre_magi	\N	19	15709	307	351
2302	98	3087776760	1059	-11	10	10	2	19174	362	128	41	1058	juggernaut	\N	25	25223	572	631
2303	106	3087776760	1124	-11	4	7	7	16468	237	129	3	0	obsidian_destroyer	\N	22	25618	404	497
2304	157	3087776760	1000	-11	3	4	8	7273	157	130	11	0	slardar	\N	20	23410	293	415
2305	155	3087776760	1029	-11	4	11	13	10271	64	131	0	0	crystal_maiden	\N	19	16058	250	363
2306	114	3087776760	986	-11	4	9	3	6490	40	132	0	19	disruptor	\N	17	13680	267	303
2307	92	3087858685	1024	-9	3	7	7	8188	63	0	2	61	winter_wyvern	\N	14	12140	235	250
2308	96	3087858685	1129	-9	9	6	4	23170	323	1	13	779	juggernaut	\N	24	14792	510	641
2309	157	3087858685	989	-9	2	10	9	22752	173	2	7	16	centaur	\N	19	32478	316	387
2310	129	3087858685	1064	-9	10	7	9	24731	133	3	19	64	monkey_king	\N	20	22375	330	426
2311	114	3087858685	975	-9	0	15	7	9068	30	4	4	0	disruptor	\N	16	16421	236	315
2312	95	3087858685	984	9	6	18	4	23695	106	128	1	5074	abaddon	\N	20	25618	402	446
2313	98	3087858685	1048	9	20	9	0	37383	295	129	28	12616	invoker	\N	25	15662	802	696
2314	105	3087858685	1030	9	6	9	1	21570	333	130	25	3184	phantom_assassin	\N	24	13096	648	671
2315	155	3087858685	1018	9	0	12	10	6302	9	131	2	234	ogre_magi	\N	14	15650	272	252
2316	106	3087858685	1113	9	3	15	10	6459	45	132	1	1817	witch_doctor	\N	18	15086	303	362
2317	91	3089707778	1012	-12	4	13	9	27879	119	0	5	2026	dragon_knight	\N	17	33385	312	377
2318	157	3089707778	980	-12	5	12	9	14899	130	1	5	0	centaur	\N	18	22950	342	412
2319	98	3089707778	1057	-12	12	9	3	14128	205	2	5	475	necrolyte	\N	22	9950	518	599
2320	105	3089707778	1039	-12	2	12	8	6674	15	3	1	15	winter_wyvern	\N	14	14520	181	256
2321	129	3089707778	1055	-12	5	14	5	22256	155	4	19	182	monkey_king	\N	20	17849	380	487
2322	97	3089707778	989	12	7	13	6	24015	106	128	7	1941	night_stalker	\N	19	28847	391	434
2323	95	3089707778	993	12	7	17	2	19016	73	129	0	1103	abaddon	\N	21	18045	382	566
2324	109	3089707778	1026	12	5	15	5	15071	74	130	2	4609	pugna	\N	18	13300	359	415
2325	96	3089707778	1120	12	14	9	2	38346	399	131	21	15203	terrorblade	\N	24	11642	821	718
2326	114	3089707778	966	12	0	11	13	5356	3	132	2	0	ogre_magi	\N	11	17152	242	169
2327	109	3089803824	1038	-13	2	5	6	12901	27	0	0	48	elder_titan	\N	13	12237	203	243
2328	96	3089803824	1132	-13	1	7	5	13706	277	1	4	1154	terrorblade	\N	16	10393	473	357
2329	97	3089803824	1001	-13	2	6	9	15154	123	2	2	36	centaur	\N	17	25367	308	374
2330	91	3089803824	1000	-13	2	1	9	19253	96	3	5	1338	dragon_knight	\N	15	34653	267	312
2331	114	3089803824	978	-13	2	6	9	6372	33	4	1	438	shadow_demon	\N	12	13274	208	200
2332	95	3089803824	1005	13	3	22	4	14248	76	128	1	2400	abaddon	\N	17	16043	382	375
2333	98	3089803824	1045	13	8	11	0	20836	294	129	19	8524	invoker	\N	25	7132	787	796
2334	129	3089803824	1043	13	13	14	2	21837	196	130	8	7729	monkey_king	\N	22	12335	618	611
2335	157	3089803824	968	13	6	11	5	10467	76	131	3	2033	earthshaker	\N	17	13213	422	382
2336	105	3089803824	1027	13	7	14	0	13822	91	132	3	1771	crystal_maiden	\N	21	3949	485	541
2337	97	3089921112	988	12	3	11	7	14567	146	0	2	3470	lina	\N	22	16215	354	407
2338	98	3089921112	1058	12	10	12	3	37109	473	1	32	5622	invoker	\N	25	20286	741	514
2339	95	3089921112	1018	12	3	15	3	26010	117	2	3	2542	abaddon	\N	23	31962	344	453
2340	105	3089921112	1040	12	4	12	4	10142	39	3	0	1375	ogre_magi	\N	21	26171	328	361
2341	116	3089921112	945	12	8	14	5	62745	278	4	18	13215	life_stealer	\N	25	60658	546	518
2342	157	3089921112	981	-12	3	7	9	35371	227	128	6	1161	centaur	\N	21	42175	344	370
2343	96	3089921112	1119	-12	10	9	5	81065	549	129	6	2847	alchemist	\N	25	60010	946	515
2344	114	3089921112	965	-12	3	13	6	10907	107	130	1	315	night_stalker	\N	21	20108	256	377
2345	109	3089921112	1025	-12	3	9	5	12075	55	131	10	307	shadow_demon	\N	20	14465	207	331
2346	92	3089921112	1015	-12	2	12	3	22567	239	132	6	2301	magnataur	\N	24	20508	337	492
2347	96	3090030420	1107	-6	3	10	3	19770	276	0	12	1930	terrorblade	\N	21	10700	521	521
2367	95	3091864405	1021	15	2	8	3	5255	34	0	4	1173	abaddon	\N	9	4317	296	323
2348	109	3090030420	1013	-6	0	10	4	7779	25	1	2	29	abaddon	\N	14	12361	177	279
2349	105	3090030420	1052	-6	2	5	6	13339	130	2	0	281	centaur	\N	17	19261	306	361
2350	92	3090030420	1003	-6	5	2	5	10141	166	3	4	2564	pugna	\N	19	15311	390	447
2351	114	3090030420	953	-6	3	5	8	4480	4	4	1	97	ogre_magi	\N	15	13001	244	293
2352	106	3090030420	1122	6	12	8	1	26226	258	128	3	8818	luna	\N	23	11850	651	683
2353	98	3090030420	1070	6	10	6	1	19145	298	129	16	6351	invoker	\N	25	9725	725	775
2354	95	3090030420	1030	6	2	10	5	5251	135	130	4	1100	faceless_void	\N	21	12786	415	529
2355	97	3090030420	1000	6	1	8	4	6825	47	131	0	291	lion	\N	17	6614	307	353
2356	157	3090030420	969	6	1	10	3	4328	40	132	5	961	disruptor	\N	18	5675	296	395
2357	95	3090093196	1036	-15	4	1	12	8546	80	0	0	0	doom_bringer	\N	16	20350	356	389
2358	106	3090093196	1128	-15	3	5	20	5916	71	1	0	1006	undying	\N	14	30700	318	319
2359	109	3090093196	1007	-15	3	3	11	8388	85	2	2	1969	pugna	\N	12	15627	277	250
2360	105	3090093196	1046	-15	2	7	8	6648	95	3	0	75	dark_seer	\N	13	15116	311	289
2361	155	3090093196	1027	-15	0	3	17	6357	12	4	0	12	skywrath_mage	\N	10	17439	175	173
2362	97	3090093196	1006	15	13	26	1	31059	95	128	7	1307	zuus	\N	22	8386	563	686
2363	98	3090093196	1076	15	31	10	0	35551	338	129	19	14844	antimage	\N	25	8036	1079	929
2364	114	3090093196	947	15	7	15	7	8625	19	130	1	721	lion	\N	16	6342	398	400
2365	157	3090093196	975	15	7	33	3	11911	47	131	0	1193	disruptor	\N	19	7422	457	534
2366	107	3090093196	998	15	7	27	1	17223	162	132	2	4053	centaur	\N	22	10806	612	691
2368	91	3091864405	987	15	2	2	0	2052	53	1	3	1069	magnataur	\N	10	3425	343	365
2369	92	3091864405	997	15	3	5	1	5166	99	2	26	1208	life_stealer	\N	10	3438	471	382
2370	157	3091864405	990	15	7	8	1	3958	17	3	2	549	disruptor	\N	8	2038	325	279
2371	139	3091864405	1004	15	3	7	2	2252	10	4	0	0	witch_doctor	\N	7	1031	271	219
2372	105	3091864405	1031	-15	2	2	5	1744	42	128	4	0	enigma	\N	8	3938	285	252
2373	98	3091864405	1091	-15	1	0	2	3377	93	129	18	0	nevermore	\N	12	2398	369	455
2374	109	3091864405	992	-15	0	2	2	1177	62	130	14	102	sven	\N	8	1827	284	257
2375	177	3091864405	1000	-15	3	2	5	3032	9	131	1	0	lion	\N	7	5022	219	224
2376	120	3091864405	1000	-15	0	2	5	2455	11	132	0	0	keeper_of_the_light	\N	5	3034	149	152
2377	186	3538436243	1000	-10	1	9	9	9491	9	0	0	0	pudge	\N	11	19598	151	200
2378	187	3538436243	1000	-10	1	4	7	2973	17	1	4	13	lion	\N	13	12275	163	255
2379	188	3538436243	1000	-10	0	3	4	16461	209	2	4	58	medusa	\N	19	10330	396	492
2380	189	3538436243	1000	-10	6	3	7	5813	86	3	0	0	mirana	\N	15	14004	386	336
2381	190	3538436243	1000	-10	2	6	7	10935	228	4	17	1380	troll_warlord	\N	19	14397	426	497
2382	191	3538436243	1000	10	6	14	2	14851	180	128	19	8039	magnataur	\N	22	13227	518	640
2383	192	3538436243	1000	10	5	14	5	8810	35	129	3	3145	silencer	\N	17	5414	329	403
2384	193	3538436243	1000	10	6	15	1	11508	142	130	19	7256	abyssal_underlord	\N	21	10415	501	581
2385	194	3538436243	1000	10	4	14	3	10059	22	131	3	470	ogre_magi	\N	16	5399	328	360
2386	195	3538436243	1000	10	12	7	1	21830	293	132	52	4752	phantom_assassin	\N	22	7672	702	652
2387	196	3538546945	1000	-10	3	8	8	15188	114	0	3	0	earthshaker	\N	16	16492	285	332
2388	192	3538546945	1010	-10	3	7	16	7484	28	1	0	0	lion	\N	15	22148	224	282
2389	186	3538546945	990	-10	2	2	8	16022	102	2	6	29	bristleback	\N	18	22486	288	406
2390	189	3538546945	990	-10	6	6	2	34471	174	3	8	0	zuus	\N	20	7249	380	490
2391	193	3538546945	1010	-10	0	11	4	15905	30	4	12	0	skeleton_king	\N	16	24192	182	313
2392	191	3538546945	1010	10	6	9	2	17506	258	128	1	2429	storm_spirit	\N	23	15928	518	633
2393	188	3538546945	990	10	2	10	5	7957	145	129	1	2205	doom_bringer	\N	19	12150	510	429
2394	195	3538546945	1010	10	1	9	4	13336	67	130	8	2856	ogre_magi	\N	18	16963	338	379
2395	187	3538546945	990	10	5	15	4	18884	210	131	4	998	dark_seer	\N	23	30495	508	599
2396	197	3538546945	1000	10	24	4	0	34884	241	132	29	5716	phantom_assassin	\N	25	13534	673	729
2397	186	3538622705	980	-10	5	7	10	5509	15	0	4	126	oracle	\N	14	16832	185	251
2398	198	3538622705	1000	-10	7	12	6	19323	102	1	2	76	tiny	\N	22	30816	351	528
2399	187	3538622705	1000	-10	3	10	9	8840	157	2	21	1858	clinkz	\N	19	21299	339	414
2400	195	3538622705	1020	-10	4	10	9	30455	156	3	5	402	kunkka	\N	22	27173	384	534
2401	199	3538622705	1000	-10	6	6	7	20928	193	4	0	263	skeleton_king	\N	18	31578	346	381
2402	191	3538622705	1020	10	0	21	9	11690	83	128	1	2145	earthshaker	\N	18	12939	303	366
2403	196	3538622705	990	10	2	13	14	13509	12	129	1	84	pudge	\N	14	21695	214	250
2404	189	3538622705	980	10	13	17	1	35568	293	130	23	2814	invoker	\N	25	11518	655	696
2405	197	3538622705	1010	10	17	11	2	37568	254	131	21	3373	phantom_lancer	\N	25	15400	644	698
2406	193	3538622705	1000	10	8	17	2	21363	86	132	17	185	nyx_assassin	\N	22	15503	391	537
2407	191	3538682725	1030	13	15	18	6	42197	252	0	11	4604	sniper	\N	24	20758	561	602
2408	198	3538682725	990	13	4	26	14	12948	49	1	7	82	vengefulspirit	\N	18	18576	311	364
2409	189	3538682725	990	13	27	9	2	55118	303	2	11	10898	phantom_assassin	\N	25	14080	797	645
2410	187	3538682725	990	13	5	24	4	21152	186	3	4	2319	dark_seer	\N	25	40723	501	641
2411	186	3538682725	970	13	4	13	7	6074	98	4	0	1293	slardar	\N	21	17026	353	448
2412	196	3538682725	1000	-13	3	14	14	15022	76	128	6	559	jakiro	\N	21	34387	313	442
2413	199	3538682725	990	-13	5	15	15	11386	26	129	2	289	ancient_apparition	\N	19	25982	274	376
2414	193	3538682725	1010	-13	2	14	9	12031	113	130	20	289	undying	\N	21	28977	289	446
2415	195	3538682725	1010	-13	10	12	14	25824	49	131	3	0	riki	\N	23	29203	331	552
2416	197	3538682725	1020	-13	12	10	4	48276	439	132	6	1100	medusa	\N	25	20316	720	649
2417	187	3540213420	1003	-11	9	9	15	14680	114	0	14	1540	phantom_assassin	\N	19	19623	412	494
2418	188	3540213420	1000	-11	7	9	8	10751	119	1	1	0	doom_bringer	\N	20	20286	491	533
2419	200	3540213420	1000	-11	5	5	13	12070	94	2	5	0	invoker	\N	16	16471	341	381
2420	192	3540213420	1000	-11	2	12	10	15692	93	3	9	0	spirit_breaker	\N	19	25780	329	501
2421	193	3540213420	997	-11	2	16	8	4717	24	4	1	0	treant	\N	17	15439	250	390
2422	201	3540213420	1000	11	27	11	1	38184	258	128	21	3009	storm_spirit	\N	25	8260	778	816
2423	202	3540213420	1000	11	5	20	4	11723	39	129	8	1562	vengefulspirit	\N	19	8577	302	476
2424	198	3540213420	1003	11	3	17	7	16473	148	130	4	2763	tiny	\N	18	17370	388	434
2425	196	3540213420	987	11	8	5	2	13113	285	131	12	2690	juggernaut	\N	23	3491	608	732
2426	199	3540213420	977	11	11	22	11	18106	39	132	5	1853	ogre_magi	\N	20	20212	344	524
2427	199	3540314230	988	7	6	6	10	6050	23	0	0	1366	witch_doctor	\N	11	10843	347	271
2428	198	3540314230	1014	7	5	7	3	9247	86	1	10	3753	windrunner	\N	15	8030	478	423
2429	201	3540314230	1011	7	10	5	2	11080	108	2	31	2960	invoker	\N	17	8587	601	530
2430	202	3540314230	1011	7	4	12	6	8066	27	3	2	1010	mirana	\N	14	8373	382	413
2431	187	3540314230	992	7	3	9	5	8216	128	4	8	6354	skeleton_king	\N	15	6064	563	467
2432	188	3540314230	989	-7	0	2	3	1213	18	128	2	0	chaos_knight	\N	6	3047	159	116
2433	196	3540314230	998	-7	6	10	11	13439	41	129	0	0	earthshaker	\N	17	14075	534	561
2434	193	3540314230	986	-7	1	4	1	1470	1	130	0	0	nyx_assassin	\N	5	1829	150	86
2435	200	3540314230	989	-7	4	5	7	17730	136	131	10	943	kunkka	\N	15	18939	516	442
2436	192	3540314230	989	-7	11	9	9	25797	29	132	0	0	pudge	\N	18	22521	580	618
2437	186	3540695097	983	-10	2	8	5	5389	51	0	2	222	slardar	\N	14	14523	276	330
2438	191	3540695097	1043	-10	5	5	5	16762	117	1	6	512	windrunner	\N	18	10053	407	486
2439	192	3540695097	982	-10	4	9	10	18121	27	2	0	0	pudge	\N	12	20886	216	236
2440	199	3540695097	995	-10	0	12	12	9037	20	3	1	0	disruptor	\N	13	14716	231	292
2441	190	3540695097	990	-10	2	3	7	10541	155	4	9	590	phantom_assassin	\N	17	10318	413	463
2442	202	3540695097	1018	10	6	16	4	13177	24	128	0	1965	lich	\N	16	6890	351	431
2443	187	3540695097	999	10	0	15	3	5446	25	129	11	1356	ogre_magi	\N	17	7959	339	470
2444	203	3540695097	1000	10	15	11	4	16429	141	130	20	3667	puck	\N	21	11247	612	637
2445	188	3540695097	982	10	8	5	1	11869	289	131	33	13725	sven	\N	22	9975	715	712
2446	193	3540695097	979	10	8	19	3	16053	108	132	7	4655	abyssal_underlord	\N	19	16257	511	537
2447	190	3540778400	980	-9	14	24	8	54407	336	0	6	3983	weaver	\N	25	59611	526	420
2448	199	3540778400	985	-9	19	21	9	43092	411	1	14	1695	faceless_void	\N	25	44642	575	422
2449	205	3540778400	1000	-9	15	17	13	48790	531	2	34	2679	nevermore	\N	25	38229	600	420
2450	188	3540778400	992	-9	7	23	14	8950	147	3	9	0	shadow_shaman	\N	25	33058	328	420
2451	202	3540778400	1028	-9	3	28	15	17879	87	4	14	19	vengefulspirit	\N	25	32214	281	420
2452	187	3540778400	1009	9	4	12	13	11431	77	128	5	212	lion	\N	25	26868	284	420
2453	191	3540778400	1033	9	5	11	13	31899	486	129	24	1285	slark	\N	25	53277	517	420
2454	193	3540778400	989	9	1	15	13	14631	151	130	7	284	keeper_of_the_light	\N	24	25022	305	415
2455	192	3540778400	972	9	15	18	10	78553	478	131	10	9552	bristleback	\N	25	51054	662	420
2456	203	3540778400	1010	9	33	13	11	85520	497	132	13	8128	storm_spirit	\N	25	31177	714	420
2457	206	3540876223	1000	-8	4	5	5	13047	102	0	13	131	monkey_king	\N	14	9719	374	393
2458	187	3540876223	1018	-8	0	3	7	3368	12	1	1	0	ogre_magi	\N	10	12316	159	254
2459	205	3540876223	991	-8	3	4	5	10237	115	2	6	46	puck	\N	16	8413	409	495
2460	192	3540876223	981	-8	2	1	6	6125	94	3	3	0	tidehunter	\N	13	10535	279	340
2461	188	3540876223	983	-8	2	4	7	3615	47	4	4	0	chaos_knight	\N	12	7999	268	298
2462	191	3540876223	1042	8	6	10	3	21664	129	128	50	1696	huskar	\N	15	14857	458	447
2463	199	3540876223	976	8	3	8	2	6276	95	129	6	564	faceless_void	\N	16	9588	360	498
2464	196	3540876223	991	8	5	13	5	7491	8	130	1	0	witch_doctor	\N	14	6588	248	395
2465	203	3540876223	1019	8	12	4	0	17287	121	131	11	866	queenofpain	\N	18	7571	529	634
2466	193	3540876223	998	8	4	11	2	4384	28	132	2	0	treant	\N	13	5908	265	363
2467	199	3540922574	984	10	18	21	1	46985	277	0	20	6769	spectre	\N	25	25538	609	602
2468	193	3540922574	1006	10	10	23	5	36134	162	1	10	5784	abyssal_underlord	\N	25	32684	449	598
2469	202	3540922574	1019	10	11	23	6	13277	161	2	0	6842	mirana	\N	22	11041	493	491
2470	187	3540922574	1010	10	4	17	8	10823	61	3	2	401	lion	\N	23	14364	323	536
2471	205	3540922574	983	10	9	23	12	24778	198	4	10	1682	ember_spirit	\N	24	26413	459	551
2472	207	3540922574	1000	-10	6	12	13	8832	20	128	5	0	ogre_magi	\N	19	29872	262	347
2473	191	3540922574	1050	-10	5	15	12	19337	199	129	20	426	invoker	\N	23	23073	375	510
2474	192	3540922574	973	-10	8	13	14	25723	37	130	3	0	pudge	\N	20	42215	304	403
2475	196	3540922574	999	-10	3	8	9	10827	11	131	4	0	bane	\N	20	24735	207	402
2476	188	3540922574	975	-10	9	11	7	57099	439	132	24	1763	medusa	\N	25	23880	637	604
2487	198	3542243386	1007	8	10	18	5	28518	268	0	3	3086	skeleton_king	\N	25	32858	522	640
2488	191	3542243386	1040	8	14	23	3	28927	243	1	42	6926	bloodseeker	\N	25	20319	507	643
2489	200	3542243386	968	8	8	18	6	9989	32	2	2	943	lion	\N	22	14107	301	487
2490	187	3542243386	1020	8	6	19	9	14520	154	3	0	1381	dark_seer	\N	24	21763	419	627
2491	205	3542243386	1007	8	6	22	10	43557	167	4	2	960	zuus	\N	24	18456	398	608
2492	196	3542243386	975	-8	4	14	8	17456	52	128	4	817	jakiro	\N	19	18250	236	386
2493	199	3542243386	1008	-8	5	16	15	9391	18	129	0	78	witch_doctor	\N	18	22249	254	363
2494	203	3542243386	1013	-8	11	13	6	30344	162	130	8	130	earthshaker	\N	23	30711	405	569
2495	192	3542243386	977	-8	2	6	9	26445	199	131	16	57	abaddon	\N	21	27247	366	465
2496	195	3542243386	1011	-8	8	7	6	19907	315	132	24	330	sven	\N	23	23094	497	530
2497	198	3542416731	1015	-7	0	11	16	7036	9	0	2	182	wisp	\N	12	21930	156	204
2477	205	3542087676	993	14	2	15	4	10684	155	0	4	1943	omniknight	\N	23	33300	449	545
2478	199	3542087676	994	14	8	11	9	45302	344	1	21	18802	luna	\N	24	32776	647	616
2479	195	3542087676	997	14	6	23	7	27326	194	2	9	645	puck	\N	24	23003	426	608
2480	192	3542087676	963	14	11	15	9	34506	47	3	1	0	pudge	\N	21	41722	358	440
2481	190	3542087676	971	14	11	13	7	14908	46	4	8	437	bane	\N	22	21127	346	487
2482	198	3542087676	1021	-14	5	18	4	41539	253	128	1	1061	venomancer	\N	24	17343	568	612
2483	203	3542087676	1027	-14	14	13	10	40651	245	129	8	185	ember_spirit	\N	25	28805	505	630
2484	206	3542087676	992	-14	2	12	7	42789	254	130	12	150	life_stealer	\N	23	51314	419	516
2485	196	3542087676	989	-14	4	13	13	19577	65	131	0	0	earthshaker	\N	20	23224	278	424
2486	200	3542087676	982	-14	7	18	5	16989	71	132	4	102	windrunner	\N	22	21657	303	481
2498	199	3542416731	1000	-7	10	8	8	20859	209	1	15	1482	luna	\N	20	24675	493	528
2499	204	3542416731	1000	-7	1	10	6	5473	12	2	2	0	bane	\N	16	13017	202	347
2500	189	3542416731	1003	-7	6	3	4	17170	251	3	18	442	invoker	\N	25	10689	630	823
2501	192	3542416731	969	-7	6	5	13	17827	63	4	1	0	centaur	\N	16	28602	265	346
2502	196	3542416731	967	7	9	13	5	17118	42	128	2	473	lich	\N	18	10002	317	442
2503	191	3542416731	1048	7	11	19	2	16027	227	129	16	5800	troll_warlord	\N	24	11077	619	767
2504	202	3542416731	1029	7	3	15	9	8862	13	130	1	361	vengefulspirit	\N	16	13896	235	346
2505	187	3542416731	1028	7	17	14	2	37553	223	131	41	4030	phantom_assassin	\N	25	12046	630	811
2506	200	3542416731	976	7	5	13	5	7687	90	132	9	85	magnataur	\N	18	9678	350	417
2507	198	3542567886	1008	10	7	10	3	18629	144	0	6	3477	abyssal_underlord	\N	21	13323	491	628
2508	187	3542567886	1035	10	3	13	5	5014	39	1	4	727	shadow_shaman	\N	21	8878	322	579
2509	205	3542567886	1015	10	17	10	5	28663	180	2	10	3019	storm_spirit	\N	24	15341	592	820
2510	195	3542567886	1003	10	7	9	6	19057	235	3	46	1225	phantom_assassin	\N	22	11415	579	655
2511	196	3542567886	974	10	2	11	9	10821	50	4	5	746	lich	\N	16	12865	306	375
2512	199	3542567886	993	-10	7	9	9	8661	55	128	4	19	slardar	\N	18	23646	311	439
2513	191	3542567886	1055	-10	2	6	6	13847	167	129	7	0	slark	\N	17	20658	320	399
2514	208	3542567886	1000	-10	5	12	9	22763	152	130	6	265	ember_spirit	\N	21	14264	424	611
2515	192	3542567886	962	-10	4	11	12	13620	7	131	2	0	pudge	\N	17	24784	259	396
2516	202	3542567886	1036	-10	6	12	5	14391	86	132	1	21	mirana	\N	18	10292	355	466
2517	187	3542687946	1045	7	5	16	3	13024	204	0	3	1038	enigma	\N	23	8987	443	585
2518	199	3542687946	983	7	14	16	5	37064	214	1	14	5126	spectre	\N	25	25781	553	708
2519	202	3542687946	1026	7	3	15	5	25347	188	2	10	1408	phoenix	\N	23	15387	464	631
2520	208	3542687946	990	7	6	20	1	13727	32	3	5	280	ogre_magi	\N	23	14144	355	588
2521	195	3542687946	1013	7	12	17	5	29258	289	4	20	8654	sniper	\N	25	13061	639	732
2522	196	3542687946	984	-7	1	8	12	12604	6	128	4	46	pudge	\N	17	21775	162	347
2523	191	3542687946	1045	-7	5	8	7	20133	246	129	18	232	medusa	\N	23	19666	448	585
2524	198	3542687946	1018	-7	5	5	8	10976	229	130	1	941	skeleton_king	\N	22	30284	478	556
2525	200	3542687946	983	-7	3	4	7	32893	217	131	26	118	kunkka	\N	21	38215	422	512
2526	192	3542687946	952	-7	5	10	6	28288	136	132	14	161	centaur	\N	23	36014	393	606
2527	187	3542815871	1052	-14	5	5	12	8646	13	0	2	24	lion	\N	14	16018	261	356
2528	208	3542815871	997	-14	2	8	7	10088	110	1	4	29	spectre	\N	14	11711	326	351
2529	202	3542815871	1033	-14	0	3	9	10963	78	2	3	0	phoenix	\N	14	11692	295	336
2530	198	3542815871	1011	-14	4	2	7	15146	95	3	9	125	clinkz	\N	15	12117	339	388
2531	207	3542815871	990	-14	3	8	12	9339	14	4	6	73	disruptor	\N	12	13869	187	257
2532	199	3542815871	990	14	11	12	3	23490	198	128	19	13322	luna	\N	20	12956	673	647
2533	209	3542815871	1000	14	8	13	1	8154	15	129	1	1595	bane	\N	15	6296	386	409
2534	191	3542815871	1038	14	6	13	3	9482	135	130	17	2420	invoker	\N	19	11168	554	593
2535	192	3542815871	945	14	13	16	5	24513	8	131	0	100	pudge	\N	16	21516	393	447
2536	205	3542815871	1025	14	9	16	3	9972	92	132	6	3586	omniknight	\N	18	12450	531	553
2537	198	3542905672	997	-11	2	12	9	14229	157	0	6	63	windrunner	\N	20	19467	338	525
2538	191	3542905672	1052	-11	0	14	6	20092	266	1	14	375	slark	\N	20	20459	420	557
2539	205	3542905672	1039	-11	17	7	6	25204	206	2	23	2219	monkey_king	\N	22	14900	514	638
2540	192	3542905672	959	-11	4	12	8	20143	61	3	3	0	pudge	\N	19	26410	303	468
2541	209	3542905672	1014	-11	8	11	7	8432	24	4	4	320	bane	\N	18	9784	273	432
2542	187	3542905672	1038	11	14	8	5	25343	154	128	19	4916	phantom_assassin	\N	23	13305	587	694
2543	199	3542905672	1004	11	2	15	8	6963	46	129	4	915	ogre_magi	\N	19	16190	318	471
2544	190	3542905672	985	11	0	18	10	10303	37	130	5	552	disruptor	\N	17	12101	297	408
2545	208	3542905672	983	11	13	8	4	14716	245	131	5	9183	broodmother	\N	25	16090	643	821
2546	202	3542905672	1019	11	6	11	6	14088	104	132	16	1737	slardar	\N	21	10807	437	594
2547	204	3542996960	993	13	3	11	3	7475	38	0	1	2247	lion	\N	16	5724	325	412
2548	199	3542996960	1015	13	6	7	2	7971	130	1	2	4873	faceless_void	\N	18	11422	485	526
2549	203	3542996960	1005	13	7	11	0	17467	135	2	21	4746	puck	\N	19	8197	510	549
2550	208	3542996960	994	13	11	5	2	17763	141	3	11	3924	ursa	\N	19	10626	550	578
2551	205	3542996960	1028	13	6	11	1	10811	17	4	5	2996	lich	\N	16	6014	327	412
2552	198	3542996960	986	-13	0	3	7	9673	95	128	3	0	abyssal_underlord	\N	15	15167	272	364
2553	191	3542996960	1041	-13	1	2	2	6187	219	129	11	574	naga_siren	\N	17	8047	421	469
2554	187	3542996960	1049	-13	0	2	8	10942	120	130	20	0	phantom_assassin	\N	14	12730	293	329
2555	202	3542996960	1030	-13	0	6	9	7253	48	131	7	0	vengefulspirit	\N	11	10796	200	209
2556	190	3542996960	996	-13	4	2	7	7928	16	132	1	0	ogre_magi	\N	12	14747	219	237
2557	198	3543082126	973	-5	7	28	12	51270	360	0	0	1086	venomancer	\N	25	32696	562	414
2558	191	3543082126	1028	-5	10	18	7	46178	506	1	14	3357	phantom_lancer	\N	25	34423	543	414
2559	200	3543082126	976	-5	13	9	12	42292	524	2	11	1957	luna	\N	25	38478	547	415
2560	192	3543082126	948	-5	5	24	8	41383	309	3	7	1476	centaur	\N	25	56459	414	426
2561	204	3543082126	1006	-5	9	23	14	11522	69	4	2	391	shadow_shaman	\N	25	28407	291	414
2562	206	3543082126	978	5	9	23	7	30689	94	128	6	334	lich	\N	25	26474	402	417
2577	196	3544760806	986	-6	4	8	8	11694	38	0	3	292	lion	\N	21	14786	228	421
2563	203	3543082126	1018	5	17	14	5	47010	437	129	33	2021	invoker	\N	25	33048	637	421
2564	199	3543082126	1028	5	15	17	7	41622	664	130	32	13292	faceless_void	\N	25	44191	768	414
2565	202	3543082126	1017	5	2	27	16	14016	101	131	0	214	spirit_breaker	\N	24	35644	261	377
2566	205	3543082126	1041	5	10	19	10	37936	391	132	19	11603	viper	\N	25	34098	525	414
2607	191	3545245498	1013	-11	6	17	3	30194	726	0	11	290	shredder	\N	25	30647	595	384
2608	192	3545245498	956	-11	9	13	9	8570	127	1	10	0	witch_doctor	\N	25	20796	271	389
2609	206	3545245498	983	-11	3	20	10	5698	150	2	1	34	rubick	\N	25	18743	249	385
2610	199	3545245498	1033	-11	6	12	8	18220	352	3	8	2909	faceless_void	\N	25	28729	402	396
2611	195	3545245498	1029	-11	16	13	5	62837	578	4	30	4706	gyrocopter	\N	25	25152	589	390
2612	187	3545245498	1064	11	17	3	6	41264	737	128	23	11616	sven	\N	25	34159	753	389
2613	189	3545245498	1006	11	8	18	8	40952	677	129	10	13556	sniper	\N	25	21477	701	384
2614	190	3545245498	974	11	6	21	8	17415	145	130	6	1042	warlock	\N	25	19797	361	385
2615	207	3545245498	976	11	1	19	11	7944	14	131	3	963	bane	\N	25	21532	197	385
2616	198	3545245498	958	11	3	13	8	16492	200	132	3	3700	abyssal_underlord	\N	25	28554	324	388
2567	190	3544586761	983	-9	8	12	8	31267	212	0	8	66	bristleback	\N	24	36635	385	523
2568	205	3544586761	1046	-9	8	3	9	12669	225	1	18	187	monkey_king	\N	24	33130	386	526
2569	189	3544586761	996	-9	4	6	5	19684	530	2	8	2066	naga_siren	\N	25	33269	628	572
2570	204	3544586761	1001	-9	3	11	6	17301	121	3	0	33	keeper_of_the_light	\N	21	19905	299	421
2571	200	3544586761	971	-9	4	11	6	9294	61	4	0	197	lion	\N	22	18655	257	435
2572	187	3544586761	1036	9	1	13	5	11088	119	128	3	748	ogre_magi	\N	24	22423	338	520
2573	191	3544586761	1023	9	13	10	4	37410	423	129	16	665	spectre	\N	25	19021	656	580
2574	195	3544586761	1020	9	11	16	7	48402	381	130	12	5768	gyrocopter	\N	25	20541	610	579
2575	198	3544586761	968	9	2	17	7	11469	249	131	5	3050	venomancer	\N	24	13997	543	541
2576	196	3544586761	977	9	6	16	5	33225	95	132	1	18	zuus	\N	25	14233	329	574
2578	191	3544760806	1032	-6	6	10	7	34850	281	1	22	271	bristleback	\N	24	24117	459	596
2579	198	3544760806	977	-6	9	6	11	25943	220	2	6	1148	clinkz	\N	25	23194	415	598
2580	200	3544760806	962	-6	3	5	7	19475	261	3	10	545	kunkka	\N	22	19423	386	452
2581	202	3544760806	1022	-6	1	11	8	12573	28	4	8	122	vengefulspirit	\N	18	15899	211	340
2582	204	3544760806	992	6	4	19	8	11512	125	128	21	2028	faceless_void	\N	22	24752	330	455
2583	189	3544760806	987	6	14	19	2	14996	81	129	2	401	riki	\N	25	7347	459	603
2584	187	3544760806	1045	6	17	7	6	34169	423	130	13	5692	sven	\N	25	34388	677	599
2585	209	3544760806	1003	6	0	27	2	10231	29	131	0	3944	ogre_magi	\N	23	19356	264	531
2586	205	3544760806	1037	6	5	14	5	25314	333	132	17	6919	venomancer	\N	24	17495	631	580
2597	202	3545063706	1008	5	5	23	13	23057	298	0	4	8746	pugna	\N	25	27120	393	354
2598	192	3545063706	951	5	5	12	11	13616	84	1	4	478	lion	\N	25	19307	290	354
2599	187	3545063706	1059	5	5	10	9	30863	796	2	16	10447	sven	\N	25	43097	660	354
2600	205	3545063706	1051	5	12	24	7	49638	495	3	23	8276	faceless_void	\N	25	52148	588	357
2601	189	3545063706	1001	5	19	21	1	51039	207	4	1	930	ancient_apparition	\N	25	14445	465	357
2602	204	3545063706	990	-5	10	13	8	32677	343	128	12	1819	death_prophet	\N	25	44249	390	354
2603	196	3545063706	988	-5	5	15	16	15066	66	129	1	0	witch_doctor	\N	25	28739	238	354
2604	200	3545063706	948	-5	1	19	8	28395	503	130	1	262	keeper_of_the_light	\N	25	29883	478	354
2605	198	3545063706	963	-5	4	27	8	36692	115	131	2	107	abaddon	\N	25	46305	287	355
2606	191	3545063706	1018	-5	21	9	7	54877	671	132	21	1632	juggernaut	\N	25	30627	632	354
2587	196	3544920819	980	8	2	12	10	11141	71	0	0	956	ogre_magi	\N	18	20395	306	309
2588	189	3544920819	993	8	10	18	1	17388	71	1	2	380	lich	\N	25	18064	427	586
2589	187	3544920819	1051	8	10	11	7	44429	245	2	25	5509	life_stealer	\N	25	50802	504	587
2590	205	3544920819	1043	8	13	17	8	28580	284	3	25	4513	storm_spirit	\N	25	35251	575	585
2591	192	3544920819	943	8	12	22	5	41756	309	4	12	7202	bristleback	\N	25	33803	588	601
2592	191	3544920819	1026	-8	8	9	10	33235	227	128	11	101	bloodseeker	\N	25	34991	402	589
2593	204	3544920819	998	-8	6	18	11	32316	112	129	10	495	centaur	\N	23	39432	313	503
2594	198	3544920819	971	-8	6	15	5	26456	235	130	1	107	venomancer	\N	25	16553	537	595
2595	200	3544920819	956	-8	3	7	13	11662	88	131	0	89	disruptor	\N	16	20513	246	272
2596	202	3544920819	1016	-8	5	17	9	44370	167	132	6	0	zuus	\N	25	21529	349	586
2626	207	3547048847	987	-5	1	14	7	9797	29	132	7	0	lion	\N	18	15244	258	355
2637	198	3547154304	964	-5	3	13	8	11512	108	0	3	171	beastmaster	\N	22	20581	310	490
2638	191	3547154304	997	-5	7	16	7	17010	230	1	22	846	faceless_void	\N	23	15605	436	534
2639	200	3547154304	938	-5	8	13	8	20536	88	2	4	143	abaddon	\N	24	27848	346	583
2640	205	3547154304	1061	-5	10	14	3	29405	230	3	25	1365	queenofpain	\N	25	16457	527	646
2641	207	3547154304	982	-5	4	7	12	5625	35	4	2	0	witch_doctor	\N	18	15519	261	340
2642	196	3547154304	988	5	1	19	10	16721	82	128	0	1049	earthshaker	\N	18	14888	310	335
2643	189	3547154304	1022	5	9	8	4	24198	515	129	42	9458	antimage	\N	25	16257	843	642
2644	195	3547154304	1023	5	13	10	8	40658	73	130	3	180	pudge	\N	23	35706	395	555
2617	196	3547048847	983	5	8	10	11	14850	116	0	3	4289	pugna	\N	18	24337	347	359
2618	189	3547048847	1017	5	5	15	4	22454	96	1	3	539	ogre_magi	\N	22	24492	376	529
2619	195	3547048847	1018	5	8	10	4	35679	321	2	22	15130	medusa	\N	24	14931	630	639
2620	193	3547048847	1016	5	2	13	7	19117	167	3	17	4388	abyssal_underlord	\N	21	30023	406	487
2621	205	3547048847	1056	5	4	12	6	13165	23	4	3	1748	phoenix	\N	19	15116	320	396
2622	198	3547048847	969	-5	14	14	6	49677	163	128	5	0	zuus	\N	24	19446	433	621
2623	191	3547048847	1002	-5	12	13	4	27180	281	129	17	251	spectre	\N	23	16952	467	557
2624	200	3547048847	943	-5	1	21	7	9831	53	130	1	0	spirit_breaker	\N	18	26351	226	358
2625	187	3547048847	1075	-5	4	17	4	11682	186	131	6	9	dark_seer	\N	22	26540	383	502
2645	187	3547154304	1070	5	3	21	6	4813	91	131	5	442	warlock	\N	22	13497	387	509
2646	193	3547154304	1021	5	11	12	9	23156	240	132	9	8728	sniper	\N	25	17276	560	642
2647	198	3547277729	959	-6	1	6	8	5814	14	0	4	0	rubick	\N	9	8353	168	190
2648	191	3547277729	992	-6	1	3	3	12422	107	1	22	132	juggernaut	\N	15	10404	344	471
2649	205	3547277729	1056	-6	1	1	9	7704	75	2	8	694	pugna	\N	11	11345	263	266
2650	199	3547277729	1022	-6	2	7	9	8523	10	3	0	0	lich	\N	9	10473	168	192
2651	206	3547277729	972	-6	6	3	7	8260	61	4	7	0	axe	\N	12	13315	310	308
2652	196	3547277729	993	6	4	10	8	8103	5	128	2	142	pudge	\N	11	11151	236	271
2653	189	3547277729	1027	6	10	6	0	8114	26	129	0	527	oracle	\N	15	2975	373	489
2654	195	3547277729	1028	6	10	17	2	19440	92	130	13	1351	monkey_king	\N	17	10798	486	579
2655	203	3547277729	1023	6	10	9	1	15266	143	131	12	427	storm_spirit	\N	18	9399	550	639
2656	193	3547277729	1026	6	1	7	2	6453	112	132	30	1083	abyssal_underlord	\N	15	11886	405	468
2657	196	3547333480	999	-12	4	4	13	7650	18	0	2	77	lion	\N	13	17295	182	208
2658	189	3547333480	1033	-12	3	6	10	9320	54	1	2	0	keeper_of_the_light	\N	17	15630	269	341
2659	191	3547333480	986	-12	5	5	8	16746	175	2	14	970	juggernaut	\N	21	22153	374	496
2660	195	3547333480	1034	-12	8	9	9	49011	185	3	21	988	skeleton_king	\N	21	64161	391	479
2661	193	3547333480	1032	-12	1	7	6	13838	56	4	15	26	nyx_assassin	\N	17	18744	269	343
2662	198	3547333480	953	12	4	9	5	12643	120	128	5	1878	doom_bringer	\N	21	17901	498	501
2663	206	3547333480	966	12	1	18	3	9175	68	129	7	1264	vengefulspirit	\N	21	8330	321	473
2664	203	3547333480	1029	12	21	10	3	40429	272	130	23	5386	storm_spirit	\N	25	13447	636	690
2665	199	3547333480	1016	12	13	18	1	27711	242	131	30	7986	spectre	\N	25	14747	589	692
2666	187	3547333480	1075	12	5	17	9	17196	45	132	6	1444	lich	\N	20	11311	298	462
2667	195	3549048284	1022	15	10	7	3	24392	244	0	25	7142	nevermore	\N	23	12127	527	600
2668	203	3549048284	1041	15	7	2	0	11852	469	1	16	9080	antimage	\N	25	10574	748	709
2669	191	3549048284	974	15	3	13	3	13477	41	2	4	561	ogre_magi	\N	19	13395	268	432
2670	202	3549048284	1013	15	5	8	1	12358	107	3	3	589	mirana	\N	20	7321	405	480
2671	192	3549048284	945	15	4	15	5	28799	221	4	29	4437	centaur	\N	23	32726	504	623
2672	199	3549048284	1028	-15	3	5	4	16203	222	128	18	1027	troll_warlord	\N	22	20963	442	568
2673	189	3549048284	1021	-15	3	3	3	11560	212	129	17	382	invoker	\N	22	13911	470	575
2674	187	3549048284	1087	-15	1	4	9	10092	46	130	3	34	lich	\N	17	12857	183	338
2675	193	3549048284	1020	-15	0	5	5	17633	190	131	19	501	abyssal_underlord	\N	19	18765	367	408
2676	207	3549048284	977	-15	5	4	8	10211	27	132	4	0	witch_doctor	\N	18	13938	289	372
2677	195	3549120144	1037	-12	7	9	9	35846	201	0	18	471	phantom_assassin	\N	20	18066	476	535
2678	191	3549120144	989	-12	3	6	5	8862	269	1	11	743	antimage	\N	21	11943	467	584
2679	187	3549120144	1072	-12	3	11	12	9085	53	2	2	113	shadow_shaman	\N	20	15461	298	536
2680	202	3549120144	1028	-12	6	8	8	12496	51	3	3	0	night_stalker	\N	19	23302	292	465
2681	193	3549120144	1005	-12	3	6	5	16314	50	4	5	78	nyx_assassin	\N	18	10926	302	441
2682	199	3549120144	1013	12	11	16	5	27859	181	128	10	3934	skeleton_king	\N	23	27119	538	683
2683	203	3549120144	1056	12	5	13	4	17207	213	129	32	2594	storm_spirit	\N	21	13108	498	552
2684	189	3549120144	1006	12	12	12	2	10751	26	130	2	522	oracle	\N	21	12718	348	573
2685	205	3549120144	1050	12	8	14	5	16047	173	131	4	2481	beastmaster	\N	24	16998	502	740
2686	192	3549120144	960	12	3	20	7	8370	25	132	10	814	witch_doctor	\N	18	13196	305	423
2687	192	3550640644	972	5	1	0	0	1165	19	0	6	0	slardar	\N	5	1758	345	446
2688	191	3550640644	977	5	0	0	0	937	31	1	2	0	clinkz	\N	5	926	368	447
2689	187	3550640644	1060	5	3	0	0	1554	27	2	7	0	phantom_assassin	\N	5	1026	470	379
2690	205	3550640644	1062	5	0	2	1	1090	0	3	0	0	lion	\N	3	804	141	122
2691	221	3550640644	1000	5	0	3	0	1703	0	4	0	0	witch_doctor	\N	3	1376	147	211
2692	200	3550640644	933	-5	0	1	2	1311	5	128	0	0	jakiro	\N	4	1945	235	243
2693	189	3550640644	1018	-5	1	0	1	906	3	129	0	0	sven	\N	2	1332	193	41
2694	193	3550640644	993	-5	0	0	0	149	11	130	0	0	omniknight	\N	2	190	282	82
2695	226	3550640644	1000	-5	0	0	0	1516	20	131	2	0	puck	\N	5	1458	400	430
2696	198	3550640644	965	-5	0	0	1	2008	14	132	1	0	tidehunter	\N	5	1524	381	340
2697	192	3550695993	977	5	12	11	7	20144	67	0	1	1821	witch_doctor	\N	21	11163	370	440
2698	203	3550695993	1068	5	8	9	1	41347	518	1	35	17753	antimage	\N	25	11785	825	645
2699	187	3550695993	1065	5	3	14	8	17786	167	2	17	1398	rubick	\N	22	17853	411	515
2700	205	3550695993	1067	5	5	14	9	17430	202	3	11	2909	razor	\N	22	19246	445	512
2701	226	3550695993	995	5	4	13	3	16069	71	4	4	591	ogre_magi	\N	22	17796	343	499
2702	198	3550695993	960	-5	2	14	7	12727	58	128	5	0	lich	\N	18	13184	289	355
2703	191	3550695993	982	-5	17	8	7	62358	351	129	9	95	meepo	\N	25	84475	613	642
2704	193	3550695993	988	-5	3	13	6	20081	174	130	6	288	zuus	\N	22	14044	347	519
2705	236	3550695993	1000	-5	2	8	8	14806	199	131	2	2065	centaur	\N	21	28499	358	440
2706	221	3550695993	1005	-5	4	7	5	3920	25	132	3	0	lion	\N	13	8623	202	208
2707	206	3552513216	978	6	8	13	3	25774	218	0	25	4597	viper	\N	23	15908	511	594
2708	203	3552513216	1073	6	10	8	0	23428	552	1	18	17619	antimage	\N	25	8479	867	673
2709	189	3552513216	1013	6	6	12	1	7235	35	2	2	2	riki	\N	23	3049	335	555
2710	202	3552513216	1016	6	3	13	7	10210	48	3	5	923	vengefulspirit	\N	18	13513	274	371
2711	198	3552513216	955	6	2	9	9	10749	148	4	1	209	doom_bringer	\N	19	22480	417	393
2712	200	3552513216	928	-6	2	10	4	13954	166	128	13	2598	abyssal_underlord	\N	19	17425	379	399
2713	199	3552513216	1025	-6	3	15	9	7189	51	129	1	399	spirit_breaker	\N	17	21080	258	319
2714	197	3552513216	1007	-6	11	6	2	27585	207	130	25	1838	phantom_assassin	\N	22	13891	495	524
2715	191	3552513216	977	-6	3	7	6	5435	223	131	10	2402	lone_druid	\N	20	11394	438	442
2716	209	3552513216	1009	-6	0	12	9	9326	29	132	5	238	lion	\N	15	13666	209	276
2717	221	3554323664	1000	-7	2	9	8	5513	39	0	3	0	disruptor	\N	19	17092	204	351
2718	191	3554323664	971	-7	6	11	6	23272	336	1	22	158	storm_spirit	\N	25	32171	464	568
2719	198	3554323664	961	-7	7	14	10	32448	230	2	1	0	venomancer	\N	25	18491	511	574
2720	200	3554323664	922	-7	5	12	11	30362	271	3	3	459	abyssal_underlord	\N	25	35617	449	563
2721	205	3554323664	1072	-7	7	5	13	19727	264	4	11	3428	troll_warlord	\N	25	29058	479	563
2722	196	3554323664	987	7	4	19	3	18298	59	128	0	694	earthshaker	\N	25	16460	303	567
2723	213	3554323664	1000	7	10	22	9	42081	202	129	14	5413	omniknight	\N	24	39841	539	535
2724	234	3554323664	1000	7	6	22	9	18818	29	130	0	1315	lich	\N	23	24604	295	495
2725	206	3554323664	984	7	15	17	4	43294	312	131	15	15040	death_prophet	\N	25	29234	600	560
2726	202	3554323664	1022	7	12	8	3	21969	249	132	10	2688	phantom_assassin	\N	25	13214	494	561
2727	198	3554449842	954	15	4	13	6	13459	215	0	3	1222	venomancer	\N	21	13363	539	468
2728	191	3554449842	964	15	4	18	0	37232	353	1	34	5521	spectre	\N	25	15794	584	672
2729	213	3554449842	1007	15	0	9	6	18956	171	2	8	1831	centaur	\N	21	26723	376	470
2730	188	3554449842	965	15	10	12	4	39136	148	3	5	819	zuus	\N	23	15232	420	577
2731	248	3554449842	1000	15	4	11	4	14300	29	4	13	518	lich	\N	21	7330	245	492
2732	200	3554449842	915	-15	2	5	6	6235	41	128	5	224	omniknight	\N	16	22988	258	288
2733	205	3554449842	1065	-15	8	3	6	29994	264	129	12	3085	viper	\N	22	24804	512	550
2734	187	3554449842	1070	-15	3	4	3	29241	258	130	25	789	life_stealer	\N	22	44081	450	510
2735	206	3554449842	991	-15	7	8	5	15330	124	131	6	643	night_stalker	\N	22	29559	388	520
2736	221	3554449842	993	-15	0	10	3	7465	40	132	4	371	vengefulspirit	\N	17	11474	203	326
2737	187	3554525848	1055	-15	4	7	9	9983	435	0	8	2435	antimage	\N	25	21279	597	611
2738	189	3554525848	1019	-15	17	8	4	40948	195	1	7	0	monkey_king	\N	25	9240	543	632
2739	198	3554525848	969	-15	3	9	9	16672	104	2	8	48	windrunner	\N	21	19407	310	421
2740	207	3554525848	962	-15	3	17	9	35986	192	3	2	82	zuus	\N	24	19773	375	561
2741	248	3554525848	1015	-15	2	9	13	10332	36	4	9	0	vengefulspirit	\N	14	16454	201	210
2742	205	3554525848	1050	15	2	14	10	11061	89	128	3	796	venomancer	\N	22	19552	394	463
2743	191	3554525848	979	15	19	10	4	30257	298	129	50	1928	bloodseeker	\N	25	30602	626	614
2744	188	3554525848	980	15	9	13	0	44651	253	130	8	11525	dragon_knight	\N	25	41426	552	614
2745	221	3554525848	978	15	2	21	6	6670	78	131	0	729	sand_king	\N	21	16068	326	449
2746	200	3554525848	900	15	10	19	9	14232	250	132	4	6066	abyssal_underlord	\N	24	26991	541	593
2747	187	3554599628	1040	13	1	8	10	4457	21	0	3	457	night_stalker	\N	14	13495	256	330
2748	188	3554599628	995	13	6	15	6	14092	66	1	18	0	rattletrap	\N	17	14925	391	502
2749	189	3554599628	1004	13	14	8	0	18038	352	2	71	6905	antimage	\N	25	6243	905	1002
2750	206	3554599628	976	13	13	7	2	12368	136	3	7	3315	mirana	\N	21	13021	575	686
2751	200	3554599628	915	13	1	4	3	3323	26	4	3	249	lich	\N	13	5123	225	299
2752	205	3554599628	1065	-13	5	12	10	26121	110	128	2	19	zuus	\N	16	14905	387	468
2753	191	3554599628	994	-13	9	6	3	13852	171	129	44	914	faceless_void	\N	19	9531	516	606
2754	198	3554599628	954	-13	4	6	5	6058	132	130	0	60	venomancer	\N	16	8126	463	463
2755	248	3554599628	1000	-13	2	4	8	5075	22	131	2	0	pudge	\N	11	13188	189	219
2756	221	3554599628	993	-13	1	8	10	4389	15	132	0	0	crystal_maiden	\N	12	9216	192	260
2757	187	3554656831	1053	5	2	2	2	5765	243	0	6	10042	sven	\N	19	6381	653	577
2758	188	3554656831	1008	5	7	3	4	21113	131	1	7	897	vengefulspirit	\N	19	12185	512	580
2759	189	3554656831	1017	5	14	6	0	28403	126	2	6	1759	monkey_king	\N	22	6545	660	753
2760	205	3554656831	1052	5	3	6	7	4571	45	3	1	536	shadow_shaman	\N	14	9179	352	365
2761	198	3554656831	941	5	2	12	2	8762	67	4	6	1531	ogre_magi	\N	19	7335	426	589
2762	196	3554656831	994	-5	3	7	6	7875	25	128	0	80	earthshaker	\N	13	8625	205	310
2763	206	3554656831	989	-5	5	6	8	12670	105	129	20	0	bloodseeker	\N	17	18525	374	489
2764	199	3554656831	1019	-5	5	4	2	18439	190	130	18	1551	skeleton_king	\N	17	24226	494	498
2765	248	3554656831	987	-5	1	3	7	5404	74	131	35	256	lich	\N	14	10404	297	372
2766	221	3554656831	980	-5	1	4	5	3043	47	132	16	255	undying	\N	12	12640	223	251
\.


--
-- Name: player_match_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.player_match_stats_id_seq', 2766, true);


--
-- Name: player_steam_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.player_steam_id_seq', 1, false);


--
-- Data for Name: season; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.season (id, number, started, ended, place_1, place_2, place_3) FROM stdin;
1	1	2015-02-23 20:10:07	2015-03-20 00:00:00	76561198074711025	76561198050981415	76561198062517379
2	2	2015-08-10 21:50:40	2015-08-20 21:37:00	76561198050981415	76561198078115598	76561198006183979
3	3	2016-02-14 21:38:00	2017-04-02 05:12:00	76561198122375492	76561198050981415	76561198047815659
4	4	2017-11-02 05:12:00	\N	\N	\N	\N
\.


--
-- Name: season_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.season_id_seq', 4, true);


--
-- Data for Name: season_stats; Type: TABLE DATA; Schema: public; Owner: gleague
--

COPY public.season_stats (id, season_id, steam_id, wins, losses, pts, streak, longest_winstreak, longest_losestreak) FROM stdin;
5	1	76561198062081877	22	19	1026	2	3	4
48	1	76561198044189044	1	2	990	-1	1	1
51	1	76561198068053655	0	1	990	-1	0	1
2	1	76561198053792883	2	0	1020	2	2	0
49	1	76561197968587871	0	4	962	-4	0	4
39	1	76561198140337230	1	8	931	-7	1	7
33	1	76561198016217359	6	5	1006	-2	5	2
20	1	76561198046244483	3	4	988	1	1	2
52	1	76561198073971993	1	1	1000	1	1	1
55	1	76561198114085939	1	4	974	1	1	4
53	1	76561198097757646	0	3	972	-3	0	3
22	1	76561198011090115	5	1	1041	2	3	1
56	1	76561198145970413	0	1	991	-1	0	1
57	1	76561198074266816	0	1	993	-1	0	1
14	1	76561198054682692	0	1	990	-1	0	1
36	1	76561198100751924	0	1	989	-1	0	1
16	1	76561197988794786	1	0	1010	1	1	0
19	1	76561198025119322	0	1	990	-1	0	1
18	1	76561198029001894	2	0	1020	2	2	0
46	1	76561198103774744	10	3	1066	6	6	2
8	1	76561198155142404	31	32	997	-6	10	6
50	1	76561198041583699	4	4	1002	-2	2	2
58	1	76561198072791186	0	3	970	-3	0	3
1	1	76561198050981415	56	45	1102	-1	5	3
10	1	76561198064103935	42	41	1000	1	8	6
11	1	76561198125222713	36	29	1064	-2	5	4
40	1	76561198047190001	2	2	1002	-2	2	2
6	1	76561198029784649	19	26	941	-4	4	7
44	1	76561198056481765	2	2	1000	1	1	1
21	1	76561198064640960	2	5	971	-2	2	3
13	1	76561197981436383	41	35	1051	3	7	5
17	1	76561197977893604	8	14	940	-2	2	4
25	1	76561198015535768	3	6	970	-2	2	3
26	1	76561198084230991	13	13	996	1	4	5
29	1	76561198074711025	26	12	1130	3	6	3
45	1	76561198139750363	3	5	983	-4	2	4
30	1	76561198047287923	11	6	1052	4	4	3
3	1	76561198047012382	21	26	959	-1	4	5
54	1	76561198073588713	1	0	1009	1	1	0
4	1	76561198049220301	29	31	989	3	5	8
31	1	76561198154638721	7	14	932	-4	3	4
7	1	76561198073202489	3	2	1010	1	2	2
41	1	76561198047431797	0	1	989	-1	0	1
27	1	76561198036168458	4	4	1003	1	3	4
23	1	76561198013030157	10	6	1047	2	4	3
43	1	76561198031559450	3	2	1007	1	2	2
42	1	76561198063209393	1	2	991	-1	1	1
15	1	76561198006183979	12	11	1012	-2	3	2
28	1	76561198070896680	4	4	997	-2	3	2
32	1	76561197978556490	4	5	991	-2	2	2
34	1	76561198049523020	4	5	996	2	2	2
47	1	76561197984868652	2	4	981	-1	1	2
35	1	76561197984825338	9	6	1030	1	4	2
38	1	76561198062517379	32	23	1080	-3	7	3
12	1	76561198078115598	4	8	962	-1	2	3
37	1	76561198110443918	9	18	910	2	2	9
9	1	76561198047822188	7	8	985	-1	4	6
73	2	76561198046244483	1	2	998	-2	1	2
63	2	76561198103774744	1	0	1010	1	1	0
74	2	76561198047431797	1	0	1010	1	1	0
80	2	76561197993923694	0	1	991	-1	0	1
60	2	76561198050981415	24	3	1151	20	20	2
69	2	76561198074711025	5	8	974	-1	2	2
67	2	76561198006183979	5	4	1007	2	3	3
75	2	76561198053792883	3	5	983	-3	3	3
61	2	76561198050567489	10	9	1000	1	3	2
82	2	76561198040981068	1	0	1006	1	1	0
72	2	76561198036168458	1	2	988	1	1	2
62	2	76561198041583699	10	9	1005	2	3	3
65	2	76561198047822188	7	6	1005	-3	6	3
81	2	76561198047223952	1	0	1007	1	1	0
70	2	76561198016217359	6	8	979	-1	3	3
71	2	76561197997266515	7	9	1000	-1	2	3
78	2	76561198056236087	7	9	987	1	2	3
88	2	76561198166729266	1	0	1005	1	1	0
89	2	76561198063645309	0	1	995	-1	0	1
66	2	76561198122375492	9	10	991	-1	5	3
90	2	76561198157310514	0	1	995	-1	0	1
68	2	76561198029784649	2	6	968	-2	1	3
59	2	76561198049220301	11	15	982	1	3	6
76	2	76561198049386294	1	4	975	-2	1	2
77	2	76561198061772583	2	2	991	-1	1	1
64	2	76561198078115598	12	11	1008	1	3	3
79	2	76561198070896680	4	6	995	-2	2	2
84	2	76561198047287923	1	0	1005	1	1	0
83	2	76561198097757646	1	1	999	1	1	1
85	2	76561197981436383	0	2	990	-2	0	2
86	2	76561198052402193	1	1	1000	-1	1	1
93	3	76561198067027003	2	1	1014	2	2	1
97	3	76561198074711025	18	17	1021	3	5	5
91	3	76561198050567489	12	11	1002	1	4	4
96	3	76561198050981415	60	42	1101	-3	9	8
94	3	76561198086133183	0	2	985	-2	0	2
102	3	76561198054368968	0	1	992	-1	0	1
100	3	76561198056568682	3	1	1021	2	2	1
92	3	76561198062517379	32	28	1012	1	5	6
101	3	76561197997266515	2	4	983	1	1	2
95	3	76561198049220301	48	39	1036	1	7	6
98	3	76561198047815659	45	41	1076	-1	5	6
106	3	76561198122375492	48	26	1113	-1	10	4
104	3	76561197981436383	2	7	965	-2	2	5
99	3	76561198047822188	7	8	1010	4	4	7
107	3	76561198053792883	16	18	1013	1	3	5
105	3	76561198047012382	16	14	1016	-3	6	3
108	3	76561198070896680	0	7	948	-7	0	7
109	3	76561198041583699	13	14	977	-5	5	5
103	3	76561198052402193	3	2	1002	1	2	2
154	3	76561198203934173	6	4	998	-1	2	1
110	3	76561198000576954	2	2	1001	1	1	2
164	3	76561198243575514	5	7	974	-5	4	5
112	3	76561197996770593	2	2	999	2	2	2
111	3	76561198006183979	15	13	993	-1	6	5
156	3	76561198140337230	0	1	995	-1	0	1
162	3	76561198012217055	0	1	994	-1	0	1
170	3	76561198045178572	0	3	982	-3	0	3
125	3	76561198029784649	0	1	985	-1	0	1
113	3	76561198078115598	9	19	954	-3	2	4
140	3	76561198047287923	2	8	951	-7	1	7
118	3	76561198020742538	1	0	1009	1	1	0
175	3	76561198087315989	3	4	991	-4	3	4
127	3	76561198011090115	0	1	993	-1	0	1
161	3	76561198066455570	0	1	985	-1	0	1
129	3	76561198016217359	26	23	1056	1	5	3
136	3	76561198158099214	3	0	1018	3	3	0
115	3	76561198064103935	4	7	989	-5	3	5
152	3	76561198349109618	1	0	1005	1	1	0
153	3	76561198092655025	0	1	995	-1	0	1
116	3	76561198125222713	19	25	957	1	3	5
117	3	76561198062081877	6	19	945	1	3	13
169	3	76561198068053655	1	0	1005	1	1	0
114	3	76561198049386294	22	25	962	1	5	5
155	3	76561198321243292	6	4	1012	-1	3	1
132	3	76561198155142404	6	9	990	-2	3	6
120	3	76561198029001894	0	1	985	-1	0	1
139	3	76561198015535768	2	1	1019	2	2	1
163	3	76561198029055164	5	3	1015	1	2	2
157	3	76561198070524578	25	28	1005	3	3	4
177	3	76561198026718418	0	1	985	-1	0	1
135	3	76561198334460348	23	23	983	-1	5	4
167	3	76561198160172458	2	0	1012	2	2	0
168	3	76561198123893031	0	2	988	-2	0	2
176	3	76561198077176110	2	3	983	-2	2	2
187	4	76561198334460348	23	11	1058	2	5	2
194	4	76561198029055164	1	0	1010	1	1	0
208	4	76561198047822188	3	2	1007	2	2	1
204	4	76561198074711025	2	5	985	-2	1	2
188	4	76561198006183979	6	6	1013	4	4	3
201	4	76561198077196808	2	0	1018	2	2	0
186	4	76561198062081877	1	4	973	-1	1	3
189	4	76561198047815659	14	8	1022	2	7	2
196	4	76561197996770593	12	11	989	-1	3	3
197	4	76561198045178572	2	2	1001	-2	2	2
198	4	76561198049220301	11	20	946	1	3	5
191	4	76561198050981415	14	21	981	-1	4	8
190	4	76561198053792883	3	5	985	1	2	3
206	4	76561198125222713	5	6	984	-1	3	2
207	4	76561198049386294	1	7	947	-4	1	4
200	4	76561198047012382	4	16	928	2	2	12
221	4	76561198078115598	2	5	975	-2	1	3
226	4	76561198092655025	1	1	1000	1	1	1
209	4	76561198166729266	2	2	1003	-1	1	1
234	4	76561198029001894	1	0	1007	1	1	0
213	4	76561198050567489	2	0	1022	2	2	0
195	4	76561198016217359	11	6	1025	-1	3	2
192	4	76561198070524578	10	13	982	4	4	4
193	4	76561198041583699	10	9	983	-5	7	5
236	4	76561198056236087	0	1	995	-1	0	1
203	4	76561198432160076	11	2	1079	8	8	2
202	4	76561198026718418	12	7	1029	2	3	2
199	4	76561198122375492	12	12	1014	-2	5	3
205	4	76561198062517379	16	10	1057	1	5	2
248	4	76561198047223952	1	3	982	-3	1	3
\.


--
-- Name: season_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gleague
--

SELECT pg_catalog.setval('public.season_stats_id_seq', 275, true);


--
-- Name: match_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (id);


--
-- Name: player_match_item_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_item
    ADD CONSTRAINT player_match_item_pkey PRIMARY KEY (id);


--
-- Name: player_match_rating_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_rating
    ADD CONSTRAINT player_match_rating_pkey PRIMARY KEY (id);


--
-- Name: player_match_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_stats
    ADD CONSTRAINT player_match_stats_pkey PRIMARY KEY (id);


--
-- Name: player_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (steam_id);


--
-- Name: rated_once; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_rating
    ADD CONSTRAINT rated_once UNIQUE (rated_by_steam_id, player_match_stats_id);


--
-- Name: season_number_key; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season
    ADD CONSTRAINT season_number_key UNIQUE (number);


--
-- Name: season_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season
    ADD CONSTRAINT season_pkey PRIMARY KEY (id);


--
-- Name: season_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season_stats
    ADD CONSTRAINT season_stats_pkey PRIMARY KEY (id);


--
-- Name: match_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player_match_item_player_match_stats_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_item
    ADD CONSTRAINT player_match_item_player_match_stats_id_fkey FOREIGN KEY (player_match_stats_id) REFERENCES public.player_match_stats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player_match_rating_player_match_stats_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_rating
    ADD CONSTRAINT player_match_rating_player_match_stats_id_fkey FOREIGN KEY (player_match_stats_id) REFERENCES public.player_match_stats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player_match_rating_rated_by_steam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_rating
    ADD CONSTRAINT player_match_rating_rated_by_steam_id_fkey FOREIGN KEY (rated_by_steam_id) REFERENCES public.player(steam_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player_match_stats_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_stats
    ADD CONSTRAINT player_match_stats_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player_match_stats_season_stats_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.player_match_stats
    ADD CONSTRAINT player_match_stats_season_stats_id_fkey FOREIGN KEY (season_stats_id) REFERENCES public.season_stats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: season_place_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season
    ADD CONSTRAINT season_place_1_fkey FOREIGN KEY (place_1) REFERENCES public.player(steam_id);


--
-- Name: season_place_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season
    ADD CONSTRAINT season_place_2_fkey FOREIGN KEY (place_2) REFERENCES public.player(steam_id);


--
-- Name: season_place_3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season
    ADD CONSTRAINT season_place_3_fkey FOREIGN KEY (place_3) REFERENCES public.player(steam_id);


--
-- Name: season_stats_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season_stats
    ADD CONSTRAINT season_stats_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: season_stats_steam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gleague
--

ALTER TABLE ONLY public.season_stats
    ADD CONSTRAINT season_stats_steam_id_fkey FOREIGN KEY (steam_id) REFERENCES public.player(steam_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

