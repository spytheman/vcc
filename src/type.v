module main

struct Type {
mut:
  kind []Typekind
  suffix []int
}

enum Typekind {
  int
  char
  ptr
  ary
}

fn (typ Type) size() int {
  kind := typ.kind.last()
  size := match kind {
    .char => {1}
    .int => {4}
    .ptr => {8}
    .ary => {typ.suffix.last() * typ.reduce().size()}
    else => {8}
  }
  return size
}

fn (typ Type) reduce() &Type {
  mut typ2 := &Type{}
  typ2.kind = typ.kind.clone()
  typ2.suffix = typ.suffix.clone()
  if typ2.kind.last() == .ary {
    typ2.suffix.delete(typ2.suffix.len-1)
  }
  typ2.kind.delete(typ2.kind.len-1)
  return typ2
}

fn (typ Type) is_int() bool {
  return typ.kind.last() == .int
}

fn (typ Type) is_ptr() bool {
  return typ.kind.last() == .ptr || typ.kind.last() == .ary
}

fn (node mut Node) add_type() {
  if node.kind == .nothing || node.typ != 0 {
    return
  }
  if node.cond != 0 {node.cond.add_type()}
  if node.first != 0 {node.first.add_type()}
  if node.left != 0 {node.left.add_type()}
  if node.right != 0 {node.right.add_type()}

  for i in node.code {
    mut no := &Node(i)
    no.add_type()
  }

  mut typ := &Type{}

  match(node.kind) {
    .assign => {
      node.typ = node.left.typ
    }
    .add    => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .sub    => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .mul    => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .div    => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .eq     => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .ne     => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .gt     => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .ge     => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .num    => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .call   => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .sizof  => {
      typ.kind << Typekind.int
      node.typ = typ
    }
    .deref  => {
      if node.left.typ.is_ptr() {
        typ.kind = node.left.typ.kind.clone()
        typ.suffix = node.left.typ.suffix.clone()
        typ = typ.reduce()
      } else {
        typ.kind << Typekind.int
      }
      node.typ = typ
    }
    .addr   => {
      typ.kind = node.left.typ.kind.clone()
      typ.suffix = node.left.typ.suffix.clone()
      if typ.kind.last() == .ary {
        typ = typ.reduce()
      }
      typ.kind << Typekind.ptr
      node.typ = typ
    }
  }
}