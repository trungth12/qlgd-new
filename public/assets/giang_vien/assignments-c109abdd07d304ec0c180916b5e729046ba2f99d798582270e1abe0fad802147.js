- /**
  - * @jsx React.DOM
  - */
"use strict";

var React = require("react");
//= require ./grade3       
var DATA = [{ assignment_group_id: 1, name: 'BT1', weight: 50, assignments: [{ assignment_id: 1, name: 'BT11', points: 10 }, { assignment_id: 2, name: 'BT12', points: 8 }]
}, { assignment_group_id: 2, name: 'BT2', weight: 50, assignments: [{ assignment_id: 3, name: 'BT21', points: 9 }, { assignment_id: 4, name: 'BT22', points: 8 }] }];
var Assignments = React.createClass({
    displayName: "Assignments",

    getInitialState: function () {
        return { data: [], add: 0 };
    },
    loadData: function () {
        $.ajax({
            url: "/teacher/lop/" + this.props.lop + "/assignments.json",
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
            }).bind(this)
        });
    },
    componentWillMount: function () {
        this.loadData();
    },

    handleEdit: function (obj) {
        obj._method = "put";
        $.ajax({
            url: "/teacher//lop/" + this.props.lop + "/assignment_groups",
            type: 'POST',
            data: obj,
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
                React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                React.renderComponent(React.createElement(Grade2, { lop: this.props.lop }), document.getElementById("grades"));
            }).bind(this)
        });
    },
    handleUpdate: function (d) {
        d._method = "put";
        $.ajax({
            url: "/teacher//lop/" + this.props.lop + "/assignments",
            type: 'POST',
            data: d,
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
                React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                React.renderComponent(React.createElement(Grade2, { lop: this.props.lop }), document.getElementById("grades"));
            }).bind(this)
        });
        return false;
    },
    enableAdd: function (e) {
        this.state.add = 1;
        this.forceUpdate();
    },
    cancelAdd: function (e) {
        this.state.add = 0;
        this.forceUpdate();
    },
    onAdd: function (e) {

        var name = this.refs.name.getDOMNode().value;
        var weight = this.refs.weight.getDOMNode().value;
        console.log('onAdd');

        if (parseInt(weight) > 0) {
            var d = {
                lop_id: this.props.lop_id,
                name: name,
                weight: weight
            };
            $.ajax({
                url: "/teacher//lop/" + this.props.lop + "/assignment_groups",
                type: 'POST',
                data: d,
                success: (function (data) {
                    data.forEach(function (d) {
                        if (d.assignments != null && d.assignments.length > 0) {
                            d.assignments.map(function (d2) {
                                d2.edit = 0;
                                return d2;
                            });
                        }
                    });
                    this.setState({ data: data, add: 0 });
                    React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                    React.renderComponent(React.createElement(Grade, { lop: this.props.lop }), document.getElementById("grades"));
                }).bind(this)
            });
        } else {
            alert("Trọng số phải lớn hơn 0");
        }

        return false;
    },
    handleDelete: function (assignment_group) {
        var d = { assignment_group_id: assignment_group.assignment_group_id, "_method": "delete" };
        $.ajax({
            url: "/teacher//lop/" + this.props.lop + "/assignment_groups",
            type: 'POST',
            data: d,
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
                React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                React.renderComponent(React.createElement(Grade, { lop: this.props.lop }), document.getElementById("grades"));
            }).bind(this)
        });
    },
    handleAssignmentDelete: function (assignment) {
        var d = { assignment_id: assignment.assignment_id, "_method": "delete" };
        $.ajax({
            url: "/teacher//lop/" + this.props.lop + "/assignments",
            type: 'POST',
            data: d,
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
                React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                React.renderComponent(React.createElement(Grade, { lop: this.props.lop }), document.getElementById("grades"));
            }).bind(this)
        });
    },
    handleAssignmentAdd: function (obj) {
        var d = {
            assignment_group_id: obj.assignment_group_id,
            name: obj.name,
            points: obj.points
        };
        $.ajax({
            url: "/teacher//lop/" + this.props.lop + "/assignments",
            type: 'POST',
            data: d,
            success: (function (data) {
                data.forEach(function (d) {
                    if (d.assignments != null && d.assignments.length > 0) {
                        d.assignments.map(function (d2) {
                            d2.edit = 0;
                            return d2;
                        });
                    }
                });
                this.setState({ data: data, add: 0 });
                React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                React.renderComponent(React.createElement(Grade, { lop: this.props.lop }), document.getElementById("grades"));
            }).bind(this)
        });
        return false;
    },
    componentDidUpdate: function () {
        var self = this;
        var multi = document.getElementById('multi');
        /*new Sortable(multi, {
            draggable: '.tile',
            handle: '.tile__name',
            onUpdate: function(evt){
                var type = $('#'+evt.item.id).data('type');
                if (type === 'assignment_group'){
                   var data = {
                    assignment_group_id: $('#'+evt.item.id).data('group'),
                    position: $("li.layer.tile").index(evt.item)
                    };
                    $.ajax({
                      url: "/lop/" + self.props.lop + "/reorder_assignment_groups",
                      type: 'POST',
                      data: data,
                      success: function(data) {             
                        React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                        React.renderComponent(<Grade giang_vien={self.props.giang_vien} lop={self.props.lop} />,
                                    document.getElementById("grades"));
                      }.bind(self)
                    });      
                }                            
            }
        });*/

        [].forEach.call(multi.getElementsByClassName('tile__list'), function (el) {
            new Sortable(el, { group: 'photo' + el.id,
                onUpdate: function (evt) {
                    var assignment_group_id = $('#' + evt.item.id).data('group');
                    var assignment_id = $('#' + evt.item.id).data('assignment');
                    var position = $('li.group' + assignment_group_id).index(evt.item);
                    var data = {
                        assignment_group_id: assignment_group_id,
                        assignment_id: assignment_id,
                        position: position
                    };
                    $.ajax({
                        url: "/teacher//lop/" + self.props.lop + "/reorder_assignments",
                        type: 'POST',
                        data: data,
                        success: (function (data) {
                            React.unmountAndReleaseReactRootNode(document.getElementById('grades'));
                            React.renderComponent(React.createElement(Grade, { lop: self.props.lop }), document.getElementById("grades"));
                        }).bind(self)
                    });
                }
            });
        });
    },
    render: function () {
        var self = this;
        var x = this.state.data.map(function (d) {
            return React.createElement(AssignmentGroup, { key: 'assignment_group' + d.assignment_group_id, onAssignmentDelete: self.handleAssignmentDelete, onDelete: self.handleDelete, onEdit: self.handleEdit, weight: d.weight, group_name: d.name, onUpdate: self.handleUpdate, group: d.assignment_group_id, can_destroy: d.can_destroy, data: d.assignments, onAddAssignment: self.handleAssignmentAdd });
        });
        if (this.state.add === 0) {
            return React.createElement(
                "div",
                null,
                React.createElement("hr", null),
                React.createElement(
                    "button",
                    { "class": "btn btn-primary btn-sm glow", onClick: this.enableAdd },
                    "Thêm"
                ),
                React.createElement("hr", null),
                React.createElement(
                    "ul",
                    { id: "multi" },
                    x
                )
            );
        } else {
            return React.createElement(
                "div",
                null,
                React.createElement("hr", null),
                React.createElement("input", { ref: "name", type: "text", placeholder: "Tên nhóm điểm" }),
                React.createElement("input", { ref: "weight", type: "text", placeholder: "Trọng số" }),
                React.createElement(
                    "div",
                    { "class": "btn-group btn-group-sm" },
                    React.createElement(
                        "button",
                        { "class": "btn btn-primary btn-sm glow", onClick: this.cancelAdd },
                        "Hủy"
                    ),
                    React.createElement(
                        "button",
                        { "class": "btn btn-primary btn-sm glow", onClick: this.onAdd },
                        "Cập nhật"
                    )
                ),
                React.createElement("hr", null),
                React.createElement(
                    "ul",
                    { id: "multi" },
                    x
                )
            );
        }
    }
});
var AssignmentGroup = React.createClass({
    displayName: "AssignmentGroup",

    getInitialState: function () {
        return { add: 0, edit: 0 };
    },
    handleClick: function () {
        this.setState({ add: 1, edit: 0 });
    },
    handleCancel: function () {
        this.setState({ add: 0, edit: 0 });
    },
    handleAdd: function () {
        var name = this.refs.name.getDOMNode().value;
        var points = this.refs.points.getDOMNode().value;
        this.setState({ add: 0, edit: 0 });
        if (parseInt(points) > 0) {
            this.props.onAddAssignment({ assignment_group_id: this.props.group, name: name, points: points });
        } else {
            alert("Trọng số phải lớn hơn 0");
        }
    },
    cancelUpdateName: function () {
        this.setState({ edit: 0, add: 0 });
    },
    handleUpdateName: function () {
        this.setState({ add: 0, edit: 1 });
    },
    handleEdit: function () {
        var x = this.refs.name.getDOMNode().value;
        var y = this.refs.weight.getDOMNode().value;
        if (parseInt(y) > 0) {
            this.setState({ edit: 0, add: 0 });
            this.props.onEdit({ assignment_group_id: this.props.group, name: x, weight: y });
        } else {
            alert("Trọng số phải lớn hơn 0");
        }
    },
    handleDelete: function (e) {
        if (confirm('Đồng ý')) {
            this.props.onDelete({ assignment_group_id: this.props.group });
        }
    },
    componentDidUpdate: function () {
        if (this.state.edit == 1) {
            this.refs.name.getDOMNode().value = this.props.group_name;
            this.refs.weight.getDOMNode().value = this.props.weight;
        }
    },
    render: function () {
        var self = this;
        var x = React.createElement("li", null);
        if (this.props.data != null) {
            x = this.props.data.map(function (d) {
                return React.createElement(Assignment, { group: self.props.group, key: 'assignment' + d.assignment_id, data: d, onUpdate: self.props.onUpdate, onDelete: self.props.onAssignmentDelete });
            });
        }
        if (this.state.add === 0) {
            if (this.state.edit === 0) {
                return React.createElement(
                    "li",
                    { id: 'group' + this.props.group, "data-type": "assignment_group", "data-group": this.props.group, "class": "layer tile" },
                    React.createElement(
                        "div",
                        { "class": "row" },
                        React.createElement(
                            "div",
                            { "class": "col-sm-3", "class": "tile__name" },
                            this.props.group_name
                        ),
                        React.createElement(
                            "div",
                            { style: { "font-weight": "bold" }, "class": "col-sm-3", onClick: this.handleWeight },
                            this.props.weight,
                            " %"
                        ),
                        React.createElement(
                            "button",
                            { onClick: this.handleUpdateName, "class": "btn btn-sm btn-success" },
                            "Sửa"
                        ),
                        React.createElement(
                            "button",
                            { style: { display: this.props.can_destroy === false ? 'none' : '' }, "class": "btn btn-danger btn-sm glow", onClick: this.handleDelete },
                            "Xóa"
                        ),
                        React.createElement(
                            "span",
                            null,
                            '                 '
                        ),
                        React.createElement(
                            "button",
                            { "class": "btn btn-primary btn-sm glow", onClick: this.handleClick },
                            "Thêm đầu điểm"
                        ),
                        React.createElement(
                            "ul",
                            { id: 'group' + this.props.group, "data-group": this.props.group, "class": "tile__list" },
                            x
                        )
                    )
                );
            } else {
                return React.createElement(
                    "li",
                    null,
                    React.createElement(
                        "div",
                        null,
                        React.createElement("input", { ref: "name", type: "text", id: "group" + this.props.group, placeholder: "Tên nhóm điểm" }),
                        React.createElement("input", { ref: "weight", type: "text", id: "weight" + this.props.group, placeholder: "Trọng số" }),
                        React.createElement(
                            "div",
                            { "class": "btn-group btn-group-sm" },
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.cancelUpdateName },
                                "Hủy"
                            ),
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleEdit },
                                "Cập nhật"
                            )
                        )
                    ),
                    React.createElement(
                        "div",
                        null,
                        React.createElement(
                            "button",
                            { "class": "btn btn-primary btn-sm glow", onClick: this.handleClick },
                            "Thêm đầu điểm"
                        ),
                        React.createElement(
                            "ul",
                            null,
                            x
                        )
                    )
                );
            }
        } else {
            if (this.state.edit === 0) {
                return React.createElement(
                    "li",
                    null,
                    React.createElement(
                        "span",
                        { "class": "tile__name" },
                        this.props.group_name
                    ),
                    React.createElement(
                        "span",
                        null,
                        this.props.weight
                    ),
                    React.createElement(
                        "button",
                        { onClick: this.handleUpdateName, "class": "btn btn-sm btn-success" },
                        "Sửa"
                    ),
                    React.createElement(
                        "button",
                        { style: { display: this.props.can_destroy === false ? 'none' : '' }, "class": "btn btn-danger btn-sm glow", onClick: this.handleDelete },
                        "Xóa"
                    ),
                    React.createElement(
                        "div",
                        null,
                        React.createElement("input", { ref: "name", type: "text", placeholder: "Tên đầu điểm" }),
                        React.createElement("input", { ref: "points", type: "text", placeholder: "Điểm tối đa" }),
                        React.createElement(
                            "div",
                            { "class": "btn-group btn-group-sm" },
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleCancel },
                                "Hủy"
                            ),
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleAdd },
                                "Cập nhật"
                            )
                        ),
                        React.createElement(
                            "ul",
                            null,
                            x
                        )
                    )
                );
            } else {
                return React.createElement(
                    "li",
                    null,
                    React.createElement(
                        "div",
                        null,
                        React.createElement("input", { ref: "name", type: "text", id: "group" + this.props.group, placeholder: "Tên nhóm điểm" }),
                        React.createElement("input", { ref: "weight", type: "text", id: "weight" + this.props.group, placeholder: "Trọng số" }),
                        React.createElement(
                            "div",
                            { "class": "btn-group btn-group-sm" },
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.cancelUpdateName },
                                "Hủy"
                            ),
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleEdit },
                                "Cập nhật"
                            )
                        )
                    ),
                    React.createElement(
                        "div",
                        null,
                        React.createElement("input", { ref: "name", type: "text", placeholder: "Tên đầu điểm" }),
                        React.createElement("input", { ref: "points", type: "text", placeholder: "Điểm tối đa" }),
                        React.createElement(
                            "div",
                            { "class": "btn-group btn-group-sm" },
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleCancel },
                                "Hủy"
                            ),
                            React.createElement(
                                "button",
                                { "class": "btn btn-primary btn-sm glow", onClick: this.handleAdd },
                                "Cập nhật"
                            )
                        ),
                        React.createElement(
                            "ul",
                            null,
                            x
                        )
                    )
                );
            }
        }
    }
});

