(*  Title:       Safe OCL
    Author:      Denis Nikiforov, March 2019
    Maintainer:  Denis Nikiforov <denis.nikif at gmail.com>
    License:     LGPL
*)
chapter \<open>Types\<close>
theory OCL_Types
  imports Tuple Errorable "HOL-Library.Phantom_Type"
begin

(*** Definition *************************************************************)

section \<open>Definition\<close>

text \<open>
  Types are parameterized over classes.\<close>

type_synonym 'a enum_type = "('a, String.literal) phantom"
type_synonym elit = String.literal
type_synonym telem = String.literal
datatype collection_kind =
  CollectionKind | SetKind | OrderedSetKind | BagKind | SequenceKind

datatype (plugins del: size) 'a type =
  OclAny
| OclVoid

| Boolean
| Real
| Integer
| UnlimitedNatural
| String

| Enum "'a enum_type"
| ObjectType 'a ("\<langle>_\<rangle>\<^sub>\<T>" [0] 1000)
| Tuple "telem \<rightharpoonup>\<^sub>f 'a type\<^sub>N"

| Collection "'a type\<^sub>N"
| Set "'a type\<^sub>N"
| OrderedSet "'a type\<^sub>N"
| Bag "'a type\<^sub>N"
| Sequence "'a type\<^sub>N"

| Map "'a type\<^sub>N" "'a type\<^sub>N"

and 'a type\<^sub>N =
  Required "'a type" ("_[\<^bold>1]" [1000] 1000)
| Optional "'a type" ("_[\<^bold>?]" [1000] 1000)


type_synonym 'a type\<^sub>N\<^sub>E = "'a type\<^sub>N errorable"


primrec type_size :: "'a type \<Rightarrow> nat"
    and type_size\<^sub>N :: "'a type\<^sub>N \<Rightarrow> nat" where

  "type_size OclAny = 0"
| "type_size OclVoid = 0"

| "type_size Boolean = 0"
| "type_size Real = 0"
| "type_size Integer = 0"
| "type_size UnlimitedNatural = 0"
| "type_size String = 0"

| "type_size (Enum \<E>) = 0"
| "type_size (ObjectType \<C>) = 0"
| "type_size (Tuple \<pi>) = Suc (ffold tcf 0 (fset_of_fmap (fmmap type_size\<^sub>N \<pi>)))"

| "type_size (Collection \<tau>) = Suc (type_size\<^sub>N \<tau>)"
| "type_size (Set \<tau>) = Suc (type_size\<^sub>N \<tau>)"
| "type_size (OrderedSet \<tau>) = Suc (type_size\<^sub>N \<tau>)"
| "type_size (Bag \<tau>) = Suc (type_size\<^sub>N \<tau>)"
| "type_size (Sequence \<tau>) = Suc (type_size\<^sub>N \<tau>)"

| "type_size (Map \<tau> \<sigma>) = Suc (type_size\<^sub>N \<tau> + type_size\<^sub>N \<sigma>)"

| "type_size\<^sub>N (Required \<tau>) = Suc (type_size \<tau>)"
| "type_size\<^sub>N (Optional \<tau>) = Suc (type_size \<tau>)"

lemma Tuple_type_size\<^sub>N_intro [intro]:
  "\<tau> |\<in>| fmran \<pi> \<Longrightarrow>
   type_size\<^sub>N \<tau> < Suc (ffold tcf 0 (fset_of_fmap (fmmap type_size\<^sub>N \<pi>)))"
  using fmran'I by fastforce

instantiation type :: (type) size
begin
definition size_type where [simp, code]: "size_type \<equiv> type_size"
instance ..
end

instantiation type\<^sub>N :: (type) size
begin
definition size_type\<^sub>N where [simp, code]: "size_type\<^sub>N \<equiv> type_size\<^sub>N"
instance ..
end

text \<open>
  Please take a note that the @{text "UnlimitedNatural"} type is not a subtype
  of the @{text "Integer"} type.\<close>

inductive subtype :: "'a::order type \<Rightarrow> 'a type \<Rightarrow> bool" (infix "\<sqsubset>" 65)
      and subtype\<^sub>N :: "'a type\<^sub>N \<Rightarrow> 'a type\<^sub>N \<Rightarrow> bool" (infix "\<sqsubset>\<^sub>N" 65) where

\<comment> \<open>Basic Types\<close>

  "OclVoid \<sqsubset> Boolean"
| "OclVoid \<sqsubset> Integer"
| "OclVoid \<sqsubset> UnlimitedNatural"
| "OclVoid \<sqsubset> String"
| "OclVoid \<sqsubset> \<langle>\<C>\<rangle>\<^sub>\<T>"
| "OclVoid \<sqsubset> Enum \<E>"

| "Integer \<sqsubset> Real"
| "\<C> < \<D> \<Longrightarrow> \<langle>\<C>\<rangle>\<^sub>\<T> \<sqsubset> \<langle>\<D>\<rangle>\<^sub>\<T>"

| "Boolean \<sqsubset> OclAny"
| "Real \<sqsubset> OclAny"
| "UnlimitedNatural \<sqsubset> OclAny"
| "String \<sqsubset> OclAny"
| "\<langle>\<C>\<rangle>\<^sub>\<T> \<sqsubset> OclAny"
| "Enum \<E> \<sqsubset> OclAny"

\<comment> \<open>Tuple Types\<close>

| "OclVoid \<sqsubset> Tuple \<pi>"
| "strict_subtuple (\<lambda>\<tau> \<sigma>. \<tau> \<sqsubset>\<^sub>N \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi> \<Longrightarrow>
   Tuple \<pi> \<sqsubset> Tuple \<xi>"
| "Tuple \<pi> \<sqsubset> OclAny"

\<comment> \<open>Collection Types\<close>

| "OclVoid \<sqsubset> Set OclVoid[\<^bold>1]"
| "OclVoid \<sqsubset> OrderedSet OclVoid[\<^bold>1]"
| "OclVoid \<sqsubset> Bag OclVoid[\<^bold>1]"
| "OclVoid \<sqsubset> Sequence OclVoid[\<^bold>1]"

| "\<tau> \<sqsubset>\<^sub>N \<sigma> \<Longrightarrow> Collection \<tau> \<sqsubset> Collection \<sigma>"
| "\<tau> \<sqsubset>\<^sub>N \<sigma> \<Longrightarrow> Set \<tau> \<sqsubset> Set \<sigma>"
| "\<tau> \<sqsubset>\<^sub>N \<sigma> \<Longrightarrow> OrderedSet \<tau> \<sqsubset> OrderedSet \<sigma>"
| "\<tau> \<sqsubset>\<^sub>N \<sigma> \<Longrightarrow> Bag \<tau> \<sqsubset> Bag \<sigma>"
| "\<tau> \<sqsubset>\<^sub>N \<sigma> \<Longrightarrow> Sequence \<tau> \<sqsubset> Sequence \<sigma>"

| "Set \<tau> \<sqsubset> Collection \<tau>"
| "OrderedSet \<tau> \<sqsubset> Collection \<tau>"
| "Bag \<tau> \<sqsubset> Collection \<tau>"
| "Sequence \<tau> \<sqsubset> Collection \<tau>"

| "Collection OclAny[\<^bold>?] \<sqsubset> OclAny"

\<comment> \<open>Map Types\<close>

| "OclVoid \<sqsubset> Map \<tau> \<sigma>"
| "\<sigma> \<sqsubset>\<^sub>N \<upsilon> \<Longrightarrow> Map \<tau> \<sigma> \<sqsubset> Map \<tau> \<upsilon>"
| "\<tau> \<sqsubset>\<^sub>N \<rho> \<Longrightarrow> Map \<tau> \<sigma> \<sqsubset> Map \<rho> \<sigma>"
| "Map \<tau> \<sigma> \<sqsubset> OclAny"

\<comment> \<open>Nullable Types\<close>

| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Required \<tau> \<sqsubset>\<^sub>N Required \<sigma>"
| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Optional \<tau> \<sqsubset>\<^sub>N Optional \<sigma>"
| "Required \<tau> \<sqsubset>\<^sub>N Optional \<tau>"

declare subtype_subtype\<^sub>N.intros [intro!]

inductive_cases subtype_x_OclAny [elim!]: "\<tau> \<sqsubset> OclAny"
inductive_cases subtype_x_OclVoid [elim!]: "\<tau> \<sqsubset> OclVoid"
inductive_cases subtype_x_Boolean [elim!]: "\<tau> \<sqsubset> Boolean"
inductive_cases subtype_x_Real [elim!]: "\<tau> \<sqsubset> Real"
inductive_cases subtype_x_Integer [elim!]: "\<tau> \<sqsubset> Integer"
inductive_cases subtype_x_UnlimitedNatural [elim!]: "\<tau> \<sqsubset> UnlimitedNatural"
inductive_cases subtype_x_String [elim!]: "\<tau> \<sqsubset> String"
inductive_cases subtype_x_Enum [elim!]: "\<tau> \<sqsubset> Enum \<E>"
inductive_cases subtype_x_ObjectType [elim!]: "\<tau> \<sqsubset> ObjectType \<C>"
inductive_cases subtype_x_Tuple [elim!]: "\<tau> \<sqsubset> Tuple \<pi>"
inductive_cases subtype_x_Collection [elim!]: "\<tau> \<sqsubset> Collection \<sigma>"
inductive_cases subtype_x_Set [elim!]: "\<tau> \<sqsubset> Set \<sigma>"
inductive_cases subtype_x_OrderedSet [elim!]: "\<tau> \<sqsubset> OrderedSet \<sigma>"
inductive_cases subtype_x_Bag [elim!]: "\<tau> \<sqsubset> Bag \<sigma>"
inductive_cases subtype_x_Sequence [elim!]: "\<tau> \<sqsubset> Sequence \<sigma>"
inductive_cases subtype_x_Map [elim!]: "\<tau> \<sqsubset> Map \<rho> \<upsilon>"

inductive_cases subtype_x_Required [elim!]: "\<tau> \<sqsubset>\<^sub>N Required \<sigma>"
inductive_cases subtype_x_Optional [elim!]: "\<tau> \<sqsubset>\<^sub>N Optional \<sigma>"

inductive_cases subtype_OclAny_x [elim!]: "OclAny \<sqsubset> \<sigma>"
inductive_cases subtype_Collection_x [elim!]: "Collection \<tau> \<sqsubset> \<sigma>"
inductive_cases subtype_Map_x [elim!]: "Map \<tau> \<sigma> \<sqsubset> \<psi>"

