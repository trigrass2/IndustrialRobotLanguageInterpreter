/*
 * VISITOR.HH
 *
 *
 * The asbract syntax tree is scaned several times
 * during the whole compilation process. For e.g., stage 3 verifies
 * semantics, and stage 4 produces output.
 *
 * Since the number of functions that need to scan through
 * the abtract syntax tree may increase in time, (e.g. new
 * output formats, new semantic checks, etc...) while the
 * abstract syntax tree class structure is pretty stable
 * (i.e. the ST and IL languages will not be changing much...),
 * we use the 'visitor' design patern.
 *
 * It is not strictly necessary to use this pattern, but it does
 * have the advantage of bringing together the functions
 * that implement the same algorithm, each on a different
 * class of object in the abstract syntax tree.
 *
 *
 * This file contains the interface that each visitor class
 * must implement in order to be able to visit the abstract
 * syntax tree (class visitor_c)
 *
 * Three implementations of this interface are also provided,
 * that may be later extended to execute a particular algorithm.
 *
 * The null (class null_visitor_c) does nothing.
 *
 * The iterator (class iterator_visitor_c) iterates through
 * every object in the syntax tree.
 *
 * The search class (class search_visitor_c) iterates through
 * every object, until one returns a value != NULL.
 */


#ifndef _VISITOR_HH
#define _VISITOR_HH




#include "absyntax.hh"



#define SYM_LIST(class_name_c)	\
  virtual void *visit(class_name_c *symbol) = 0;

#define SYM_TOKEN(class_name_c)	\
  virtual void *visit(class_name_c *symbol) = 0;

#define SYM_REF0(class_name_c)	\
  virtual void *visit(class_name_c *symbol) = 0;

#define SYM_REF2(class_name_c, ref1, ref2)	\
  virtual void *visit(class_name_c *symbol) = 0;


class visitor_c {
  public:
  #include "absyntax.def"

  virtual ~visitor_c(void);
};

#undef SYM_LIST
#undef SYM_TOKEN
#undef SYM_REF0
#undef SYM_REF2




#define SYM_LIST(class_name_c)	\
  virtual void *visit(class_name_c *symbol);

#define SYM_TOKEN(class_name_c)	\
  virtual void *visit(class_name_c *symbol);

#define SYM_REF0(class_name_c)	\
  virtual void *visit(class_name_c *symbol);

#define SYM_REF2(class_name_c, ref1, ref2)	\
  virtual void *visit(class_name_c *symbol);




class null_visitor_c: public visitor_c {
  public:
  #include "absyntax.def"

  virtual ~null_visitor_c(void);
};



class iterator_visitor_c: public visitor_c {
  protected:
  void *visit_list(list_c *list);

  public:
  #include "absyntax.def"

  virtual ~iterator_visitor_c(void);
};


class search_visitor_c: public visitor_c {
  protected:
  void *visit_list(list_c *list);

  public:
  #include "absyntax.def"

  virtual ~search_visitor_c(void);
};


#undef SYM_LIST
#undef SYM_TOKEN
#undef SYM_REF0
#undef SYM_REF2


#endif /*  _VISITOR_HH */
