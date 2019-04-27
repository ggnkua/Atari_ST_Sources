/* Some unit tests for the records - to check formatting of entries */

#include <stdio.h>
#include "record.h"

/* global variables to hold statistics */
int total_tests = 0;
int passed_tests = 0;
int failed_tests = 0;
int last_failed = 0;

/* function for checking result of a single test */
void test (char* message, int result) {
	total_tests += 1;

	if (result) {
		passed_tests += 1;
		if (last_failed) printf ("\n");
		printf (".");
		last_failed = 0;
	} else {
		failed_tests += 1;
		printf ("\nFailed test %d: %s", total_tests, message);
		last_failed = 1;
	}
}

/* create example records */
struct record * make_eg1 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "article";
	add_key_value (rec, "author", "Ludwig Beethoven");
	add_key_value (rec, "year", "2015");
	add_key_value (rec, "title", "A new paper");
	add_key_value (rec, "journal", "Special Journal");
	add_key_value (rec, "pages", "1-30");
	add_key_value (rec, "volume", "10");

	return rec;
}

struct record * make_eg2 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "article";
	add_key_value (rec, "author", "Beethoven, Ludwig");
	add_key_value (rec, "year", "2015");
	add_key_value (rec, "title", "A new paper");
	add_key_value (rec, "journal", "Special Journal");
	add_key_value (rec, "pages", "1-30");
	add_key_value (rec, "volume", "10");

	return rec;
}

struct record * make_eg3 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "article";
	add_key_value (rec, "author", "Beethoven, Jr, Ludwig");
	add_key_value (rec, "year", "2015");
	add_key_value (rec, "title", "A new paper");
	add_key_value (rec, "journal", "Special Journal");
	add_key_value (rec, "pages", "1-30");
	add_key_value (rec, "volume", "10");

	return rec;
}

struct record * make_eg4 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "article";
	add_key_value (rec, "author", "L. Beethoven and I. Stravinsky");
	add_key_value (rec, "year", "2015");
	add_key_value (rec, "title", "A new paper");
	add_key_value (rec, "journal", "Special Journal");
	add_key_value (rec, "pages", "1-30");
	add_key_value (rec, "volume", "10");

	return rec;
}

struct record * make_eg5 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "book";
	add_key_value (rec, "author", "Beethoven, L. and Stravinsky, I.");
	add_key_value (rec, "year", "2015");
	add_key_value (rec, "title", "A new book");
	add_key_value (rec, "publisher", "Special Press");
	add_key_value (rec, "address", "London, UK");

	return rec;
}

struct record * make_eg6 (void) {
	struct record * rec = new_record ();

	rec->id = "Xyz13";
	rec->type = "incollection";
	add_key_value (rec, "author", "L. Beethoven");
	add_key_value (rec, "title", "My symphonies");
	add_key_value (rec, "editor", "I. Stravinsky");
	add_key_value (rec, "booktitle", "Musical Collection");
	add_key_value (rec, "pages", "1-30");
	add_key_value (rec, "year", "2015");

	return rec;
}

struct record * make_eg7 (void) {
	struct record * rec = new_record ();

	add_key_value (rec, "author", "F. Gobet and A. {de Voogt} and J. Retschitzki");

	return rec;
}

/* test creation of citation */
void test_citation_1 (void) {
	struct record * rec = make_eg1 ();
	char * got = record_citation (rec);
	char * want = "(Beethoven, 2015)";

	test ("citation 1", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_citation_2 (void) {
	struct record * rec = make_eg2 ();
	char * got = record_citation (rec);
	char * want = "(Beethoven, 2015)";

	test ("citation 2", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_citation_3 (void) {
	struct record * rec = make_eg3 ();
	char * got = record_citation (rec);
	char * want = "(Beethoven Jr, 2015)";

	test ("citation 3", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_citation_4 (void) {
	struct record * rec = make_eg4 ();
	char * got = record_citation (rec);
	char * want = "(Beethoven and Stravinsky, 2015)";

	test ("citation 4", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_citation_5 (void) {
	struct record * rec = make_eg5 ();
	char * got = record_citation (rec);
	char * want = "(Beethoven and Stravinsky, 2015)";

	test ("citation 5", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_citation_7 (void) {
	struct record * rec = make_eg7 ();
	char * got = record_citation (rec);
	char * want = "(Gobet, de Voogt and Retschitzki, n.d.)";

	test ("citation 7", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

/* test creation of Harvard reference */
void test_harvard_1 (void) {
	struct record * rec = make_eg1 ();
	char * got = record_harvard (rec);
	char * want = "Beethoven, Ludwig (2015). A new paper, Special Journal, 10:1-30";

	test ("Harvard 1", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_harvard_4 (void) {
	struct record * rec = make_eg4 ();
	char * got = record_harvard (rec);
	char * want = "Beethoven, L. and Stravinsky, I. (2015). A new paper, Special Journal, 10:1-30";

	test ("Harvard 4", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_harvard_5 (void) {
	struct record * rec = make_eg5 ();
	char * got = record_harvard (rec);
	char * want = "Beethoven, L. and Stravinsky, I. (2015). A new book. (London, UK: Special Press)";

	test ("Harvard 5", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

void test_harvard_6 (void) {
	struct record * rec = make_eg6 ();
	char * got = record_harvard (rec);
	char * want = "Beethoven, L. (2015). My symphonies. In Stravinsky, I. (Eds.), Musical Collection, pp.1-30";

	test ("Harvard 6", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

/* test creation of IEEE reference */
void test_ieee_1 (void) {
	struct record * rec = make_eg1 ();
	char * got = record_ieee (rec);
	char * want = "Ludwig Beethoven, A new paper, Special Journal, 10:1-30, 2015";

	test ("IEEE 1", strcmp(got, want) == 0);

	free (got);
	free_record (rec);
}

/* main routine, to run the tests */
int main (int argc, char ** argv) {
	printf ("Testing BibFind:\n");

	test_citation_1 ();
	test_citation_2 ();
	test_citation_3 ();
	test_citation_4 ();
	test_citation_5 ();
	test_citation_7 ();

	test_harvard_1 ();
	test_harvard_4 ();
	test_harvard_5 ();
	test_harvard_6 ();

	test_ieee_1 ();

	printf ("\n\nRan %d tests.  %d passed, %d failed.\n", total_tests, passed_tests, failed_tests);

	return 0;
}