lemma
  subtype_asym: "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> \<sigma> \<sqsubset> \<tau> \<Longrightarrow> False" and
  subtype\<^sub>N_asym: "\<tau>\<^sub>N \<sqsubset>\<^sub>N \<sigma>\<^sub>N \<Longrightarrow> \<sigma>\<^sub>N \<sqsubset>\<^sub>N \<tau>\<^sub>N \<Longrightarrow> False"
  for \<tau> \<sigma> :: "'a :: order type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N :: "'a type\<^sub>N"
  apply (induct rule: subtype_subtype\<^sub>N.inducts, auto)
  using subtuple_antisym by fastforce

(*** Notation ***************************************************************)

section \<open>Notation\<close>

notation to_error_free_type ("_\<lbrakk>.\<rbrakk>" [1000] 1000)
notation to_errorable_type ("_\<lbrakk>.!\<rbrakk>" [1000] 1000)

fun required_type\<^sub>N where
  "required_type\<^sub>N (Required \<tau>) = True"
| "required_type\<^sub>N (Optional \<tau>) = False"

fun required_type where
  "required_type (ErrorFree \<tau>) = required_type\<^sub>N \<tau>"
| "required_type (Errorable \<tau>) = required_type\<^sub>N \<tau>"

abbreviation "optional_type\<^sub>N \<tau> \<equiv> \<not> required_type\<^sub>N \<tau>"
abbreviation "optional_type \<tau> \<equiv> \<not> required_type \<tau>"

fun to_required_type\<^sub>N where
  "to_required_type\<^sub>N (Required \<tau>) = Required \<tau>"
| "to_required_type\<^sub>N (Optional \<tau>) = Required \<tau>"

abbreviation to_required_type ("_\<lbrakk>1.\<rbrakk>" [1000] 1000) where
  "to_required_type \<equiv> map_errorable to_required_type\<^sub>N"

(* Is it realy required? Maybe it is better to check types intersection? *)
fun to_optional_type_nested\<^sub>T
and to_optional_type_nested\<^sub>N where
  "to_optional_type_nested\<^sub>T OclAny = OclAny"
| "to_optional_type_nested\<^sub>T OclVoid = OclVoid"

| "to_optional_type_nested\<^sub>T Boolean = Boolean"
| "to_optional_type_nested\<^sub>T Real = Real"
| "to_optional_type_nested\<^sub>T Integer = Integer"
| "to_optional_type_nested\<^sub>T UnlimitedNatural = UnlimitedNatural"
| "to_optional_type_nested\<^sub>T String = String"

| "to_optional_type_nested\<^sub>T (Enum \<E>) = Enum \<E>"
| "to_optional_type_nested\<^sub>T (ObjectType \<C>) = ObjectType \<C>"
| "to_optional_type_nested\<^sub>T (Tuple \<pi>) =
      Tuple (fmmap to_optional_type_nested\<^sub>N \<pi>)"

| "to_optional_type_nested\<^sub>T (Collection \<tau>) =
      Collection (to_optional_type_nested\<^sub>N \<tau>)"
| "to_optional_type_nested\<^sub>T (Set \<tau>) =
      Set (to_optional_type_nested\<^sub>N \<tau>)"
| "to_optional_type_nested\<^sub>T (OrderedSet \<tau>) =
      OrderedSet (to_optional_type_nested\<^sub>N \<tau>)"
| "to_optional_type_nested\<^sub>T (Bag \<tau>) =
      Bag (to_optional_type_nested\<^sub>N \<tau>)"
| "to_optional_type_nested\<^sub>T (Sequence \<tau>) =
      Sequence (to_optional_type_nested\<^sub>N \<tau>)"

| "to_optional_type_nested\<^sub>T (Map \<tau> \<sigma>) =
      Map (to_optional_type_nested\<^sub>N \<tau>) (to_optional_type_nested\<^sub>N \<sigma>)"

| "to_optional_type_nested\<^sub>N (Required \<tau>) = Optional (to_optional_type_nested\<^sub>T \<tau>)"
| "to_optional_type_nested\<^sub>N (Optional \<tau>) = Optional (to_optional_type_nested\<^sub>T \<tau>)"

abbreviation to_optional_type_nested ("_\<lbrakk>??.\<rbrakk>" [1000] 1000) where
  "to_optional_type_nested \<equiv> map_errorable to_optional_type_nested\<^sub>N"

abbreviation Required_ErrorFree ("_[1]" [1000] 1000) where
  "Required_ErrorFree \<tau> \<equiv> ErrorFree (Required \<tau>)"

abbreviation Optional_ErrorFree ("_[?]" [1000] 1000) where
  "Optional_ErrorFree \<tau> \<equiv> ErrorFree (Optional \<tau>)"

abbreviation Required_Errorable ("_[1!]" [1000] 1000) where
  "Required_Errorable \<tau> \<equiv> Errorable (Required \<tau>)"

abbreviation Optional_Errorable ("_[?!]" [1000] 1000) where
  "Optional_Errorable \<tau> \<equiv> Errorable (Optional \<tau>)"

(*** Constructors Bijectivity on Transitive Closures ************************)

section \<open>Constructors Bijectivity on Transitive Closures\<close>

lemma Tuple_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) Tuple"
  unfolding inj_def
  using tranclp.cases by fastforce

lemma subtype_tranclp_Collection_x:
  "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection \<tau>) \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<sigma> = Collection \<rho> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<rho> \<Longrightarrow> P) \<Longrightarrow>
   (\<sigma> = OclAny \<Longrightarrow> P) \<Longrightarrow> P"
  apply (induct rule: tranclp_induct)
  apply auto[1]
  by (metis subtype_Collection_x subtype_OclAny_x tranclp.trancl_into_trancl)

lemma Collection_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) Collection"
  unfolding inj_def
  using subtype_tranclp_Collection_x by auto

lemma Set_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) Set"
  unfolding inj_def
  using tranclp.cases by fastforce

lemma OrderedSet_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) OrderedSet"
  unfolding inj_def
  using tranclp.cases by fastforce

lemma Bag_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) Bag"
  unfolding inj_def
  using tranclp.cases by fastforce

lemma Sequence_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>) Sequence"
  unfolding inj_def
  using tranclp.cases by fastforce

lemma subtype_tranclp_x_Map_key:
  "(\<sqsubset>)\<^sup>+\<^sup>+ (Map \<tau> \<sigma>) (Map \<rho> \<upsilon>) \<Longrightarrow>
   ((\<And>\<tau>'. \<tau> = \<tau>' \<Longrightarrow> \<sigma> = \<upsilon> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<rho> \<Longrightarrow> P) \<Longrightarrow>
    (\<And>\<sigma>'. \<tau> = \<rho> \<Longrightarrow> \<sigma> = \<sigma>' \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
    (\<And>\<tau>' \<sigma>'. \<tau> = \<tau>' \<Longrightarrow> \<sigma> = \<sigma>' \<Longrightarrow>
          (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<rho> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<upsilon> \<Longrightarrow> P) \<Longrightarrow> P) \<Longrightarrow>
   ((\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<rho> \<Longrightarrow> P) \<Longrightarrow>
   (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<tau> \<Longrightarrow> P"
  by (metis tranclp_trans)

lemma subtype_tranclp_x_Map_value:
  "(\<sqsubset>)\<^sup>+\<^sup>+ (Map \<tau> \<sigma>) (Map \<rho> \<upsilon>) \<Longrightarrow>
   ((\<And>\<tau>'. \<tau> = \<tau>' \<Longrightarrow> \<sigma> = \<upsilon> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<rho> \<Longrightarrow> P) \<Longrightarrow>
    (\<And>\<sigma>'. \<tau> = \<rho> \<Longrightarrow> \<sigma> = \<sigma>' \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
    (\<And>\<tau>' \<sigma>'. \<tau> = \<tau>' \<Longrightarrow> \<sigma> = \<sigma>' \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau>' \<rho> \<Longrightarrow>
          (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<upsilon> \<Longrightarrow> P) \<Longrightarrow> P) \<Longrightarrow>
   ((\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
   (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma>' \<sigma> \<Longrightarrow> P"
  by (metis tranclp_trans)

lemma subtype_tranclp_x_Map:
  "(\<sqsubset>)\<^sup>+\<^sup>+ \<phi> (Map \<tau> \<sigma>) \<Longrightarrow>
   (\<And>\<rho>. \<phi> = Map \<rho> \<sigma> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<rho> \<tau> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<upsilon>. \<phi> = Map \<tau> \<upsilon> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<upsilon> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho> \<upsilon>. \<phi> = Map \<rho> \<upsilon> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<rho> \<tau> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<upsilon> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<phi> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  apply (induct rule: converse_tranclp_induct)
  apply auto[1]
  apply (erule subtype.cases; simp)
  apply (drule subtype_tranclp_x_Map_value; auto)
  apply (drule subtype_tranclp_x_Map_key; auto)
  done

lemma Map_key_bij_on_trancl [simp]:
  "((\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma> \<sigma> \<Longrightarrow> False) \<Longrightarrow> bij_on_trancl (\<sqsubset>) (\<lambda>\<tau>. Map \<tau> \<sigma>)"
  apply (auto simp add: inj_def)
  using tranclp.cases apply fastforce
  by (erule subtype_tranclp_x_Map; simp add: tranclp.trancl_into_trancl)

lemma Map_value_bij_on_trancl [simp]:
  "((\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<tau> \<Longrightarrow> False) \<Longrightarrow> bij_on_trancl (\<sqsubset>) (\<lambda>\<sigma>. Map \<tau> \<sigma>)"
  apply (auto simp add: inj_def)
  using tranclp.cases apply fastforce
  by (erule subtype_tranclp_x_Map; simp add: tranclp.trancl_into_trancl)

lemma Required_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>\<^sub>N) Required"
  by (auto simp add: inj_def)

lemma not_subtype_Optional_Required:
  "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ (Optional \<tau>) \<sigma> \<Longrightarrow> \<sigma> = Required \<rho> \<Longrightarrow> P"
  by (induct arbitrary: \<rho> rule: tranclp_induct; auto)

lemma Optional_bij_on_trancl [simp]:
  "bij_on_trancl (\<sqsubset>\<^sub>N) Optional"
  unfolding inj_def
  using not_subtype_Optional_Required by blast

(*** Partial Order of Types *************************************************)

section \<open>Partial Order of Types\<close>

instantiation type :: (order) ord
begin
definition "(<) \<equiv> (\<sqsubset>)\<^sup>+\<^sup>+"
definition "(\<le>) \<equiv> (\<sqsubset>)\<^sup>*\<^sup>*"
instance ..
end

instantiation type\<^sub>N :: (order) ord
begin
definition "(<) \<equiv> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+"
definition "(\<le>) \<equiv> (\<sqsubset>\<^sub>N)\<^sup>*\<^sup>*"
instance ..
end

(*** Strict Introduction Rules **********************************************)

subsection \<open>Strict Introduction Rules\<close>

lemma type_less_x_OclAny_intro [intro]:
  "\<tau> \<noteq> OclAny \<Longrightarrow> \<tau> < OclAny"
  "\<tau>\<^sub>N \<noteq> Optional OclAny \<Longrightarrow> \<tau>\<^sub>N < Optional OclAny"
  for \<tau> :: "'a :: order type"
  and \<tau>\<^sub>N :: "'a type\<^sub>N"
proof (induct \<tau> and \<tau>\<^sub>N)
  case OclAny thus ?case by simp
next
  case OclVoid
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid Boolean" by auto
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ Boolean OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case Boolean show ?case unfolding less_type_def by auto
next
  case Real show ?case unfolding less_type_def by auto
next
  case Integer
  have "(\<sqsubset>)\<^sup>+\<^sup>+ Integer Real" by auto
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ Real OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case UnlimitedNatural show ?case unfolding less_type_def by auto
next
  case String show ?case unfolding less_type_def by auto
next
  case (Enum \<E>) show ?case unfolding less_type_def by auto
next
  case (ObjectType \<C>) show ?case unfolding less_type_def by auto
next
  case (Tuple \<pi>) show ?case unfolding less_type_def by auto
next
  case (Collection \<tau>)
  from Collection.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Collection \<tau>) (Collection OclAny[\<^bold>?])"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection OclAny[\<^bold>?]) OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (Set \<tau>)
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Set \<tau>) (Collection \<tau>)" by auto
  also from Set.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Collection \<tau>) (Collection OclAny[\<^bold>?])"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection OclAny[\<^bold>?]) OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (OrderedSet \<tau>)
  have "(\<sqsubset>)\<^sup>*\<^sup>* (OrderedSet \<tau>) (Collection \<tau>)" by auto
  also from OrderedSet.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Collection \<tau>) (Collection OclAny[\<^bold>?])"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection OclAny[\<^bold>?]) OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (Bag \<tau>)
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Bag \<tau>) (Collection \<tau>)" by auto
  also from Bag.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Collection \<tau>) (Collection OclAny[\<^bold>?])"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection OclAny[\<^bold>?]) OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (Sequence \<tau>)
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Sequence \<tau>) (Collection \<tau>)" by auto
  also from Sequence.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Collection \<tau>) (Collection OclAny[\<^bold>?])"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Collection OclAny[\<^bold>?]) OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (Map \<tau> \<sigma>) show ?case unfolding less_type_def by auto
next
  case (Required \<tau>)
  have "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ (Required \<tau>) (Optional \<tau>)" by auto
  also from Required.hyps
  have "(\<sqsubset>\<^sub>N)\<^sup>*\<^sup>* (Optional \<tau>) (Optional OclAny)"
    unfolding less_type_def
    by (rule_tac ?R="(\<sqsubset>)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  finally show ?case unfolding less_type\<^sub>N_def by simp
next
  case (Optional \<tau>) thus ?case
    unfolding less_type_def less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>)" in preserve_tranclp, auto)
qed

lemma type_less_OclVoid_x_intro [intro]:
  "\<tau> \<noteq> OclVoid \<Longrightarrow> OclVoid < \<tau>"
  "\<tau>\<^sub>N \<noteq> Required OclVoid \<Longrightarrow> Required OclVoid < \<tau>\<^sub>N"
  for \<tau> :: "'a :: order type"
  and \<tau>\<^sub>N :: "'a type\<^sub>N"
proof (induct \<tau> and \<tau>\<^sub>N)
  case OclAny
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid Boolean" by auto
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ Boolean OclAny" by auto
  finally show ?case unfolding less_type_def by simp
next
  case OclVoid thus ?case by simp
next
  case Boolean show ?case unfolding less_type_def by auto
next
  case Real
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid Integer" by auto
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ Integer Real" by auto
  finally show ?case unfolding less_type_def by simp
next
  case Integer show ?case unfolding less_type_def by auto
next
  case UnlimitedNatural show ?case unfolding less_type_def by auto
next
  case String show ?case unfolding less_type_def by auto
next
  case (Enum \<E>) show ?case unfolding less_type_def by auto
next
  case (ObjectType \<C>) show ?case unfolding less_type_def by auto
next
  case (Tuple \<pi>) show ?case unfolding less_type_def by auto
next
  case (Collection \<tau>)
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid (Set OclVoid[\<^bold>1])" by auto
  also from Collection.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Set OclVoid[\<^bold>1]) (Set \<tau>)"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Set \<tau>) (Collection \<tau>)" by auto
  finally show ?case unfolding less_type_def by simp