var Assignment = React.createClass({
    displayName: "Assignment",

    getInitialState: function () {
        return { edit: 0 };
    },
    handleEdit: function (e) {
        this.setState({ edit: 1 });
    },
    handleCancelEdit: function (e) {
        this.setState({ edit: 0 });
    },
    handleUpdate: function (e) {
        if (this.state.edit === 1) {
            var name = this.refs.mname.getDOMNode().value;
            var points = this.refs.mpoints.getDOMNode().value;
            var d = { assignment_group_id: this.props.group, assignment_id: this.props.data.assignment_id, name: name, points: points };
            this.setState({ edit: 0 });
            this.props.onUpdate(d);
        }
    },
    handleDelete: function (e) {
        if (confirm('Đồng ý')) {
            this.props.onDelete({ assignment_id: this.props.data.assignment_id });
        }
    },
    componentDidUpdate: function () {
        $('#mname' + this.props.data.assignment_id).val(this.props.data.name);
        $('#mpoints' + this.props.data.assignment_id).val(this.props.data.points);

        if (this.props.data.can_destroy === false) {
            $('#btndelete' + this.props.data.assignment_id).hide();
        }
    },
    render: function () {
        if (this.state.edit === 1) {
            return React.createElement(
                "li",
                null,
                React.createElement("input", { id: "mname" + this.props.data.assignment_id, ref: "mname", type: "text" }),
                React.createElement("input", { id: "mpoints" + this.props.data.assignment_id, ref: "mpoints", type: "text" }),
                React.createElement("input", { "class": "btn btn-primary btn-sm", onClick: this.handleCancelEdit, type: "submit", value: "Hủy" }),
                React.createElement("input", { "class": "btn btn-primary btn-sm", onClick: this.handleUpdate, type: "submit", value: "Cập nhật" })
            );
        } else {
            return React.createElement(
                "li",
                { "data-type": "assignment", "data-assignment": this.props.data.assignment_id, "data-group": this.props.group, id: 'item' + this.props.data.assignment_id, "class": 'group' + this.props.group },
                React.createElement(
                    "div",
                    null,
                    React.createElement(
                        "span",
                        null,
                        this.props.data.name
                    ),
                    React.createElement(
                        "span",
                        null,
                        ", điểm tối đa: ",
                        this.props.data.points
                    ),
                    React.createElement(
                        "span",
                        null,
                        React.createElement(
                            "button",
                            { onClick: this.handleEdit, "class": "btn btn-sm btn-success" },
                            "Sửa"
                        ),
                        React.createElement(
                            "button",
                            { style: { display: this.props.data.can_destroy === false ? 'none' : '' }, "class": "btn btn-danger btn-sm glow", onClick: this.handleDelete },
                            "Xóa"
                        )
                    )
                )
            );
        }
    }
});