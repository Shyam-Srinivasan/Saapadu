import axios from "axios";
import {useCallback, useEffect, useState} from "react";
import {Container, Table, Row, Col} from "react-bootstrap";

export const RecentOrdersTable = () => {
    const API_BASE = `http://${window.location.hostname}:8080`;
    const [college, setCollege] = useState(null);
    const [recentOrders, setRecentOrders] = useState([]);

    const loadRecentOrders = useCallback(async () => {
        try {
            if (!college?.id) {
                return;
            }
            const res = await axios.get(
                `${API_BASE}/home/recent-orders`, {
                    params: {collegeId: college.id, limit: 10},
                    validateStatus: () => true,
                }
            );
            if (res.status === 200 && Array.isArray(res.data)) {
                setRecentOrders(res.data);
            } else {
                alert("Something went wrong to fetch recent orders.");
            }
        } catch (err) {
            alert(`${err} - An error has been occurred!`);
        }
    }, [college?.id]);

    useEffect(() => {
        try {
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            setCollege(savedCollege);
        } catch {
            setCollege(null);
        }
    }, []);

    useEffect(() => {
        if (college?.id) {
            loadRecentOrders();
        }
    }, [college, loadRecentOrders]);

    return (
        <Container fluid className="recent-orders-container">
            <Row>
                <Col>
                    <Table responsive striped bordered hover className="recent-orders-table">
                        <thead>
                        <tr>
                            <th className="align-middle text-center">Order id</th>
                            <th className="align-middle text-center">User</th>
                            <th className="align-middle text-center">Items</th>
                            <th className="align-middle text-center">Shop</th>
                            <th className="align-middle text-center">Amount</th>
                            <th className="align-middle text-center">Timestamp</th>
                            <th className="align-middle text-center">Status</th>
                        </tr>
                        </thead>
                        <tbody className="text-center">
                        {recentOrders.length > 0 ? (
                            recentOrders.map((order) => (
                                <tr key={order.order_id}>
                                    <td className="align-middle">{order.order_id}</td>
                                    <td className="align-middle">{`${order.user_name} (${order.user_id})`}</td>
                                    <td className="align-middle">
                                        {order.items?.map((item, i) => (
                                            <div key={i}>
                                                {item.item_name} x {item.quantity}
                                            </div>
                                        ))}
                                    </td>
                                    <td className="align-middle">{order.shop_name}</td>
                                    <td className="align-middle">₹{order.total_amount}</td>
                                    <td className="align-middle">{new Date(order.timeStamp).toLocaleString()}</td>
                                    <td className="align-middle">{order.purchased ? "Purchased" : "Pending"}</td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan="7" className="text-center">
                                    No recent Orders found..
                                </td>
                            </tr>
                        )}
                        </tbody>
                    </Table>
                </Col>
            </Row>
        </Container>
    );
};