next
  case (Set \<tau>)
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid (Set OclVoid[\<^bold>1])" by auto
  also from Set.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Set OclVoid[\<^bold>1]) (Set \<tau>)"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  finally show ?case unfolding less_type_def by simp
next
  case (OrderedSet \<tau>)
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid (OrderedSet OclVoid[\<^bold>1])" by auto
  also from OrderedSet.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (OrderedSet OclVoid[\<^bold>1]) (OrderedSet \<tau>)"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  finally show ?case unfolding less_type_def by simp
next
  case (Bag \<tau>)
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid (Bag OclVoid[\<^bold>1])" by auto
  also from Bag.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Bag OclVoid[\<^bold>1]) (Bag \<tau>)"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  finally show ?case unfolding less_type_def by simp
next
  case (Sequence \<tau>)
  have "(\<sqsubset>)\<^sup>+\<^sup>+ OclVoid (Sequence OclVoid[\<^bold>1])" by auto
  also from Sequence.hyps
  have "(\<sqsubset>)\<^sup>*\<^sup>* (Sequence OclVoid[\<^bold>1]) (Sequence \<tau>)"
    unfolding less_type\<^sub>N_def
    by (rule_tac ?R="(\<sqsubset>\<^sub>N)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  finally show ?case unfolding less_type_def by simp
next
  case (Map \<tau> \<sigma>) show ?case unfolding less_type_def by auto
next
  case (Required \<tau>) thus ?case
    unfolding less_type\<^sub>N_def less_type_def
    by (rule_tac ?f="Required" in preserve_tranclp; auto)
next
  case (Optional \<tau>)
  hence "(\<sqsubset>\<^sub>N)\<^sup>*\<^sup>* (Required OclVoid) (Required \<tau>)"
    unfolding less_type_def
    by (rule_tac ?R="(\<sqsubset>)" in preserve_rtranclp;
        auto simp add: Nitpick.rtranclp_unfold)
  also have "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ (Required \<tau>) (Optional \<tau>)" by auto
  finally show ?case unfolding less_type\<^sub>N_def by simp
qed

lemma type_less_x_Real_intro [intro]:
  "\<tau> = Integer \<Longrightarrow> \<tau> < Real"
  unfolding less_type_def
  by (rule rtranclp_into_tranclp2, auto)+

lemma type_less_x_ObjectType_intro [intro]:
  "\<tau> = \<langle>\<C>\<rangle>\<^sub>\<T> \<Longrightarrow> \<C> < \<D> \<Longrightarrow> \<tau> < \<langle>\<D>\<rangle>\<^sub>\<T>"
  unfolding less_type_def
  using dual_order.order_iff_strict by blast

lemma fun_or_eq_refl [intro]:
  "reflp (\<lambda>x y. f x y \<or> x = y)"
  by (simp add: reflpI)

lemma type_less_x_Tuple_intro [intro]:
  assumes "\<tau> = Tuple \<pi>"
      and "strict_subtuple (\<le>) \<pi> \<xi>"
    shows "\<tau> < Tuple \<xi>"
proof -
  have "subtuple (\<lambda>\<tau> \<sigma>. \<tau> \<sqsubset>\<^sub>N \<sigma> \<or> \<tau> = \<sigma>)\<^sup>*\<^sup>* \<pi> \<xi>"
    by (metis assms(2) less_eq_type\<^sub>N_def rtranclp_eq_rtranclp)
  hence "(subtuple (\<lambda>\<tau> \<sigma>. \<tau> \<sqsubset>\<^sub>N \<sigma> \<or> \<tau> = \<sigma>))\<^sup>+\<^sup>+ \<pi> \<xi>"
    by simp (rule subtuple_to_trancl; auto)
  hence "(strict_subtuple (\<lambda>\<tau> \<sigma>. \<tau> \<sqsubset>\<^sub>N \<sigma> \<or> \<tau> = \<sigma>))\<^sup>*\<^sup>* \<pi> \<xi>"
    by (simp add: tranclp_into_rtranclp)
  hence "(strict_subtuple (\<lambda>\<tau> \<sigma>. \<tau> \<sqsubset>\<^sub>N \<sigma> \<or> \<tau> = \<sigma>))\<^sup>+\<^sup>+ \<pi> \<xi>"
    by (meson assms(2) rtranclpD)
  thus ?thesis
    unfolding less_type_def
    using assms(1) apply simp
    by (rule preserve_tranclp; auto)
qed

lemma type_less_x_Collection_intro [intro]:
  "\<tau> = Collection \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Collection \<sigma>"
  "\<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> < Collection \<sigma>"
  "\<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> < Collection \<sigma>"
  "\<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> < Collection \<sigma>"
  "\<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> < Collection \<sigma>"
  unfolding less_type_def less_type\<^sub>N_def less_eq_type\<^sub>N_def
  apply simp_all
  apply (rule_tac ?f="Collection" in preserve_tranclp; auto)
  by (rule preserve_rtranclp''; auto)+

lemma type_less_x_Set_intro [intro]:
  "\<tau> = Set \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Set \<sigma>"
  unfolding less_type_def less_type\<^sub>N_def
  by simp (rule preserve_tranclp; auto)

lemma type_less_x_OrderedSet_intro [intro]:
  "\<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < OrderedSet \<sigma>"
  unfolding less_type_def less_type\<^sub>N_def
  by simp (rule preserve_tranclp; auto)

lemma type_less_x_Bag_intro [intro]:
  "\<tau> = Bag \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Bag \<sigma>"
  unfolding less_type_def less_type\<^sub>N_def
  by simp (rule preserve_tranclp; auto)

lemma type_less_x_Sequence_intro [intro]:
  "\<tau> = Sequence \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Sequence \<sigma>"
  unfolding less_type_def less_type\<^sub>N_def
  by simp (rule preserve_tranclp; auto)


lemma type_less_x_Map_intro':
  assumes "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<rho>"
      and "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<sigma> \<upsilon>"
    shows "(\<sqsubset>)\<^sup>+\<^sup>+ (Map \<tau> \<sigma>) (Map \<rho> \<upsilon>)"
proof -
  from assms(2) have "(\<sqsubset>)\<^sup>+\<^sup>+ (Map \<tau> \<sigma>) (Map \<tau> \<upsilon>)"
    by (metis preserve_tranclp subtype_subtype\<^sub>N.intros(33))
  also have "(\<sqsubset>)\<^sup>+\<^sup>+ (Map \<tau> \<upsilon>) (Map \<rho> \<upsilon>)"
    apply (insert assms(1))
    by (rule preserve_tranclp; simp add: subtype_subtype\<^sub>N.intros(34))
  finally show ?thesis by simp
qed

lemma type_less_x_Map_intro [intro]:
  "\<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> = \<rho> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> \<phi> < Map \<rho> \<upsilon>"
  "\<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> < \<rho> \<Longrightarrow> \<sigma> = \<upsilon> \<Longrightarrow> \<phi> < Map \<rho> \<upsilon>"
  "\<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> < \<rho> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> \<phi> < Map \<rho> \<upsilon>"
  unfolding less_type\<^sub>N_def less_type_def
  apply simp_all
  apply (rule preserve_tranclp;
         simp add: subtype_subtype\<^sub>N.intros(33) subtype_subtype\<^sub>N.intros(34))+
  by (simp add: type_less_x_Map_intro')


lemma type_less_x_Required_intro [intro]:
  "\<tau> = Required \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Required \<sigma>"
  unfolding less_type\<^sub>N_def less_type_def
  by simp (rule preserve_tranclp; auto)

lemma type_less_x_Optional_intro [intro]:
  "\<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> < Optional \<sigma>"
  "\<tau> = Optional \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> \<tau> < Optional \<sigma>"
  unfolding less_type\<^sub>N_def less_type_def less_eq_type_def
  apply simp_all
  apply (rule preserve_rtranclp''; auto)
  by (rule preserve_tranclp; auto)

(*** Strict Elimination Rules ***********************************************)

subsection \<open>Strict Elimination Rules\<close>

lemma type_less_x_OclAny [elim!]:
  "\<tau> < OclAny \<Longrightarrow> (\<tau> \<noteq> OclAny \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (drule tranclpD; auto)

lemma type_less_x_OclVoid [elim!]:
  "\<tau> < OclVoid \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_Boolean [elim!]:
  "\<tau> < Boolean \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_Real [elim!]:
  "\<tau> < Real \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Integer \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_Integer [elim!]:
  "\<tau> < Integer \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_UnlimitedNatural [elim!]:
  "\<tau> < UnlimitedNatural \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_String [elim!]:
  "\<tau> < String \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_Enum [elim!]:
  "\<tau> < Enum \<E> \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  by (induct rule: converse_tranclp_induct; auto)

lemma type_less_x_ObjectType [elim!]:
  "\<tau> < \<langle>\<D>\<rangle>\<^sub>\<T> \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<C>. \<tau> = \<langle>\<C>\<rangle>\<^sub>\<T> \<Longrightarrow> \<C> < \<D> \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def
  apply (induct rule: converse_tranclp_induct)
  using less_trans by auto

text \<open>
  We will be able to remove the acyclicity assumption only after
  we prove that the subtype relation is acyclic.\<close>

lemma type_less_x_Tuple':
  assumes "\<tau> < Tuple \<xi>"
      and "acyclicP_on (fmran' \<xi>) (\<sqsubset>\<^sub>N)"
      and "\<And>\<pi>. \<tau> = Tuple \<pi> \<Longrightarrow> strict_subtuple (\<le>) \<pi> \<xi> \<Longrightarrow> P"
      and "\<tau> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<pi> where "\<tau> = Tuple \<pi> \<or> \<tau> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover from assms(2) have
    "\<And>\<pi>. Tuple \<pi> < Tuple \<xi> \<Longrightarrow> strict_subtuple (\<le>) \<pi> \<xi>"
    unfolding less_type_def less_eq_type\<^sub>N_def
    by (rule_tac ?f="Tuple" in strict_subtuple_rtranclp_intro; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_Collection [elim!]:
  "\<tau> < Collection \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Collection \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> 
   (\<And>\<rho>. \<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> 
   (\<And>\<rho>. \<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> 
   (\<And>\<rho>. \<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> 
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type_def less_type\<^sub>N_def less_eq_type\<^sub>N_def
  apply (induct rule: converse_tranclp_induct)
  apply auto[1]
  by (erule subtype.cases;
      auto simp add: converse_rtranclp_into_rtranclp less_eq_type_def
                     tranclp_into_tranclp2 tranclp_into_rtranclp)

lemma type_less_x_Set [elim!]:
  assumes "\<tau> < Set \<sigma>"
      and "\<And>\<rho>. \<tau> = Set \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P"
      and "\<tau> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<rho> where "\<tau> = Set \<rho> \<or> \<tau> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have "\<And>\<tau> \<sigma>. Set \<tau> < Set \<sigma> \<Longrightarrow> \<tau> < \<sigma>"
    unfolding less_type_def less_type\<^sub>N_def
    by (rule reflect_tranclp; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_OrderedSet [elim!]:
  assumes "\<tau> < OrderedSet \<sigma>"
      and "\<And>\<rho>. \<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P"
      and "\<tau> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<rho> where "\<tau> = OrderedSet \<rho> \<or> \<tau> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have "\<And>\<tau> \<sigma>. OrderedSet \<tau> < OrderedSet \<sigma> \<Longrightarrow> \<tau> < \<sigma>"
    unfolding less_type_def less_type\<^sub>N_def
    by (rule reflect_tranclp; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_Bag [elim!]:
  assumes "\<tau> < Bag \<sigma>"
      and "\<And>\<rho>. \<tau> = Bag \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P"
      and "\<tau> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<rho> where "\<tau> = Bag \<rho> \<or> \<tau> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have "\<And>\<tau> \<sigma>. Bag \<tau> < Bag \<sigma> \<Longrightarrow> \<tau> < \<sigma>"
    unfolding less_type_def less_type\<^sub>N_def
    by (rule reflect_tranclp; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_Sequence [elim!]:
  assumes "\<tau> < Sequence \<sigma>"
      and "\<And>\<rho>. \<tau> = Sequence \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P"
      and "\<tau> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<rho> where "\<tau> = Sequence \<rho> \<or> \<tau> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have "\<And>\<tau> \<sigma>. Sequence \<tau> < Sequence \<sigma> \<Longrightarrow> \<tau> < \<sigma>"
    unfolding less_type_def less_type\<^sub>N_def
    by (rule reflect_tranclp; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_Map [elim!]:
  assumes "\<phi> < Map \<rho> \<upsilon>"
      and "\<And>\<sigma>. \<phi> = Map \<rho> \<sigma> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> P"
      and "\<And>\<tau>. \<phi> = Map \<tau> \<upsilon> \<Longrightarrow> \<tau> < \<rho> \<Longrightarrow> P"
      and "\<And>\<tau> \<sigma>. \<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> < \<rho> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> P"
      and "\<phi> = OclVoid \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<tau> \<sigma> where "\<phi> = Map \<tau> \<sigma> \<or> \<phi> = OclVoid"
    unfolding less_type_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have
    "Map \<tau> \<sigma> < Map \<rho> \<upsilon> \<Longrightarrow>
     (\<tau> = \<rho> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
     (\<tau> < \<rho> \<Longrightarrow> \<sigma> = \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
     (\<tau> < \<rho> \<Longrightarrow> \<sigma> < \<upsilon> \<Longrightarrow> P) \<Longrightarrow> P"
    unfolding less_type_def less_type\<^sub>N_def
    by (erule subtype_tranclp_x_Map, auto)
  ultimately show ?thesis
    using assms by auto
qed


lemma type_less_x_Required [elim!]:
  assumes "\<tau> < Required \<sigma>"
      and "\<And>\<rho>. \<tau> = Required \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P"
    shows "P"
proof -
  from assms(1) obtain \<rho> where "\<tau> = Required \<rho>"
    unfolding less_type\<^sub>N_def
    by (induct rule: converse_tranclp_induct; auto)
  moreover have "Required \<rho> < Required \<sigma> \<Longrightarrow> \<rho> < \<sigma>"
    unfolding less_type_def less_type\<^sub>N_def
    by (rule reflect_tranclp; auto)
  ultimately show ?thesis
    using assms by auto
qed

lemma type_less_x_Optional [elim!]:
  "\<tau> < Optional \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Optional \<rho> \<Longrightarrow> \<rho> < \<sigma> \<Longrightarrow> P) \<Longrightarrow> P"
  unfolding less_type\<^sub>N_def less_type_def less_eq_type_def
  apply (induct rule: converse_tranclp_induct)
  apply auto[1]
  apply (erule subtype\<^sub>N.cases)
  apply (auto simp: converse_rtranclp_into_rtranclp tranclp_into_tranclp2)[1]
  apply (auto simp: converse_rtranclp_into_rtranclp tranclp_into_tranclp2)[1]
  using tranclp_into_rtranclp by fastforce

(*** Properties *************************************************************)

subsection \<open>Properties\<close>

lemma
  subtype_irrefl: "\<tau> < \<tau> \<Longrightarrow> False" and
  subtype\<^sub>N_irrefl: "\<tau>\<^sub>N < \<tau>\<^sub>N \<Longrightarrow> False"
  for \<tau> :: "'a :: order type"
  and \<tau>\<^sub>N :: "'a type\<^sub>N"
  apply (induct \<tau> and \<tau>\<^sub>N, auto)
  by (erule type_less_x_Tuple'; auto simp add: less_type\<^sub>N_def tranclp_unfold)

lemma subtype_acyclic:
  "acyclicP (\<sqsubset>)"
proof -
  have "\<nexists>\<tau>. (\<sqsubset>)\<^sup>+\<^sup>+ \<tau> \<tau>"
    by (metis (mono_tags) less_type_def OCL_Types.subtype_irrefl)
  thus ?thesis
    by (intro acyclicI) (simp add: trancl_def)
qed

lemma subtype\<^sub>N_acyclic:
  "acyclicP (\<sqsubset>\<^sub>N)"
proof -
  have "\<nexists>\<tau>. (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<tau>"
    by (metis (mono_tags) less_type\<^sub>N_def OCL_Types.subtype\<^sub>N_irrefl)
  thus ?thesis
    by (intro acyclicI) (simp add: trancl_def)
qed

(*** Partial Order **********************************************************)

subsection \<open>Partial Order\<close>

instantiation type :: (order) order
begin

lemma less_le_not_le_type:
  "\<tau> < \<sigma> \<longleftrightarrow> \<tau> \<le> \<sigma> \<and> \<not> \<sigma> \<le> \<tau>"
  for \<tau> \<sigma> :: "'a type"
proof -
  have "(\<sqsubset>)\<^sup>+\<^sup>+ \<tau> \<sigma> \<Longrightarrow> (\<sqsubset>)\<^sup>*\<^sup>* \<sigma> \<tau> \<Longrightarrow> False"
    by (metis (mono_tags) subtype_irrefl less_type_def tranclp_rtranclp_tranclp)
  moreover have "(\<sqsubset>)\<^sup>*\<^sup>* \<tau> \<sigma> \<Longrightarrow> \<not> (\<sqsubset>)\<^sup>*\<^sup>* \<sigma> \<tau> \<Longrightarrow> (\<sqsubset>)\<^sup>+\<^sup>+ \<tau> \<sigma>"
    by (metis rtranclpD)
  ultimately show ?thesis
    unfolding less_type_def less_eq_type_def by auto
qed

lemma order_refl_type:
  "\<tau> \<le> \<tau>"
  for \<tau> :: "'a type"
  unfolding less_eq_type_def by simp

lemma order_trans_type:
  "\<tau> \<le> \<sigma> \<Longrightarrow> \<sigma> \<le> \<rho> \<Longrightarrow> \<tau> \<le> \<rho>"
  for \<tau> \<sigma> \<rho> :: "'a type"
  unfolding less_eq_type_def by simp

lemma antisym_type:
  "\<tau> \<le> \<sigma> \<Longrightarrow> \<sigma> \<le> \<tau> \<Longrightarrow> \<tau> = \<sigma>"
  for \<tau> \<sigma> :: "'a type"
  unfolding less_eq_type_def less_type_def
  by (metis (mono_tags, lifting) less_eq_type_def
      less_le_not_le_type less_type_def rtranclpD)

instance
  apply intro_classes
  apply (simp add: less_le_not_le_type)
  apply (simp add: order_refl_type)
  using order_trans_type apply blast
  by (simp add: antisym_type)

end

instantiation type\<^sub>N :: (order) order
begin

lemma less_le_not_le_type\<^sub>N:
  "\<tau> < \<sigma> \<longleftrightarrow> \<tau> \<le> \<sigma> \<and> \<not> \<sigma> \<le> \<tau>"
  for \<tau> \<sigma> :: "'a type\<^sub>N"
proof -
  have "(\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<sigma> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>*\<^sup>* \<sigma> \<tau> \<Longrightarrow> False"
    by (metis subtype\<^sub>N_irrefl less_type\<^sub>N_def tranclp_rtranclp_tranclp)
  moreover have "(\<sqsubset>\<^sub>N)\<^sup>*\<^sup>* \<tau> \<sigma> \<Longrightarrow> \<not> (\<sqsubset>\<^sub>N)\<^sup>*\<^sup>* \<sigma> \<tau> \<Longrightarrow> (\<sqsubset>\<^sub>N)\<^sup>+\<^sup>+ \<tau> \<sigma>"
    by (metis rtranclpD)
  ultimately show ?thesis
    unfolding less_type\<^sub>N_def less_eq_type\<^sub>N_def by auto
qed

lemma order_refl_type\<^sub>N:
  "\<tau> \<le> \<tau>"
  for \<tau> :: "'a type\<^sub>N"
  unfolding less_eq_type\<^sub>N_def by simp

lemma order_trans_type\<^sub>N:
  "\<tau> \<le> \<sigma> \<Longrightarrow> \<sigma> \<le> \<rho> \<Longrightarrow> \<tau> \<le> \<rho>"
  for \<tau> \<sigma> \<rho> :: "'a type\<^sub>N"
  unfolding less_eq_type\<^sub>N_def by simp

lemma antisym_type\<^sub>N:
  "\<tau> \<le> \<sigma> \<Longrightarrow> \<sigma> \<le> \<tau> \<Longrightarrow> \<tau> = \<sigma>"
  for \<tau> \<sigma> :: "'a type\<^sub>N"
  unfolding less_eq_type\<^sub>N_def less_type\<^sub>N_def
  by (metis (mono_tags, lifting) less_eq_type\<^sub>N_def
      less_le_not_le_type\<^sub>N less_type\<^sub>N_def rtranclpD)

instance
  apply intro_classes
  apply (simp add: less_le_not_le_type\<^sub>N)
  apply (simp add: order_refl_type\<^sub>N)
  using order_trans_type\<^sub>N apply blast
  by (simp add: antisym_type\<^sub>N)

end

(*** Non-Strict Introduction Rules ******************************************)

subsection \<open>Non-Strict Introduction Rules\<close>

lemma type_less_eq_x_OclAny_intro [intro]:
  "\<tau> \<le> OclAny"
  unfolding dual_order.order_iff_strict by auto

lemma type_less_eq_OclVoid_x_intro [intro]:
  "OclVoid \<le> \<tau>"
  unfolding dual_order.order_iff_strict by auto

lemma type_less_eq_x_Real_intro [intro]:
  "\<tau> = Real \<Longrightarrow> \<tau> \<le> Real"
  "\<tau> = Integer \<Longrightarrow> \<tau> \<le> Real"
  unfolding dual_order.order_iff_strict by auto

lemma type_less_eq_x_Integer_intro [intro]:
  "\<tau> = Integer \<Longrightarrow> \<tau> \<le> Integer"
  unfolding dual_order.order_iff_strict by auto

lemma type_less_eq_x_ObjectType_intro [intro]:
  "\<tau> = \<langle>\<C>\<rangle>\<^sub>\<T> \<Longrightarrow> \<C> \<le> \<D> \<Longrightarrow> \<tau> \<le> \<langle>\<D>\<rangle>\<^sub>\<T>"
  unfolding dual_order.order_iff_strict by auto

lemma type_less_eq_x_Tuple_intro [intro]:
  "\<tau> = Tuple \<pi> \<Longrightarrow> subtuple (\<le>) \<pi> \<xi> \<Longrightarrow> \<tau> \<le> Tuple \<xi>"
  using order.strict_iff_order by blast

lemma type_less_eq_x_Collection_intro [intro]:
  "\<tau> = Collection \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Collection \<sigma>"
  "\<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Collection \<sigma>"
  "\<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Collection \<sigma>"
  "\<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Collection \<sigma>"
  "\<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Collection \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_Set_intro [intro]:
  "\<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Set \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_OrderedSet_intro [intro]:
  "\<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> OrderedSet \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_Bag_intro [intro]:
  "\<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Bag \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_Sequence_intro [intro]:
  "\<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Sequence \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_Map_intro [intro]:
  "\<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> \<le> \<rho> \<Longrightarrow> \<sigma> \<le> \<upsilon> \<Longrightarrow> \<phi> \<le> Map \<rho> \<upsilon>"
  by (metis eq_iff le_imp_less_or_eq order.strict_implies_order type_less_x_Map_intro)

lemma type_less_eq_x_Required_intro [intro]:
  "\<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Required \<sigma>"
  unfolding order.order_iff_strict by auto

lemma type_less_eq_x_Optional_intro [intro]:
  "\<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Optional \<sigma>"
  "\<tau> = Optional \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> \<tau> \<le> Optional \<sigma>"
  unfolding order.order_iff_strict by auto

(*** Non-Strict Elimination Rules *******************************************)

subsection \<open>Non-Strict Elimination Rules\<close>

lemma type_less_eq_x_OclVoid [elim!]:
  "\<tau> \<le> OclVoid \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Boolean [elim!]:
  "\<tau> \<le> Boolean \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Boolean \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Real [elim!]:
  "\<tau> \<le> Real \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Integer \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Real \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Integer [elim!]:
  "\<tau> \<le> Integer \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Integer \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_UnlimitedNatural [elim!]:
  "\<tau> \<le> UnlimitedNatural \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = UnlimitedNatural \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_String [elim!]:
  "\<tau> \<le> String \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = String \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Enum [elim!]:
  "\<tau> \<le> Enum \<E> \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = Enum \<E> \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_ObjectType [elim!]:
  "\<tau> \<le> \<langle>\<D>\<rangle>\<^sub>\<T> \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<C>. \<tau> = \<langle>\<C>\<rangle>\<^sub>\<T> \<Longrightarrow> \<C> \<le> \<D> \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_x_Tuple [elim!]:
  "\<tau> < Tuple \<xi> \<Longrightarrow>
   (\<And>\<pi>. \<tau> = Tuple \<pi> \<Longrightarrow> strict_subtuple (\<le>) \<pi> \<xi> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  apply (erule type_less_x_Tuple')
  apply (meson acyclic_def subtype\<^sub>N_acyclic)
  by simp

lemma type_less_eq_x_Tuple [elim!]:
  "\<tau> \<le> Tuple \<xi> \<Longrightarrow>
   (\<And>\<pi>. \<tau> = Tuple \<pi> \<Longrightarrow> subtuple (\<le>) \<pi> \<xi> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  apply (drule le_imp_less_or_eq, auto)
  by (simp add: fmap.rel_refl fmrel_to_subtuple)

lemma type_less_eq_x_Collection [elim!]:
  "\<tau> \<le> Collection \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Collection \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Set [elim!]:
  "\<tau> \<le> Set \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Set \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_OrderedSet [elim!]:
  "\<tau> \<le> OrderedSet \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = OrderedSet \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Bag [elim!]:
  "\<tau> \<le> Bag \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Bag \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Sequence [elim!]:
  "\<tau> \<le> Sequence \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Sequence \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<tau> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Map [elim!]:
  "\<phi> \<le> Map \<rho> \<upsilon> \<Longrightarrow>
   (\<And>\<tau> \<sigma>. \<phi> = Map \<tau> \<sigma> \<Longrightarrow> \<tau> \<le> \<rho> \<Longrightarrow> \<sigma> \<le> \<upsilon> \<Longrightarrow> P) \<Longrightarrow>
   (\<phi> = OclVoid \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Required [elim!]:
  "\<tau> \<le> Required \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

lemma type_less_eq_x_Optional [elim!]:
  "\<tau> \<le> Optional \<sigma> \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Required \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow>
   (\<And>\<rho>. \<tau> = Optional \<rho> \<Longrightarrow> \<rho> \<le> \<sigma> \<Longrightarrow> P) \<Longrightarrow> P"
  by (drule le_imp_less_or_eq; auto)

(*** Simplification Rules ***************************************************)

subsection \<open>Simplification Rules\<close>

text \<open>
  We can not declare @{thm Orderings.order_class.le_less} as
  a simplification theorem for two arbitrary types, because it is too aggressive.
  So we define a specific simplification rules for @{text "\<le>"} operator.\<close>

lemma type_less_left_simps [simp]:
  "OclAny < \<sigma> = False"
  "OclVoid < \<sigma> = (\<sigma> \<noteq> OclVoid)"

  "Boolean < \<sigma> = (\<sigma> = OclAny)"
  "Real < \<sigma> = (\<sigma> = OclAny)"
  "Integer < \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = Real)"
  "UnlimitedNatural < \<sigma> = (\<sigma> = OclAny)"
  "String < \<sigma> = (\<sigma> = OclAny)"

  "Enum \<E> < \<sigma> = (\<sigma> = OclAny)"
  "ObjectType \<C> < \<sigma> = (\<exists>\<D>.
      \<sigma> = OclAny \<or>
      \<sigma> = ObjectType \<D> \<and> \<C> < \<D>)"
  "Tuple \<pi> < \<sigma> = (\<exists>\<xi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Tuple \<xi> \<and> strict_subtuple (\<le>) \<pi> \<xi>)"

  "Collection \<tau> < \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> < \<phi>)"
  "Set \<tau> < \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Set \<phi> \<and> \<tau> < \<phi>)"
  "OrderedSet \<tau> < \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = OrderedSet \<phi> \<and> \<tau> < \<phi>)"
  "Bag \<tau> < \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Bag \<phi> \<and> \<tau> < \<phi>)"
  "Sequence \<tau> < \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Sequence \<phi> \<and> \<tau> < \<phi>)"

  "Map \<tau> \<phi> < \<sigma> = (\<exists>\<rho> \<upsilon>.
      \<sigma> = OclAny \<or>
      \<sigma> = Map \<rho> \<upsilon> \<and> \<tau> = \<rho> \<and> \<phi> < \<upsilon> \<or>
      \<sigma> = Map \<rho> \<upsilon> \<and> \<tau> < \<rho> \<and> \<phi> = \<upsilon> \<or>
      \<sigma> = Map \<rho> \<upsilon> \<and> \<tau> < \<rho> \<and> \<phi> < \<upsilon>)"
  by (induct \<sigma>; auto)+

lemma type_less_eq_left_simps [simp]:
  "OclAny \<le> \<sigma> = (\<sigma> = OclAny)"
  "OclVoid \<le> \<sigma> = True"

  "Boolean \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = Boolean)"
  "Real \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = Real)"
  "Integer \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = Real \<or> \<sigma> = Integer)"
  "UnlimitedNatural \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = UnlimitedNatural)"
  "String \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = String)"

  "Enum \<E> \<le> \<sigma> = (\<sigma> = OclAny \<or> \<sigma> = Enum \<E>)"
  "ObjectType \<C> \<le> \<sigma> = (\<exists>\<D>.
      \<sigma> = OclAny \<or>
      \<sigma> = ObjectType \<D> \<and> \<C> \<le> \<D>)"
  "Tuple \<pi> \<le> \<sigma> = (\<exists>\<xi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Tuple \<xi> \<and> subtuple (\<le>) \<pi> \<xi>)"

  "Collection \<tau> \<le> \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi>)"
  "Set \<tau> \<le> \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Set \<phi> \<and> \<tau> \<le> \<phi>)"
  "OrderedSet \<tau> \<le> \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = OrderedSet \<phi> \<and> \<tau> \<le> \<phi>)"
  "Bag \<tau> \<le> \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Bag \<phi> \<and> \<tau> \<le> \<phi>)"
  "Sequence \<tau> \<le> \<sigma> = (\<exists>\<phi>.
      \<sigma> = OclAny \<or>
      \<sigma> = Collection \<phi> \<and> \<tau> \<le> \<phi> \<or>
      \<sigma> = Sequence \<phi> \<and> \<tau> \<le> \<phi>)"

  "Map \<tau> \<phi> \<le> \<sigma> = (\<exists>\<rho> \<upsilon>.
      \<sigma> = OclAny \<or>
      \<sigma> = Map \<rho> \<upsilon> \<and> \<tau> \<le> \<rho> \<and> \<phi> \<le> \<upsilon>)"
  by (auto simp: order.order_iff_strict reflpI)

lemma type\<^sub>N_less_left_simps [simp]:
  "Required \<rho> < \<sigma> = (\<exists>\<upsilon>.
      \<sigma> = Required \<upsilon> \<and> \<rho> < \<upsilon> \<or>
      \<sigma> = Optional \<upsilon> \<and> \<rho> \<le> \<upsilon>)"
  "Optional \<rho> < \<sigma> = (\<exists>\<upsilon>.
      \<sigma> = Optional \<upsilon> \<and> \<rho> < \<upsilon>)"
  by (induct \<sigma>; auto)+

lemma type\<^sub>N_less_eq_left_simps [simp]:
  "Required \<rho> \<le> \<sigma> = (\<exists>\<upsilon>.
      \<sigma> = Required \<upsilon> \<and> \<rho> \<le> \<upsilon> \<or>
      \<sigma> = Optional \<upsilon> \<and> \<rho> \<le> \<upsilon>)"
  "Optional \<rho> \<le> \<sigma> = (\<exists>\<upsilon>.
      \<sigma> = Optional \<upsilon> \<and> \<rho> \<le> \<upsilon>)"
  by (auto simp: dual_order.order_iff_strict)

lemma type_less_right_simps [simp]:
  "\<tau> < OclAny = (\<tau> \<noteq> OclAny)"
  "\<tau> < OclVoid = False"

  "\<tau> < Boolean = (\<tau> = OclVoid)"
  "\<tau> < Real = (\<tau> = Integer \<or> \<tau> = OclVoid)"
  "\<tau> < Integer = (\<tau> = OclVoid)"
  "\<tau> < UnlimitedNatural = (\<tau> = OclVoid)"
  "\<tau> < String = (\<tau> = OclVoid)"

  "\<tau> < Enum \<E> = (\<tau> = OclVoid)"
  "\<tau> < ObjectType \<D> = (\<exists>\<C>.
      \<tau> = ObjectType \<C> \<and> \<C> < \<D> \<or>
      \<tau> = OclVoid)"
  "\<tau> < Tuple \<xi> = (\<exists>\<pi>.
      \<tau> = Tuple \<pi> \<and> strict_subtuple (\<le>) \<pi> \<xi> \<or>
      \<tau> = OclVoid)"

  "\<tau> < Collection \<sigma> = (\<exists>\<phi>.
      \<tau> = Collection \<phi> \<and> \<phi> < \<sigma> \<or>
      \<tau> = Set \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = OrderedSet \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = Bag \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = Sequence \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = OclVoid)"
  "\<tau> < Set \<sigma> = (\<exists>\<phi>.
      \<tau> = Set \<phi> \<and> \<phi> < \<sigma> \<or>
      \<tau> = OclVoid)"
  "\<tau> < OrderedSet \<sigma> = (\<exists>\<phi>.
      \<tau> = OrderedSet \<phi> \<and> \<phi> < \<sigma> \<or>
      \<tau> = OclVoid)"
  "\<tau> < Bag \<sigma> = (\<exists>\<phi>.
      \<tau> = Bag \<phi> \<and> \<phi> < \<sigma> \<or>
      \<tau> = OclVoid)"
  "\<tau> < Sequence \<sigma> = (\<exists>\<phi>.
      \<tau> = Sequence \<phi> \<and> \<phi> < \<sigma> \<or>
      \<tau> = OclVoid)"

  "\<tau> < Map \<rho> \<upsilon> = (\<exists>\<phi> \<sigma>.
      \<tau> = Map \<phi> \<sigma> \<and> \<phi> = \<rho> \<and> \<sigma> < \<upsilon> \<or>
      \<tau> = Map \<phi> \<sigma> \<and> \<phi> < \<rho> \<and> \<sigma> = \<upsilon> \<or>
      \<tau> = Map \<phi> \<sigma> \<and> \<phi> < \<rho> \<and> \<sigma> < \<upsilon> \<or>
      \<tau> = OclVoid)"
  by auto

lemma type_less_eq_right_simps [simp]:
  "\<tau> \<le> OclAny = True"
  "\<tau> \<le> OclVoid = (\<tau> = OclVoid)"

  "\<tau> \<le> Boolean = (\<tau> = Boolean \<or> \<tau> = OclVoid)"
  "\<tau> \<le> Real = (\<tau> = Real \<or> \<tau> = Integer \<or> \<tau> = OclVoid)"
  "\<tau> \<le> Integer = (\<tau> = Integer \<or> \<tau> = OclVoid)"
  "\<tau> \<le> UnlimitedNatural = (\<tau> = UnlimitedNatural \<or> \<tau> = OclVoid)"
  "\<tau> \<le> String = (\<tau> = String \<or> \<tau> = OclVoid)"

  "\<tau> \<le> Enum \<E> = (\<tau> = Enum \<E> \<or> \<tau> = OclVoid)"
  "\<tau> \<le> ObjectType \<D> = (\<exists>\<C>. \<tau> = ObjectType \<C> \<and> \<C> \<le> \<D> \<or> \<tau> = OclVoid)"
  "\<tau> \<le> Tuple \<xi> = (\<exists>\<pi>. \<tau> = Tuple \<pi> \<and> subtuple (\<le>) \<pi> \<xi> \<or> \<tau> = OclVoid)"

  "\<tau> \<le> Collection \<sigma> = (\<exists>\<phi>.
      \<tau> = Collection \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = Set \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = OrderedSet \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = Bag \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = Sequence \<phi> \<and> \<phi> \<le> \<sigma> \<or>
      \<tau> = OclVoid)"
  "\<tau> \<le> Set \<sigma> = (\<exists>\<phi>. \<tau> = Set \<phi> \<and> \<phi> \<le> \<sigma> \<or> \<tau> = OclVoid)"
  "\<tau> \<le> OrderedSet \<sigma> = (\<exists>\<phi>. \<tau> = OrderedSet \<phi> \<and> \<phi> \<le> \<sigma> \<or> \<tau> = OclVoid)"
  "\<tau> \<le> Bag \<sigma> = (\<exists>\<phi>. \<tau> = Bag \<phi> \<and> \<phi> \<le> \<sigma> \<or> \<tau> = OclVoid)"
  "\<tau> \<le> Sequence \<sigma> = (\<exists>\<phi>. \<tau> = Sequence \<phi> \<and> \<phi> \<le> \<sigma> \<or> \<tau> = OclVoid)"

  "\<tau> \<le> Map \<rho> \<upsilon> = (\<exists>\<phi> \<sigma>.
      \<tau> = Map \<phi> \<sigma> \<and> \<phi> \<le> \<rho> \<and> \<sigma> \<le> \<upsilon> \<or>
      \<tau> = OclVoid)"
  by (auto simp: order.order_iff_strict reflpI)

lemma type\<^sub>N_less_right_simps [simp]:
  "\<tau> < Required \<upsilon> = (\<exists>\<rho>.
      \<tau> = Required \<rho> \<and> \<rho> < \<upsilon>)"
  "\<tau> < Optional \<upsilon> = (\<exists>\<rho>.
      \<tau> = Required \<rho> \<and> \<rho> \<le> \<upsilon> \<or>
      \<tau> = Optional \<rho> \<and> \<rho> < \<upsilon>)"
  by auto

lemma type\<^sub>N_less_eq_right_simps [simp]:
  "\<tau> \<le> Required \<upsilon> = (\<exists>\<rho>.
      \<tau> = Required \<rho> \<and> \<rho> \<le> \<upsilon>)"
  "\<tau> \<le> Optional \<upsilon> = (\<exists>\<rho>.
      \<tau> = Required \<rho> \<and> \<rho> \<le> \<upsilon> \<or>
      \<tau> = Optional \<rho> \<and> \<rho> \<le> \<upsilon>)"
  by auto

(*** Upper Semilattice of Types *********************************************)

section \<open>Upper Semilattice of Types\<close>

notation sup (infixl "\<squnion>" 65)

fun type_sup (infixl "\<squnion>\<^sub>T" 65)
and type_sup\<^sub>N (infixl "\<squnion>\<^sub>N" 65) where
  "OclAny \<squnion>\<^sub>T \<sigma> = OclAny"
| "OclVoid \<squnion>\<^sub>T \<sigma> = \<sigma>"

| "Boolean \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Boolean \<Rightarrow> Boolean
     | OclVoid \<Rightarrow> Boolean
     | _ \<Rightarrow> OclAny)"
| "Real \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Real \<Rightarrow> Real
     | Integer \<Rightarrow> Real
     | OclVoid \<Rightarrow> Real
     | _ \<Rightarrow> OclAny)"
| "Integer \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Real \<Rightarrow> Real
     | Integer \<Rightarrow> Integer
     | OclVoid \<Rightarrow> Integer
     | _ \<Rightarrow> OclAny)"
| "UnlimitedNatural \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of UnlimitedNatural \<Rightarrow> UnlimitedNatural
     | OclVoid \<Rightarrow> UnlimitedNatural
     | _ \<Rightarrow> OclAny)"
| "String \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of String \<Rightarrow> String
     | OclVoid \<Rightarrow> String
     | _ \<Rightarrow> OclAny)"

| "Enum \<E> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Enum \<E>' \<Rightarrow> if \<E> = \<E>' then Enum \<E> else OclAny
     | OclVoid \<Rightarrow> Enum \<E>
     | _ \<Rightarrow> OclAny)"
| "\<langle>\<C>\<rangle>\<^sub>\<T> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of \<langle>\<D>\<rangle>\<^sub>\<T> \<Rightarrow> \<langle>\<C> \<squnion> \<D>\<rangle>\<^sub>\<T>
     | OclVoid \<Rightarrow> \<langle>\<C>\<rangle>\<^sub>\<T>
     | _ \<Rightarrow> OclAny)"
| "Tuple \<pi> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Tuple \<xi> \<Rightarrow> Tuple (fmmerge_fun (\<squnion>\<^sub>N) \<pi> \<xi>)
     | OclVoid \<Rightarrow> Tuple \<pi>
     | _ \<Rightarrow> OclAny)"

| "Collection \<tau> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Collection \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Set \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OrderedSet \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Bag \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Sequence \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OclVoid \<Rightarrow> Collection \<tau>
     | _ \<Rightarrow> OclAny)"
| "Set \<tau> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Collection \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Set \<rho> \<Rightarrow> Set (\<tau> \<squnion>\<^sub>N \<rho>)
     | OrderedSet \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Bag \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Sequence \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OclVoid \<Rightarrow> Set \<tau>
     | _ \<Rightarrow> OclAny)"
| "OrderedSet \<tau> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Collection \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Set \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OrderedSet \<rho> \<Rightarrow> OrderedSet (\<tau> \<squnion>\<^sub>N \<rho>)
     | Bag \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Sequence \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OclVoid \<Rightarrow> OrderedSet \<tau>
     | _ \<Rightarrow> OclAny)"
| "Bag \<tau> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Collection \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Set \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OrderedSet \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Bag \<rho> \<Rightarrow> Bag (\<tau> \<squnion>\<^sub>N \<rho>)
     | Sequence \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OclVoid \<Rightarrow> Bag \<tau>
     | _ \<Rightarrow> OclAny)"
| "Sequence \<tau> \<squnion>\<^sub>T \<sigma> = (case \<sigma>
    of Collection \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Set \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | OrderedSet \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Bag \<rho> \<Rightarrow> Collection (\<tau> \<squnion>\<^sub>N \<rho>)
     | Sequence \<rho> \<Rightarrow> Sequence (\<tau> \<squnion>\<^sub>N \<rho>)
     | OclVoid \<Rightarrow> Sequence \<tau>
     | _ \<Rightarrow> OclAny)"

| "Map \<tau> \<sigma> \<squnion>\<^sub>T \<phi> = (case \<phi>
    of Map \<rho> \<upsilon> \<Rightarrow> Map (\<tau> \<squnion>\<^sub>N \<rho>) (\<sigma> \<squnion>\<^sub>N \<upsilon>)
     | OclVoid \<Rightarrow> Map \<tau> \<sigma>
     | _ \<Rightarrow> OclAny)"

| "Required \<tau> \<squnion>\<^sub>N \<sigma> = (case \<sigma>
    of Required \<rho> \<Rightarrow> Required (\<tau> \<squnion>\<^sub>T \<rho>)
     | Optional \<rho> \<Rightarrow> Optional (\<tau> \<squnion>\<^sub>T \<rho>))"
| "Optional \<tau> \<squnion>\<^sub>N \<sigma> = (case \<sigma>
    of Required \<rho> \<Rightarrow> Optional (\<tau> \<squnion>\<^sub>T \<rho>)
     | Optional \<rho> \<Rightarrow> Optional (\<tau> \<squnion>\<^sub>T \<rho>))"

lemma sup_ge1_type:
  "\<tau> \<le> \<tau> \<squnion>\<^sub>T \<sigma>"
  "\<tau>\<^sub>N \<le> \<tau>\<^sub>N \<squnion>\<^sub>N \<sigma>\<^sub>N"
  for \<tau> \<sigma> :: "'a::{order,semilattice_sup} type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N :: "'a type\<^sub>N"
proof (induct \<tau> and \<tau>\<^sub>N arbitrary: \<sigma> and \<sigma>\<^sub>N)
  case OclAny show ?case by auto
next
  case OclVoid show ?case by auto
next
  case Boolean show ?case by (cases \<sigma>; auto)
next
  case Real show ?case by (cases \<sigma>; auto)
next
  case Integer show ?case by (cases \<sigma>; auto)
next
  case UnlimitedNatural show ?case by (cases \<sigma>; auto)
next
  case String show ?case by (cases \<sigma>; auto)
next
  case (Enum \<E>) show ?case by (cases \<sigma>; auto)
next
  case (ObjectType \<C>) show ?case by (cases \<sigma>; auto)
next
  case (Tuple \<pi>) thus ?case by (cases \<sigma>;
    auto simp del: type_less_eq_left_simps type_less_eq_right_simps)
next
  case (Collection \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (Set \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (OrderedSet \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (Bag \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (Sequence \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (Map \<tau> \<phi>) thus ?case by (cases \<sigma>; auto)
next
  case (Required \<tau>) thus ?case by (cases \<sigma>\<^sub>N; auto)
next
  case (Optional \<tau>) thus ?case by (cases \<sigma>\<^sub>N; auto)
qed

lemma sup_commut_type:
  "\<tau> \<squnion>\<^sub>T \<sigma> = \<sigma> \<squnion>\<^sub>T \<tau>"
  "\<tau>\<^sub>N \<squnion>\<^sub>N \<sigma>\<^sub>N = \<sigma>\<^sub>N \<squnion>\<^sub>N \<tau>\<^sub>N"
  for \<tau> \<sigma> :: "'a::semilattice_sup type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N :: "'a type\<^sub>N"
proof (induct \<tau> and \<tau>\<^sub>N arbitrary: \<sigma> and \<sigma>\<^sub>N)
  case OclAny show ?case by (cases \<sigma>; simp)
next
  case OclVoid show ?case by (cases \<sigma>; simp)
next
  case Boolean show ?case by (cases \<sigma>; simp)
next
  case Real show ?case by (cases \<sigma>; simp)
next
  case Integer show ?case by (cases \<sigma>; simp)
next
  case UnlimitedNatural show ?case by (cases \<sigma>; simp)
next
  case String show ?case by (cases \<sigma>; simp)
next
  case (Enum \<E>) show ?case by (cases \<sigma>; simp)
next
  case (ObjectType \<C>) show ?case by (cases \<sigma>; simp add: sup_commute)
next
  case (Tuple \<pi>) thus ?case apply (cases \<sigma>; simp)
    using fmmerge_commut by blast
next
  case (Collection \<tau>) thus ?case by (cases \<sigma>; simp)
next
  case (Set \<tau>) thus ?case by (cases \<sigma>; simp)
next
  case (OrderedSet \<tau>) thus ?case by (cases \<sigma>; simp)
next
  case (Bag \<tau>) thus ?case by (cases \<sigma>; simp)
next
  case (Sequence \<tau>) thus ?case by (cases \<sigma>; simp)
next
  case (Map \<tau> \<phi>) thus ?case by (cases \<sigma>; simp)
next
  case (Required \<tau>) thus ?case by (cases \<sigma>\<^sub>N; simp)
next
  case (Optional \<tau>) thus ?case by (cases \<sigma>\<^sub>N; simp)
qed

lemma sup_least_type:
  "\<tau> \<le> \<rho> \<Longrightarrow> \<sigma> \<le> \<rho> \<Longrightarrow> \<tau> \<squnion>\<^sub>T \<sigma> \<le> \<rho>"
  "\<tau>\<^sub>N \<le> \<rho>\<^sub>N \<Longrightarrow> \<sigma>\<^sub>N \<le> \<rho>\<^sub>N \<Longrightarrow> \<tau>\<^sub>N \<squnion>\<^sub>N \<sigma>\<^sub>N \<le> \<rho>\<^sub>N"
  for \<tau> \<sigma> \<rho> :: "'a::semilattice_sup type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N \<rho>\<^sub>N :: "'a type\<^sub>N"
  by (induct \<rho> and \<rho>\<^sub>N arbitrary: \<tau> \<sigma> and \<tau>\<^sub>N \<sigma>\<^sub>N,
      auto simp: fmrel_on_fset_fmmerge1)

no_notation type_sup (infixl "\<squnion>\<^sub>T" 65)
no_notation type_sup\<^sub>N (infixl "\<squnion>\<^sub>N" 65)


instantiation type :: (semilattice_sup) semilattice_sup
begin
definition sup_type where [simp, code]: "sup_type \<equiv> type_sup"
instance
  apply intro_classes
  apply (simp add: sup_ge1_type)
  apply (simp add: sup_commut_type sup_ge1_type)
  by (simp add: sup_least_type)
end

instantiation type\<^sub>N :: (semilattice_sup) semilattice_sup
begin
definition sup_type\<^sub>N where [simp, code]: "sup_type\<^sub>N \<equiv> type_sup\<^sub>N"
instance
  apply intro_classes
  apply (simp add: sup_ge1_type)
  apply (simp add: sup_commut_type sup_ge1_type)
  by (simp add: sup_least_type)
end

(*** Code Setup *************************************************************)

section \<open>Code Setup\<close>

code_pred subtype .

lemma Tuple_measure_intro [intro]:
  assumes "fmlookup \<xi> k = Some \<sigma>"
    shows "(Inr (\<tau>, \<sigma>), Inl (Tuple \<pi>, Tuple \<xi>)) \<in>
   case_sum (type_size \<circ> snd) (type_size\<^sub>N \<circ> snd) <*mlex*> {}"
proof -
  have "fmlookup \<xi> k = Some \<sigma> \<Longrightarrow> type_size\<^sub>N \<sigma> < type_size (Tuple \<xi>)"
    by (simp add: elem_le_ffold' fmran'I)
  with assms show ?thesis
    unfolding mlex_prod_def less_eq by simp
qed

function subtype\<^sub>T_fun :: "'a::order type \<Rightarrow> 'a type \<Rightarrow> bool"
     and subtype\<^sub>N_fun :: "'a type\<^sub>N \<Rightarrow> 'a type\<^sub>N \<Rightarrow> bool" where

  "subtype\<^sub>T_fun OclAny _ = False"
| "subtype\<^sub>T_fun OclVoid \<sigma> = (\<sigma> \<noteq> OclVoid)"

| "subtype\<^sub>T_fun Boolean \<sigma> = (\<sigma> = OclAny)"
| "subtype\<^sub>T_fun Real \<sigma> = (\<sigma> = OclAny)"
| "subtype\<^sub>T_fun Integer \<sigma> = (\<sigma> = Real \<or> \<sigma> = OclAny)"
| "subtype\<^sub>T_fun UnlimitedNatural \<sigma> = (\<sigma> = OclAny)"
| "subtype\<^sub>T_fun String \<sigma> = (\<sigma> = OclAny)"

| "subtype\<^sub>T_fun (Enum _) \<sigma> = (\<sigma> = OclAny)"
| "subtype\<^sub>T_fun \<langle>\<C>\<rangle>\<^sub>\<T> \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | \<langle>\<D>\<rangle>\<^sub>\<T> \<Rightarrow> \<C> < \<D>
     | _ \<Rightarrow> False)"
| "subtype\<^sub>T_fun (Tuple \<pi>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Tuple \<xi> \<Rightarrow> strict_subtuple_fun (\<lambda>\<tau> \<sigma>. subtype\<^sub>N_fun \<tau> \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi>
     | _ \<Rightarrow> False)"

| "subtype\<^sub>T_fun (Collection \<tau>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Collection \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho>
     | _ \<Rightarrow> False)"
| "subtype\<^sub>T_fun (Set \<tau>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Collection \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho> \<or> \<tau> = \<rho>
     | Set \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho>
     | _ \<Rightarrow> False)"
| "subtype\<^sub>T_fun (OrderedSet \<tau>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Collection \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho> \<or> \<tau> = \<rho>
     | OrderedSet \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho>
     | _ \<Rightarrow> False)"
| "subtype\<^sub>T_fun (Bag \<tau>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Collection \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho> \<or> \<tau> = \<rho>
     | Bag \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho>
     | _ \<Rightarrow> False)"
| "subtype\<^sub>T_fun (Sequence \<tau>) \<sigma> = (case \<sigma>
    of OclAny \<Rightarrow> True
     | Collection \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho> \<or> \<tau> = \<rho>
     | Sequence \<rho> \<Rightarrow> subtype\<^sub>N_fun \<tau> \<rho>
     | _ \<Rightarrow> False)"

| "subtype\<^sub>T_fun (Map \<tau> \<sigma>) \<phi> = (case \<phi>
    of OclAny \<Rightarrow> True
     | Map \<rho> \<upsilon> \<Rightarrow>
        \<tau> = \<rho> \<and> subtype\<^sub>N_fun \<sigma> \<upsilon> \<or>
        subtype\<^sub>N_fun \<tau> \<rho> \<and> \<sigma> = \<upsilon> \<or>
        subtype\<^sub>N_fun \<tau> \<rho> \<and> subtype\<^sub>N_fun \<sigma> \<upsilon>
     | _ \<Rightarrow> False)"

| "subtype\<^sub>N_fun (Required \<tau>) \<sigma> = (case \<sigma>
    of Required \<rho> \<Rightarrow> subtype\<^sub>T_fun \<tau> \<rho>
     | Optional \<rho> \<Rightarrow> subtype\<^sub>T_fun \<tau> \<rho> \<or> \<tau> = \<rho>)"
| "subtype\<^sub>N_fun (Optional \<tau>) \<sigma>\<^sub>N = (case \<sigma>\<^sub>N
    of Required \<rho> \<Rightarrow> False
     | Optional \<rho> \<Rightarrow> subtype\<^sub>T_fun \<tau> \<rho>)"
  by pat_completeness auto
termination
  apply (relation "case_sum (size \<circ> snd) (size \<circ> snd) <*mlex*> {}")
  by (auto simp add: wf_mlex mlex_less)

lemma subtuple_subtype\<^sub>N_fun_intro [simp]:
  assumes "(\<And>\<tau> \<sigma>\<^sub>N. \<tau> \<in> fmran' \<pi> \<Longrightarrow> \<tau> < \<sigma>\<^sub>N \<Longrightarrow> subtype\<^sub>N_fun \<tau> \<sigma>\<^sub>N)"
      and "subtuple (\<le>) \<pi> \<xi>"
    shows "subtuple (\<lambda>\<tau> \<sigma>. subtype\<^sub>N_fun \<tau> \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi>"
proof -
  have "subtuple (\<le>) \<pi> \<xi> \<longrightarrow> subtuple (\<lambda>\<tau> \<sigma>. subtype\<^sub>N_fun \<tau> \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi>"
    apply (rule subtuple_mono)
    using assms(1) by auto
  with assms(2) show ?thesis by simp
qed

lemma subtuple_subtype\<^sub>N_fun_drule [simp]:
  assumes "(\<And>\<tau> \<sigma>\<^sub>N. \<tau> \<in> fmran' \<pi> \<Longrightarrow> subtype\<^sub>N_fun \<tau> \<sigma>\<^sub>N \<Longrightarrow> \<tau> < \<sigma>\<^sub>N)"
      and "subtuple (\<lambda>\<tau> \<sigma>. subtype\<^sub>N_fun \<tau> \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi>"
    shows "subtuple (\<le>) \<pi> \<xi>"
proof -
  have "subtuple (\<lambda>\<tau> \<sigma>. subtype\<^sub>N_fun \<tau> \<sigma> \<or> \<tau> = \<sigma>) \<pi> \<xi> \<longrightarrow> subtuple (\<le>) \<pi> \<xi>"
    apply (rule subtuple_mono)
    by (simp add: assms(1) order.strict_implies_order)
  with assms(2) show ?thesis by simp
qed

lemma
  subtype\<^sub>T_fun_intro: "\<tau> < \<sigma> \<Longrightarrow> subtype\<^sub>T_fun \<tau> \<sigma>" and
  subtype\<^sub>N_fun_intro: "\<tau>\<^sub>N < \<sigma>\<^sub>N \<Longrightarrow> subtype\<^sub>N_fun \<tau>\<^sub>N \<sigma>\<^sub>N"
  for \<tau> \<sigma> :: "'a::order type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N :: "'a type\<^sub>N"
  by (induct \<tau> and \<tau>\<^sub>N arbitrary: \<sigma> and \<sigma>\<^sub>N, auto)

lemma
  subtype\<^sub>T_fun_drule: "subtype\<^sub>T_fun \<tau> \<sigma> \<Longrightarrow> \<tau> < \<sigma>" and
  subtype\<^sub>N_fun_drule: "subtype\<^sub>N_fun \<tau>\<^sub>N \<sigma>\<^sub>N \<Longrightarrow> \<tau>\<^sub>N < \<sigma>\<^sub>N"
  for \<tau> \<sigma> :: "'a::order type"
  and \<tau>\<^sub>N \<sigma>\<^sub>N :: "'a type\<^sub>N"
proof (induct \<tau> and \<tau>\<^sub>N arbitrary: \<sigma> and \<sigma>\<^sub>N)
  case OclAny thus ?case by auto
next
  case OclVoid thus ?case by auto
next
  case Boolean thus ?case by auto
next
  case Real thus ?case by auto
next
  case Integer thus ?case by auto
next
  case UnlimitedNatural thus ?case by auto
next
  case String thus ?case by auto
next
  case (Enum \<E>) thus ?case by auto
next
  case (ObjectType \<C>) thus ?case by (cases \<sigma>; auto)
next
  case (Tuple \<pi>) thus ?case by (cases \<sigma>; auto)
next
  case (Collection \<tau>) thus ?case by (cases \<sigma>; auto)
next
  case (Set \<tau>) thus ?case by (cases \<sigma>; auto simp: less_imp_le)
next
  case (OrderedSet \<tau>) thus ?case by (cases \<sigma>; auto simp: less_imp_le)
next
  case (Bag \<tau>) thus ?case by (cases \<sigma>; auto simp: less_imp_le)
next
  case (Sequence \<tau>) thus ?case by (cases \<sigma>; auto simp: less_imp_le)
next
  case (Map \<tau> \<phi>) thus ?case by (cases \<sigma>; auto)
next
  case (Required \<tau>) thus ?case by (cases \<sigma>\<^sub>N; auto simp: order.strict_implies_order)
next
  case (Optional \<tau>) thus ?case by (cases \<sigma>\<^sub>N; auto)
qed

lemma less_type\<^sub>T_code [code]:
  "(<) = subtype\<^sub>T_fun"
  by (intro ext iffI; simp add: subtype\<^sub>T_fun_intro subtype\<^sub>T_fun_drule)

lemma less_type\<^sub>N_code [code]:
  "(<) = subtype\<^sub>N_fun"
  by (intro ext iffI; simp add: subtype\<^sub>N_fun_intro subtype\<^sub>N_fun_drule)

lemma less_eq_type\<^sub>T_code [code]:
  "(\<le>) = (\<lambda>x y. subtype\<^sub>T_fun x y \<or> x = y)"
  unfolding dual_order.order_iff_strict less_type\<^sub>T_code
  by auto

lemma less_eq_type\<^sub>N_code [code]:
  "(\<le>) = (\<lambda>x y. subtype\<^sub>N_fun x y \<or> x = y)"
  unfolding dual_order.order_iff_strict less_type\<^sub>N_code
  by auto

end
